import 'package:supabase_flutter/supabase_flutter.dart';

enum AppUserRole { admin, customer, provider }

class AuthResult {
  const AuthResult({
    required this.userRole,
    required this.needsEmailConfirmation,
  });

  final AppUserRole userRole;
  final bool needsEmailConfirmation;
}

class AuthService {
  AuthService._();

  static final SupabaseClient client = Supabase.instance.client;

  static Session? get currentSession => client.auth.currentSession;

  static String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'\s+'), '');
  }

  static Future<AuthResult> signUp({
    required AppUserRole role,
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? gender,
    int? age,
    String? nidNumber,
    String? tradeLicenseNumber,
  }) async {
    try {
      final normalizedPhone = _normalizePhone(phone);

      if (normalizedPhone.isNotEmpty) {
        final existingProfiles = await client
            .from('profiles')
            .select('id')
            .eq('phone', normalizedPhone)
            .limit(1);

        if ((existingProfiles as List).isNotEmpty) {
          throw const AuthException(
            'This phone number is already used by another account.',
          );
        }
      }

      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'role': role.name,
          'full_name': fullName,
          'phone': normalizedPhone.isEmpty ? null : normalizedPhone,
          'gender': gender?.isEmpty ?? true ? null : gender,
          'age': age,
          'nid_number': nidNumber?.isEmpty ?? true ? null : nidNumber,
          'trade_license_number': tradeLicenseNumber?.isEmpty ?? true
              ? null
              : tradeLicenseNumber,
          if (role == AppUserRole.provider) 'business_name': '$fullName Services',
        },
      );

      final user = response.user;
      if (user == null) {
        throw const AuthException('Could not create account.');
      }

      return AuthResult(
        userRole: role,
        needsEmailConfirmation: response.session == null,
      );
    } on AuthException catch (error) {
      if (error.statusCode == '429' ||
          error.message.toLowerCase().contains('rate limit')) {
        throw const AuthException(
          'Too many signup attempts right now. Wait a few minutes and try again, or configure SMTP/email settings in Supabase.',
        );
      }
      if (error.message.toLowerCase().contains('database error saving new user')) {
        throw const AuthException(
          'Could not create this account because one of the profile values already exists. Try a different phone number.',
        );
      }
      rethrow;
    }
  }

  static Future<AppUserRole> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) {
      throw const AuthException('Could not load user after login.');
    }

    final roleValue = user.userMetadata?['role'] as String?;

    if (roleValue != null) {
      return AppUserRole.values.firstWhere(
        (role) => role.name == roleValue,
        orElse: () => AppUserRole.customer,
      );
    }

    final profile = await client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    final dbRole = profile['role'] as String? ?? AppUserRole.customer.name;
    return AppUserRole.values.firstWhere(
      (role) => role.name == dbRole,
      orElse: () => AppUserRole.customer,
    );
  }

  static Future<void> resetPassword(String email) {
    return client.auth.resetPasswordForEmail(email);
  }
}
