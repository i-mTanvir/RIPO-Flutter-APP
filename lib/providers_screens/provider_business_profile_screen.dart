import 'package:flutter/material.dart';

class ProviderBusinessProfileScreen extends StatefulWidget {
  final VoidCallback onBack;
  const ProviderBusinessProfileScreen({super.key, required this.onBack});

  @override
  State<ProviderBusinessProfileScreen> createState() => _ProviderBusinessProfileScreenState();
}

class _ProviderBusinessProfileScreenState extends State<ProviderBusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();

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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageUploader(),
              const SizedBox(height: 24),
              const Text('Basic Information', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildInputField(label: 'Business Name', initialValue: 'Elite Servicing BD'),
              const SizedBox(height: 16),
              _buildInputField(label: 'Owner Name', initialValue: 'Shaidul Islam'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInputField(label: 'Phone Number', initialValue: '+880 1711-223344', keyboardType: TextInputType.phone)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInputField(label: 'Experience', initialValue: '5 Years', keyboardType: TextInputType.text)),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputField(label: 'Email Address', initialValue: 'shaidul@eliteservicing.com', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),

              const Text('Business Details', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Business Address',
                initialValue: 'House 14, Road 3, Sector 7, Uttara, Dhaka',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Bio / About the Company',
                initialValue: 'We are a premium servicing company providing top notch AC, Fridge, and House Cleaning services across Dhaka.',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              const Text('Verification & Legal', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildInputField(label: 'Trade License Number (Optional)', initialValue: 'TL-9843-DHK'),
              const SizedBox(height: 16),
              _buildInputField(label: 'NID Number', initialValue: '1995 8293 8472 8394'),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
               FocusScope.of(context).unfocus();
               if (!mounted) return;
               widget.onBack();
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF6950F4),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Save Profile Updates',
                style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader() {
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
              image: const DecorationImage(
                image: AssetImage('lib/media/clean_house_offer.png'), // Mock profile picture
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6950F4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String initialValue,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              borderSide: const BorderSide(color: Color(0xFF6950F4), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
