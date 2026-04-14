import 'package:flutter/material.dart';

class CreateOfferScreen extends StatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  State<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends State<CreateOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedService = 'AC Servicing';

  // In a real app, this would be a list of the provider's active services
  final List<String> _myServices = [
    'AC Servicing',
    'TV Repairing Service',
    'Deep House Cleaning',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Create Special Offer',
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
              // Promo Graphic Preview
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF8F00), Color(0xFFFFB300)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x33FF8F00),
                        blurRadius: 12,
                        offset: Offset(0, 6)),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(Icons.local_offer_rounded,
                          size: 140,
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Special Offer',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '00% OFF',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Promo Code: NEWCODE',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text('Offer Details',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              const SizedBox(height: 16),

              const Text('Select Service',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedService,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.black54),
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null) _selectedService = newValue;
                      });
                    },
                    items: _myServices
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                      child: _buildInputField(
                          label: 'Discount (%)',
                          hint: 'e.g., 20',
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildInputField(
                          label: 'Promo Code', hint: 'e.g., SUMMER20')),
                ],
              ),
              const SizedBox(height: 20),

              _buildInputField(
                label: 'Valid Until',
                hint: 'DD/MM/YYYY',
                keyboardType: TextInputType.datetime,
                suffixIcon: Icons.calendar_today_rounded,
              ),

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
          child: ElevatedButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFFF8F00), // Action color for offers
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              'Broadcast Offer',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    IconData? suffixIcon,
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
          keyboardType: keyboardType,
          style: const TextStyle(
              fontFamily: 'Inter', fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: Colors.black38, size: 20)
                : null,
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
                  const BorderSide(color: Color(0xFFFF8F00), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
