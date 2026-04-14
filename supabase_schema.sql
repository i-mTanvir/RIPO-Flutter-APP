create extension if not exists pgcrypto with schema extensions;

create type public.app_role as enum ('admin', 'customer', 'provider');
create type public.verification_status as enum ('pending', 'verified', 'rejected', 'suspended');
create type public.booking_status as enum ('pending', 'accepted', 'in_progress', 'completed', 'rejected', 'cancelled');
create type public.payment_status as enum ('unpaid', 'paid', 'refunded', 'partial');
create type public.payment_method as enum ('cash', 'online', 'wallet', 'offline');
create type public.notification_type as enum ('booking', 'offer', 'system', 'promo');

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  user_role public.app_role;
  user_full_name text;
  user_phone text;
  user_gender text;
  user_age int;
  user_nid text;
  user_trade_license text;
  user_business_name text;
begin
  user_role := case coalesce(new.raw_user_meta_data->>'role', 'customer')
    when 'admin' then 'admin'::public.app_role
    when 'provider' then 'provider'::public.app_role
    else 'customer'::public.app_role
  end;

  user_full_name := coalesce(
    nullif(new.raw_user_meta_data->>'full_name', ''),
    split_part(coalesce(new.email, ''), '@', 1),
    'User'
  );
  user_phone := nullif(new.raw_user_meta_data->>'phone', '');
  user_gender := nullif(new.raw_user_meta_data->>'gender', '');
  user_age := nullif(new.raw_user_meta_data->>'age', '')::int;
  user_nid := nullif(new.raw_user_meta_data->>'nid_number', '');
  user_trade_license := nullif(new.raw_user_meta_data->>'trade_license_number', '');
  user_business_name := coalesce(
    nullif(new.raw_user_meta_data->>'business_name', ''),
    user_full_name || ' Services'
  );

  insert into public.profiles (
    id,
    role,
    full_name,
    email,
    phone,
    gender,
    age
  ) values (
    new.id,
    user_role,
    user_full_name,
    new.email,
    user_phone,
    user_gender,
    user_age
  )
  on conflict (id) do update
  set
    role = excluded.role,
    full_name = excluded.full_name,
    email = excluded.email,
    phone = excluded.phone,
    gender = excluded.gender,
    age = excluded.age;

  if user_role = 'customer'::public.app_role then
    insert into public.customer_profiles (user_id)
    values (new.id)
    on conflict (user_id) do nothing;
  elsif user_role = 'provider'::public.app_role then
    insert into public.provider_profiles (
      user_id,
      business_name,
      owner_name,
      business_email,
      business_phone,
      nid_number,
      trade_license_number
    ) values (
      new.id,
      user_business_name,
      user_full_name,
      new.email,
      user_phone,
      user_nid,
      user_trade_license
    )
    on conflict (user_id) do update
    set
      business_name = excluded.business_name,
      owner_name = excluded.owner_name,
      business_email = excluded.business_email,
      business_phone = excluded.business_phone,
      nid_number = excluded.nid_number,
      trade_license_number = excluded.trade_license_number;
  end if;

  return new;
end;
$$;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  role public.app_role not null,
  full_name text not null,
  email text,
  phone text,
  avatar_url text,
  gender text,
  age int,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint profiles_email_unique unique (email),
  constraint profiles_phone_unique unique (phone),
  constraint profiles_age_positive check (age is null or age > 0)
);

create table public.locations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  label text not null,
  address_line text not null,
  area text,
  city text not null,
  district text,
  postal_code text,
  latitude numeric(9,6),
  longitude numeric(9,6),
  is_default boolean not null default false,
  created_at timestamptz not null default now()
);

create table public.customer_profiles (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  default_location_id uuid,
  date_of_birth date,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.provider_profiles (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  business_name text not null,
  owner_name text,
  business_email text,
  business_phone text,
  working_days int[] not null default array[6,0,1,2,3,4],
  work_start_time time not null default '08:00:00'::time,
  work_end_time time not null default '19:00:00'::time,
  business_address text,
  bio text,
  experience_years int,
  trade_license_number text,
  nid_number text,
  verification_status public.verification_status not null default 'pending',
  service_area_text text,
  rating_avg numeric(3,2) not null default 0,
  review_count int not null default 0,
  joined_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint provider_profiles_experience_non_negative check (experience_years is null or experience_years >= 0),
  constraint provider_profiles_rating_range check (rating_avg >= 0 and rating_avg <= 5),
  constraint provider_profiles_working_days_valid check (working_days <@ array[0,1,2,3,4,5,6]),
  constraint provider_profiles_work_time_order check (work_end_time > work_start_time)
);

alter table public.customer_profiles
  add constraint customer_profiles_default_location_fk
  foreign key (default_location_id) references public.locations(id) on delete set null;

create table public.service_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null,
  parent_group text not null,
  icon_name text,
  is_active boolean not null default true,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  constraint service_categories_name_unique unique (name),
  constraint service_categories_slug_unique unique (slug)
);

