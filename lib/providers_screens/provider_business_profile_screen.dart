// lib\providers_screens\provider_business_profile_screen.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderBusinessProfileScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProviderBusinessProfileScreen({super.key, required this.onBack});

  @override
  State<ProviderBusinessProfileScreen> createState() =>
      _ProviderBusinessProfileScreenState();
}

class _ProviderBusinessProfileScreenState
    extends State<ProviderBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _bioController = TextEditingController();
  final _tradeLicenseController = TextEditingController();
  final _nidController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  Uint8List? _selectedAvatarBytes;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _tradeLicenseController.dispose();
    _nidController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      final results = await Future.wait([
        client
            .from('provider_profiles')
            .select(
              'business_name, owner_name, business_email, business_phone, '
              'experience_years, business_address, bio, trade_license_number, '
              'nid_number',
            )
            .eq('user_id', userId)
            .maybeSingle(),
        client
            .from('profiles')
            .select('email, phone, avatar_url')
            .eq('id', userId)
            .maybeSingle(),
      ]);

      final provider = results[0];
      final profile = results[1];

      _businessNameController.text =
          (provider?['business_name'] as String?)?.trim() ?? '';
      _ownerNameController.text =
          (provider?['owner_name'] as String?)?.trim() ?? '';
      _phoneController.text =
          (provider?['business_phone'] as String?)?.trim() ??
              (profile?['phone'] as String?)?.trim() ??
              '';
      _experienceController.text =
          (provider?['experience_years'] as int?)?.toString() ?? '';
      _emailController.text =
          (provider?['business_email'] as String?)?.trim() ??
              (profile?['email'] as String?)?.trim() ??
              '';
      _addressController.text =
          (provider?['business_address'] as String?)?.trim() ?? '';
      _bioController.text = (provider?['bio'] as String?)?.trim() ?? '';
      _tradeLicenseController.text =
          (provider?['trade_license_number'] as String?)?.trim() ?? '';
      _nidController.text = (provider?['nid_number'] as String?)?.trim() ?? '';
      _avatarUrl = (profile?['avatar_url'] as String?)?.trim() ?? '';
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not load business profile data.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfileData() async {
    if (_isSaving) return;

    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);
    try {
      final experienceText = _experienceController.text.trim();
      final experienceYears =
          experienceText.isEmpty ? null : int.tryParse(experienceText);

      await client.from('provider_profiles').upsert({
        'user_id': userId,
        'business_name': _businessNameController.text.trim().isEmpty
            ? null
            : _businessNameController.text.trim(),
        'owner_name': _ownerNameController.text.trim().isEmpty
            ? null
            : _ownerNameController.text.trim(),
        'business_phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'business_email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'experience_years': experienceYears,
        'business_address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'bio': _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
        'trade_license_number': _tradeLicenseController.text.trim().isEmpty
            ? null
            : _tradeLicenseController.text.trim(),
        'nid_number': _nidController.text.trim().isEmpty
            ? null
            : _nidController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await client.from('profiles').update({
        'full_name': _ownerNameController.text.trim().isEmpty
            ? null
            : _ownerNameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'avatar_url': _avatarUrl.isEmpty ? null : _avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save profile updates.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickAndUploadProfileImage() async {
    if (_isLoading || _isSaving) return;

    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedAvatarBytes = bytes;
      });

      final ext = _fileExtension(picked.name);
      final path =
          '$userId/profile-${DateTime.now().millisecondsSinceEpoch}.$ext';
      final contentType = _contentTypeForExtension(ext);

      await client.storage.from('provider-profile-images').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      final publicUrl =
          client.storage.from('provider-profile-images').getPublicUrl(path);

      if (!mounted) return;
      setState(() {
        _avatarUrl = publicUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image uploaded.')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not upload profile image.')),
        );
      }
    }
  }

  String _fileExtension(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.webp')) return 'webp';
    return 'jpg';
  }

  String _contentTypeForExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
            if (!mounted) return;
            widget.onBack();
          },
          child: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Business Profile',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: CircularProgressIndicator()),
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageUploader(),
                    const SizedBox(height: 24),
                    const Text('Basic Information',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const SizedBox(height: 16),
                    _buildInputField(
                        label: 'Business Name',
                        controller: _businessNameController),
                    const SizedBox(height: 16),
                    _buildInputField(
                        label: 'Owner Name', controller: _ownerNameController),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Phone Number',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            label: 'Experience (Years)',
                            controller: _experienceController,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Email Address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    const Text('Business Details',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Business Address',
                      controller: _addressController,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Bio / About the Company',
                      controller: _bioController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    const Text('Verification & Legal',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87)),
                    const SizedBox(height: 16),
                    _buildInputField(
                      label: 'Trade License Number (Optional)',
                      controller: _tradeLicenseController,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                        label: 'NID Number', controller: _nidController),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isLoading || _isSaving
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    _saveProfileData();
                  },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: _isLoading || _isSaving
                    ? const Color(0xFF6950F4).withValues(alpha: 0.5)
                    : const Color(0xFF6950F4),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _isSaving ? 'Saving...' : 'Save Profile Updates',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
    final ImageProvider avatarProvider;
    if (_selectedAvatarBytes != null) {
      avatarProvider = MemoryImage(_selectedAvatarBytes!);
    } else if (_avatarUrl.isNotEmpty) {
      avatarProvider = NetworkImage(_avatarUrl);
    } else {
      avatarProvider = const AssetImage('lib/media/clean_house_offer.png');
    }

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6950F4), width: 2),
              color: const Color(0xFFE8F4FD),
              image: DecorationImage(
                image: avatarProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: -4,
            child: GestureDetector(
              onTap: _pickAndUploadProfileImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6950F4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF6950F4), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
