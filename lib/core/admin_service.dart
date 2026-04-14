import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCustomerListItem {
  const AdminCustomerListItem({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;
}

class AdminProviderListItem {
  const AdminProviderListItem({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.verificationStatus,
    required this.isActive,
    required this.joinedAt,
  });

  final String id;
  final String fullName;
  final String businessName;
  final String? ownerName;
  final String? email;
  final String? phone;
  final String verificationStatus;
  final bool isActive;
  final DateTime? joinedAt;

  bool get isVerified => verificationStatus == 'verified';
}

class AdminBookingPreview {
  const AdminBookingPreview({
    required this.serviceName,
    required this.providerName,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  final String serviceName;
  final String providerName;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
}

class AdminCustomerDetailsData {
  const AdminCustomerDetailsData({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.createdAt,
    required this.totalBookings,
    required this.pendingBookings,
    required this.cancelledBookings,
    required this.recentBookings,
  });

  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;
  final int totalBookings;
  final int pendingBookings;
  final int cancelledBookings;
  final List<AdminBookingPreview> recentBookings;
}

class AdminProviderReviewPreview {
  const AdminProviderReviewPreview({
    required this.customerName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  final String customerName;
  final String? comment;
  final int rating;
  final DateTime? createdAt;
}

class AdminProviderDetailsData {
  const AdminProviderDetailsData({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.ownerName,
    required this.email,
    required this.phone,
    required this.verificationStatus,
    required this.isActive,
    required this.joinedAt,
    required this.ratingAvg,
    required this.reviewCount,
    required this.experienceYears,
    required this.bio,
    required this.tradeLicenseNumber,
    required this.nidNumber,
    required this.completedJobs,
    required this.activeGigs,
    required this.recentReviews,
  });

  final String id;
  final String fullName;
  final String businessName;
  final String? ownerName;
  final String? email;
  final String? phone;
  final String verificationStatus;
  final bool isActive;
  final DateTime? joinedAt;
  final double ratingAvg;
  final int reviewCount;
  final int? experienceYears;
  final String? bio;
  final String? tradeLicenseNumber;
  final String? nidNumber;
  final int completedJobs;
  final int activeGigs;
  final List<AdminProviderReviewPreview> recentReviews;

  bool get isVerified => verificationStatus == 'verified';
}

class AdminService {
  AdminService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static Future<List<AdminCustomerListItem>> fetchCustomers() async {
    final response = await _client
        .from('profiles')
        .select('id, full_name, email, phone, is_active, created_at')
        .eq('role', 'customer')
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((row) {
      return AdminCustomerListItem(
        id: row['id'] as String,
        fullName: (row['full_name'] as String?)?.trim().isNotEmpty == true
            ? row['full_name'] as String
            : 'Customer',
        email: _nullableString(row['email']),
        phone: _nullableString(row['phone']),
        isActive: row['is_active'] as bool? ?? false,
        createdAt: _parseDateTime(row['created_at']),
      );
    }).toList();
  }

  static Future<List<AdminProviderListItem>> fetchProviders() async {
    final response = await _client.from('provider_profiles').select('''
          user_id,
          business_name,
          owner_name,
          business_email,
          business_phone,
          verification_status,
          joined_at,
          profiles!inner(full_name, email, phone, is_active, created_at)
        ''').order('joined_at', ascending: false);

    return (response as List<dynamic>).map((row) {
      final profile = row['profiles'] as Map<String, dynamic>? ?? const {};

      return AdminProviderListItem(
        id: row['user_id'] as String,
        fullName: (profile['full_name'] as String?)?.trim().isNotEmpty == true
            ? profile['full_name'] as String
            : 'Provider',
        businessName:
            (row['business_name'] as String?)?.trim().isNotEmpty == true
                ? row['business_name'] as String
                : 'Business',
        ownerName: _nullableString(row['owner_name']),
        email: _nullableString(row['business_email']) ??
            _nullableString(profile['email']),
        phone: _nullableString(row['business_phone']) ??
            _nullableString(profile['phone']),
        verificationStatus:
            _nullableString(row['verification_status']) ?? 'pending',
        isActive: profile['is_active'] as bool? ?? false,
        joinedAt: _parseDateTime(row['joined_at']) ??
            _parseDateTime(profile['created_at']),
      );
    }).toList();
  }

  static Future<AdminCustomerDetailsData> fetchCustomerDetails(
      String userId) async {
    final profile = await _client
        .from('profiles')
        .select('id, full_name, email, phone, is_active, created_at')
        .eq('id', userId)
        .single();

    final bookingsResponse = await _client
        .from('bookings')
        .select(
            'id, service_id, provider_id, total_amount, booking_status, created_at')
        .eq('customer_id', userId)
        .order('created_at', ascending: false);

    final bookings =
        List<Map<String, dynamic>>.from(bookingsResponse as List<dynamic>);

    final serviceIds = bookings
        .map((row) => row['service_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();
    final providerIds = bookings
        .map((row) => row['provider_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final serviceNames = <String, String>{};
    final providerNames = <String, String>{};

    if (serviceIds.isNotEmpty) {
      final servicesResponse = await _client
          .from('services')
          .select('id, name')
          .inFilter('id', serviceIds);

      for (final row in servicesResponse as List<dynamic>) {
        final map = row as Map<String, dynamic>;
        final id = map['id'] as String?;
        final name = map['name'] as String?;
        if (id != null && name != null && name.trim().isNotEmpty) {
          serviceNames[id] = name;
        }
      }
    }

    if (providerIds.isNotEmpty) {
      final providerResponse = await _client
          .from('provider_profiles')
          .select('user_id, business_name')
          .inFilter('user_id', providerIds);

      for (final row in providerResponse as List<dynamic>) {
        final map = row as Map<String, dynamic>;
        final id = map['user_id'] as String?;
        final businessName = map['business_name'] as String?;
        if (id != null &&
            businessName != null &&
            businessName.trim().isNotEmpty) {
          providerNames[id] = businessName;
        }
      }
    }

    final pendingStatuses = {'pending', 'accepted', 'in_progress'};
    final cancelledStatuses = {'cancelled', 'rejected'};

    final pendingBookings = bookings
        .where((row) =>
            pendingStatuses.contains(row['booking_status'] as String? ?? ''))
        .length;
    final cancelledBookings = bookings
        .where((row) =>
            cancelledStatuses.contains(row['booking_status'] as String? ?? ''))
        .length;

    final recentBookings = bookings.take(6).map((row) {
      final serviceId = row['service_id'] as String?;
      final providerId = row['provider_id'] as String?;
      return AdminBookingPreview(
        serviceName: serviceNames[serviceId] ?? 'Service',
        providerName: providerNames[providerId] ?? 'Provider',
        totalAmount: (row['total_amount'] as num?)?.toDouble() ?? 0,
        status: _nullableString(row['booking_status']) ?? 'pending',
        createdAt: _parseDateTime(row['created_at']),
      );
    }).toList();

    return AdminCustomerDetailsData(
      id: profile['id'] as String,
      fullName: (profile['full_name'] as String?)?.trim().isNotEmpty == true
          ? profile['full_name'] as String
          : 'Customer',
      email: _nullableString(profile['email']),
      phone: _nullableString(profile['phone']),
      isActive: profile['is_active'] as bool? ?? false,
      createdAt: _parseDateTime(profile['created_at']),
      totalBookings: bookings.length,
      pendingBookings: pendingBookings,
      cancelledBookings: cancelledBookings,
      recentBookings: recentBookings,
    );
  }

  static Future<AdminProviderDetailsData> fetchProviderDetails(
      String userId) async {
    final provider = await _client.from('provider_profiles').select('''
          user_id,
          business_name,
          owner_name,
          business_email,
          business_phone,
          verification_status,
          rating_avg,
          review_count,
          bio,
          experience_years,
          trade_license_number,
          nid_number,
          joined_at,
          profiles!inner(full_name, email, phone, is_active, created_at)
        ''').eq('user_id', userId).single();

    final profile = provider['profiles'] as Map<String, dynamic>? ?? const {};

    final bookingsResponse = await _client
        .from('bookings')
        .select('booking_status')
        .eq('provider_id', userId);

    final bookingRows =
        List<Map<String, dynamic>>.from(bookingsResponse as List<dynamic>);
    final completedJobs = bookingRows
        .where((row) => (row['booking_status'] as String?) == 'completed')
        .length;
    final activeGigs = bookingRows.where((row) {
      final status = row['booking_status'] as String?;
      return status == 'pending' ||
          status == 'accepted' ||
          status == 'in_progress';
    }).length;

    final reviewsResponse = await _client
        .from('reviews')
        .select('customer_id, rating, comment, created_at')
        .eq('provider_id', userId)
        .order('created_at', ascending: false)
        .limit(5);

    final reviews =
        List<Map<String, dynamic>>.from(reviewsResponse as List<dynamic>);
    final customerIds = reviews
        .map((row) => row['customer_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList();

    final customerNames = <String, String>{};
    if (customerIds.isNotEmpty) {
      final customersResponse = await _client
          .from('profiles')
          .select('id, full_name')
          .inFilter('id', customerIds);

      for (final row in customersResponse as List<dynamic>) {
        final map = row as Map<String, dynamic>;
        final id = map['id'] as String?;
        final fullName = map['full_name'] as String?;
        if (id != null && fullName != null && fullName.trim().isNotEmpty) {
          customerNames[id] = fullName;
        }
      }
    }

    final recentReviews = reviews.map((row) {
      final customerId = row['customer_id'] as String?;
      return AdminProviderReviewPreview(
        customerName: customerNames[customerId] ?? 'Customer',
        comment: _nullableString(row['comment']),
        rating: (row['rating'] as int?) ?? 0,
        createdAt: _parseDateTime(row['created_at']),
      );
    }).toList();

    return AdminProviderDetailsData(
      id: provider['user_id'] as String,
      fullName: (profile['full_name'] as String?)?.trim().isNotEmpty == true
          ? profile['full_name'] as String
          : 'Provider',
      businessName:
          (provider['business_name'] as String?)?.trim().isNotEmpty == true
              ? provider['business_name'] as String
              : 'Business',
      ownerName: _nullableString(provider['owner_name']) ??
          _nullableString(profile['full_name']),
      email: _nullableString(provider['business_email']) ??
          _nullableString(profile['email']),
      phone: _nullableString(provider['business_phone']) ??
          _nullableString(profile['phone']),
      verificationStatus:
          _nullableString(provider['verification_status']) ?? 'pending',
      isActive: profile['is_active'] as bool? ?? false,
      joinedAt: _parseDateTime(provider['joined_at']) ??
          _parseDateTime(profile['created_at']),
      ratingAvg: (provider['rating_avg'] as num?)?.toDouble() ?? 0,
      reviewCount: (provider['review_count'] as int?) ?? 0,
      experienceYears: provider['experience_years'] as int?,
      bio: _nullableString(provider['bio']),
      tradeLicenseNumber: _nullableString(provider['trade_license_number']),
      nidNumber: _nullableString(provider['nid_number']),
      completedJobs: completedJobs,
      activeGigs: activeGigs,
      recentReviews: recentReviews,
    );
  }

  static Future<void> updateProviderVerificationStatus({
    required String userId,
    required bool isVerified,
  }) {
    return _client.from('provider_profiles').update({
      'verification_status': isVerified ? 'verified' : 'pending'
    }).eq('user_id', userId);
  }

  static String? _nullableString(dynamic value) {
    final stringValue = value as String?;
    if (stringValue == null) {
      return null;
    }
    final trimmed = stringValue.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }
}