create table public.services (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.provider_profiles(user_id) on delete cascade,
  category_id uuid not null references public.service_categories(id) on delete restrict,
  service_location_id uuid references public.locations(id) on delete set null,
  service_location_text text,
  service_latitude numeric(9,6),
  service_longitude numeric(9,6),
  name text not null,
  description text,
  variations text,
  faqs text,
  duration_text text,
  regular_price numeric(10,2) not null,
  offer_price numeric(10,2),
  currency text not null default 'BDT',
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint services_regular_price_non_negative check (regular_price >= 0),
  constraint services_offer_price_non_negative check (offer_price is null or offer_price >= 0),
  constraint services_offer_not_greater_than_regular check (offer_price is null or offer_price <= regular_price)
);

create table public.service_media (
  id uuid primary key default gen_random_uuid(),
  service_id uuid not null references public.services(id) on delete cascade,
  file_url text not null,
  is_cover boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table public.provider_availability (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.provider_profiles(user_id) on delete cascade,
  weekday int not null,
  start_time time not null,
  end_time time not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint provider_availability_weekday_range check (weekday between 0 and 6),
  constraint provider_availability_time_order check (end_time > start_time),
  constraint provider_availability_unique_slot unique (provider_id, weekday)
);

create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  booking_code text not null,
  customer_id uuid not null references public.customer_profiles(user_id) on delete cascade,
  provider_id uuid not null references public.provider_profiles(user_id) on delete restrict,
  service_id uuid not null references public.services(id) on delete restrict,
  location_id uuid references public.locations(id) on delete set null,
  booking_date date not null,
  time_slot_text text not null,
  scheduled_at timestamptz,
  quantity int not null default 1,
  unit_price numeric(10,2) not null,
  total_amount numeric(10,2) not null,
  payment_method public.payment_method not null default 'offline',
  payment_status public.payment_status not null default 'unpaid',
  booking_status public.booking_status not null default 'pending',
  customer_note text,
  provider_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bookings_code_unique unique (booking_code),
  constraint bookings_quantity_positive check (quantity > 0),
  constraint bookings_unit_price_non_negative check (unit_price >= 0),
  constraint bookings_total_non_negative check (total_amount >= 0)
);

create table public.booking_status_history (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  status public.booking_status not null,
  changed_by uuid references public.profiles(id) on delete set null,
  note text,
  created_at timestamptz not null default now()
);

