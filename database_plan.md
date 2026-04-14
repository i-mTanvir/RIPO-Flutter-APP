# Database Plan for Supabase

## Goal
Build a clean first database plan for the current Flutter UI. The app clearly has 3 roles:

- Admin
- Customer
- Provider

The UI also already implies these main modules:

- Auth and profile
- Provider business profile
- Service categories and services
- Booking and schedule
- Offers and promo
- Favorites
- Chat
- Notifications
- Payments / wallet / payouts
- Reviews
- Location for everyone

## Recommended Table Count
For a relevant first version, use **14 tables**.

Core:

1. `profiles`
2. `customer_profiles`
3. `provider_profiles`
4. `locations`
5. `service_categories`
6. `services`
7. `service_media`
8. `provider_availability`
9. `bookings`
10. `booking_status_history`
11. `offers`
12. `favorites`
13. `reviews`
14. `notifications`

Phase 2 if needed:

- `messages`
- `wallet_transactions`
- `payouts`
- `admin_actions`
- `promo_codes`

## Main Relationships
- One Supabase auth user -> one `profiles` row
- One `profiles` row -> optional one `customer_profiles` row
- One `profiles` row -> optional one `provider_profiles` row
- One `profiles` row -> many `locations`
- One `service_categories` row -> many `services`
- One provider -> many `services`
- One provider -> many `provider_availability`
- One customer -> many `bookings`
- One provider -> many `bookings`
- One booking -> many `booking_status_history`
- One service -> many `offers`
- One customer -> many `favorites`
- One booking -> one review max
- One user -> many `notifications`

## Table Plan

### 1. `profiles`
Base account table for all roles. Link this with `auth.users.id`.

Columns:

- `id uuid primary key` references auth user id
- `role text` check in (`admin`, `customer`, `provider`)
- `full_name text`
- `email text`
- `phone text`
- `avatar_url text`
- `gender text null`
- `is_active boolean default true`
- `created_at timestamptz default now()`
- `updated_at timestamptz default now()`

### 2. `customer_profiles`
Customer-specific data.

Columns:

- `user_id uuid primary key` references `profiles.id`
- `default_location_id uuid null`
- `date_of_birth date null`
- `notes text null`
- `created_at timestamptz`
- `updated_at timestamptz`

### 3. `provider_profiles`
Provider business and verification data from the provider UI.

Columns:

- `user_id uuid primary key` references `profiles.id`
- `business_name text`
- `owner_name text`
- `business_email text`
- `business_phone text`
- `business_address text`
- `bio text`
- `experience_years int null`
- `trade_license_number text null`
- `nid_number text null`
- `verification_status text` check in (`pending`, `verified`, `rejected`, `suspended`)
- `service_area_text text null`
- `rating_avg numeric(3,2) default 0`
- `review_count int default 0`
- `joined_at timestamptz default now()`
- `updated_at timestamptz`

### 4. `locations`
Reusable location table for customer and provider. This is needed because location is visible in multiple screens.

Columns:

- `id uuid primary key`
- `user_id uuid` references `profiles.id`
- `label text` like `Home`, `Office`, `Business`
- `address_line text`
- `area text`
- `city text`
- `district text null`
- `postal_code text null`
- `latitude numeric null`
- `longitude numeric null`
- `is_default boolean default false`
- `created_at timestamptz default now()`

### 5. `service_categories`
Admin-controlled categories.

Columns:

- `id uuid primary key`
- `name text unique`
- `slug text unique`
- `parent_group text`
- `icon_name text null`
- `is_active boolean default true`
- `sort_order int default 0`
- `created_at timestamptz default now()`

Suggested groups from current UI:

- `Appliance Repair`
- `Home Maintenance`
- `Cleaning & Pest Control`

### 6. `services`
Provider-published services.

Columns:

- `id uuid primary key`
- `provider_id uuid` references `provider_profiles.user_id`
- `category_id uuid` references `service_categories.id`
- `name text`
- `description text`
- `variations text null`
- `faqs text null`
- `duration_text text null`
- `regular_price numeric(10,2)`
- `offer_price numeric(10,2) null`
- `currency text default 'BDT'`
- `is_active boolean default true`
- `created_at timestamptz default now()`
- `updated_at timestamptz`

### 7. `service_media`
For service images. The UI supports multiple images and a cover image.

Columns:

- `id uuid primary key`
- `service_id uuid` references `services.id`
- `file_url text`
- `is_cover boolean default false`
- `sort_order int default 0`
- `created_at timestamptz default now()`

### 8. `provider_availability`
Stores provider weekly schedule.

Columns:

- `id uuid primary key`
- `provider_id uuid` references `provider_profiles.user_id`
- `weekday int` use 0-6 or 1-7 consistently
- `start_time time`
- `end_time time`
- `is_active boolean default true`
- `created_at timestamptz default now()`

### 9. `bookings`
Most important operational table.

Columns:

- `id uuid primary key`
- `booking_code text unique`
- `customer_id uuid` references `customer_profiles.user_id`
- `provider_id uuid` references `provider_profiles.user_id`
- `service_id uuid` references `services.id`
- `location_id uuid` references `locations.id`
- `booking_date date`
- `time_slot_text text`
- `scheduled_at timestamptz null`
- `quantity int default 1`
- `unit_price numeric(10,2)`
- `total_amount numeric(10,2)`
- `payment_method text` check in (`cash`, `online`, `wallet`, `offline`)
- `payment_status text` check in (`unpaid`, `paid`, `refunded`, `partial`)
- `booking_status text` check in (`pending`, `accepted`, `in_progress`, `completed`, `rejected`, `cancelled`)
- `customer_note text null`
- `provider_note text null`
- `created_at timestamptz default now()`
- `updated_at timestamptz`

### 10. `booking_status_history`
Tracks booking progress timeline.

Columns:

- `id uuid primary key`
- `booking_id uuid` references `bookings.id`
- `status text`
- `changed_by uuid` references `profiles.id`
- `note text null`
- `created_at timestamptz default now()`

### 11. `offers`
Provider offers and admin-visible offers.

Columns:

- `id uuid primary key`
- `provider_id uuid` references `provider_profiles.user_id`
- `service_id uuid` references `services.id`
- `title text null`
- `discount_percent numeric(5,2) null`
- `promo_code text null`
- `valid_until date`
- `is_active boolean default true`
- `created_at timestamptz default now()`

### 12. `favorites`
Customer saved services.

Columns:

- `id uuid primary key`
- `customer_id uuid` references `customer_profiles.user_id`
- `service_id uuid` references `services.id`
- `created_at timestamptz default now()`

Constraint:

- unique (`customer_id`, `service_id`)

### 13. `reviews`
Customer review for a completed booking.

Columns:

- `id uuid primary key`
- `booking_id uuid unique` references `bookings.id`
- `customer_id uuid` references `customer_profiles.user_id`
- `provider_id uuid` references `provider_profiles.user_id`
- `service_id uuid` references `services.id`
- `rating int` check (`rating` between 1 and 5)
- `comment text null`
- `created_at timestamptz default now()`

### 14. `notifications`
User-specific notifications for booking, offer, and system alerts.

Columns:

- `id uuid primary key`
- `user_id uuid` references `profiles.id`
- `type text` check in (`booking`, `offer`, `system`, `promo`)
- `title text`
- `body text`
- `is_read boolean default false`
- `related_booking_id uuid null`
- `related_service_id uuid null`
- `created_at timestamptz default now()`

## UI-Driven Options Found in Current Project
These came directly from the screens and should shape enums, seed data, or admin settings.

### Roles
- `admin`
- `customer`
- `provider`

### Booking statuses
- `pending`
- `accepted`
- `in_progress`
- `completed`
- `rejected`
- `cancelled`

### Payment statuses
- `unpaid`
- `paid`
- `refunded`
- `partial`

### Notification types
- `booking`
- `offer`
- `system`
- `promo`

### Search/sort options
- `Recommended`
- `Price (Low to High)`
- `Price (High to Low)`
- `Rating (High to Low)`

### Service/category names found in UI
- `AC Servicing`
- `AC Repair`
- `Refrigerator`
- `TV Repair`
- `Microwave`
- `Washing Machine`
- `Water Purifier`
- `Plumber`
- `Electrician`
- `Carpenter`
- `Painter`
- `Full Home`
- `Sofa Clean`
- `Bathroom`
- `Pest Control`
- `Cleaning`
- `Electronics`
- `Electronics Service`
- `Fan & Light Service`
- `Fridge Servicing`
- `Painting`
- `Water Filter Servicing`
- `House Cleaning`
- `Home Sanitization`
- `Laundry Service`

## Supabase Notes
- Use `auth.users` for authentication.
- Keep `profiles.id = auth.users.id`.
- Add Row Level Security from day 1.
- Customers should only access their own profile, bookings, favorites, reviews, and notifications.
- Providers should only access their own profile, services, schedule, offers, bookings assigned to them, and their reviews summary.
- Admin access should be via role check on `profiles.role = 'admin'`.

## Best MVP Order
Build in this order:

1. `profiles`, `customer_profiles`, `provider_profiles`, `locations`
2. `service_categories`, `services`, `service_media`
3. `provider_availability`
4. `bookings`, `booking_status_history`
5. `favorites`, `reviews`, `notifications`
6. `offers`
7. Phase 2 tables for chat, wallet, payout, and admin logs

## Recommendation
For your current UI, **start with 10 core tables first**:

- `profiles`
- `customer_profiles`
- `provider_profiles`
- `locations`
- `service_categories`
- `services`
- `provider_availability`
- `bookings`
- `reviews`
- `notifications`

Then add `offers`, `favorites`, `service_media`, and `booking_status_history`.

This keeps the first Supabase integration manageable while still matching the real app screens.