create table public.offers (
  id uuid primary key default gen_random_uuid(),
  provider_id uuid not null references public.provider_profiles(user_id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  title text,
  discount_percent numeric(5,2),
  promo_code text,
  valid_until date not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  constraint offers_discount_range check (discount_percent is null or (discount_percent >= 0 and discount_percent <= 100))
);

create table public.favorites (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references public.customer_profiles(user_id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint favorites_customer_service_unique unique (customer_id, service_id)
);

create table public.reviews (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings(id) on delete cascade,
  customer_id uuid not null references public.customer_profiles(user_id) on delete cascade,
  provider_id uuid not null references public.provider_profiles(user_id) on delete cascade,
  service_id uuid not null references public.services(id) on delete cascade,
  rating int not null,
  comment text,
  created_at timestamptz not null default now(),
  constraint reviews_booking_unique unique (booking_id),
  constraint reviews_rating_range check (rating between 1 and 5)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  type public.notification_type not null,
  title text not null,
  body text not null,
  is_read boolean not null default false,
  related_booking_id uuid references public.bookings(id) on delete cascade,
  related_service_id uuid references public.services(id) on delete cascade,
  created_at timestamptz not null default now()
);

create index profiles_role_idx on public.profiles(role);
create index locations_user_id_idx on public.locations(user_id);
create index service_categories_parent_group_idx on public.service_categories(parent_group);
create index services_provider_id_idx on public.services(provider_id);
create index services_category_id_idx on public.services(category_id);
create index provider_availability_provider_id_idx on public.provider_availability(provider_id);
create index bookings_customer_id_idx on public.bookings(customer_id);
create index bookings_provider_id_idx on public.bookings(provider_id);
create index bookings_service_id_idx on public.bookings(service_id);
create index bookings_status_idx on public.bookings(booking_status);
create index bookings_date_idx on public.bookings(booking_date);
create index booking_status_history_booking_id_idx on public.booking_status_history(booking_id);
create index offers_provider_id_idx on public.offers(provider_id);
create index offers_service_id_idx on public.offers(service_id);
create index offers_valid_until_idx on public.offers(valid_until);
create index favorites_customer_id_idx on public.favorites(customer_id);
create index favorites_service_id_idx on public.favorites(service_id);
create index reviews_provider_id_idx on public.reviews(provider_id);
create index reviews_service_id_idx on public.reviews(service_id);
create index notifications_user_id_idx on public.notifications(user_id);
create index notifications_type_idx on public.notifications(type);
create index notifications_is_read_idx on public.notifications(is_read);

create trigger set_profiles_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create trigger set_customer_profiles_updated_at
before update on public.customer_profiles
for each row execute function public.set_updated_at();

create trigger set_provider_profiles_updated_at
before update on public.provider_profiles
for each row execute function public.set_updated_at();

create trigger set_services_updated_at
before update on public.services
for each row execute function public.set_updated_at();

create trigger set_bookings_updated_at
before update on public.bookings
for each row execute function public.set_updated_at();

create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'service-media',
  'service-media',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = excluded.public,
    file_size_limit = excluded.file_size_limit,
    allowed_mime_types = excluded.allowed_mime_types;

create policy "Service media public read"
on storage.objects for select
using (bucket_id = 'service-media');

create policy "Authenticated users can upload service media"
on storage.objects for insert
to authenticated
with check (bucket_id = 'service-media');

create policy "Owners can update service media"
on storage.objects for update
to authenticated
using (bucket_id = 'service-media' and owner = auth.uid())
with check (bucket_id = 'service-media' and owner = auth.uid());

create policy "Owners can delete service media"
on storage.objects for delete
to authenticated
using (bucket_id = 'service-media' and owner = auth.uid());

insert into public.service_categories (name, slug, parent_group, icon_name, sort_order)
values
  ('AC Repair', 'ac-repair', 'Appliance Repair', 'ac_unit_rounded', 1),
  ('Refrigerator', 'refrigerator', 'Appliance Repair', 'kitchen_rounded', 2),
  ('TV Repair', 'tv-repair', 'Appliance Repair', 'tv_rounded', 3),
  ('Microwave', 'microwave', 'Appliance Repair', 'microwave_rounded', 4),
  ('Washing Machine', 'washing-machine', 'Appliance Repair', 'local_laundry_service_rounded', 5),
  ('Water Purifier', 'water-purifier', 'Appliance Repair', 'water_drop_rounded', 6),
  ('Plumber', 'plumber', 'Home Maintenance', 'plumbing_rounded', 7),
  ('Electrician', 'electrician', 'Home Maintenance', 'electrical_services_rounded', 8),
  ('Carpenter', 'carpenter', 'Home Maintenance', 'handyman_rounded', 9),
  ('Painter', 'painter', 'Home Maintenance', 'format_paint_rounded', 10),
  ('Full Home', 'full-home', 'Cleaning & Pest Control', 'cleaning_services_rounded', 11),
  ('Sofa Clean', 'sofa-clean', 'Cleaning & Pest Control', 'chair_rounded', 12),
  ('Bathroom', 'bathroom', 'Cleaning & Pest Control', 'bathtub_rounded', 13),
  ('Pest Control', 'pest-control', 'Cleaning & Pest Control', 'pest_control_rounded', 14),
  ('AC Servicing', 'ac-servicing', 'Appliance Repair', 'ac_unit_rounded', 15),
  ('Cleaning', 'cleaning', 'Cleaning & Pest Control', 'cleaning_services_rounded', 16),
  ('Electronics', 'electronics', 'Appliance Repair', 'electrical_services_rounded', 17),
  ('Electronics Service', 'electronics-service', 'Appliance Repair', 'electrical_services_rounded', 18),
  ('Fan & Light Service', 'fan-light-service', 'Home Maintenance', 'lightbulb_rounded', 19),
  ('Fridge Servicing', 'fridge-servicing', 'Appliance Repair', 'kitchen_rounded', 20),
  ('Painting', 'painting', 'Home Maintenance', 'format_paint_rounded', 21),
  ('Water Filter Servicing', 'water-filter-servicing', 'Appliance Repair', 'water_drop_rounded', 22),
  ('House Cleaning', 'house-cleaning', 'Cleaning & Pest Control', 'cleaning_services_rounded', 23),
  ('Home Sanitization', 'home-sanitization', 'Cleaning & Pest Control', 'sanitizer_rounded', 24),
  ('Laundry Service', 'laundry-service', 'Cleaning & Pest Control', 'local_laundry_service_rounded', 25)
on conflict (slug) do nothing;
