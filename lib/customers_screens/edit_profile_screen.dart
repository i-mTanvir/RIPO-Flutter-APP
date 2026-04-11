import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'My Profile', 
          style: TextStyle(
            color: Colors.black87, 
            fontWeight: FontWeight.w600, 
            fontFamily: 'Inter',
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4FD),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12, width: 2),
                    ),
                    child: const Icon(Icons.person, size: 60, color: Colors.black38),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6950F4), // Purple brand
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            _buildField('Full Name', 'Tanvir Mahmud'),
            const SizedBox(height: 20),
            _buildField('Phone Number', '+880 1712 345678'),
            const SizedBox(height: 20),
            _buildField('Email', 'tanvirmahmud78@gmail.com'),
            const SizedBox(height: 20),
            _buildField('Address', 'house 57,Road 25, Block A, Banani'),
            const SizedBox(height: 20),
            _buildField('Gender', 'Male'),
            const SizedBox(height: 30),
            // Change Password specific row
            InkWell(
              onTap: () {
                // Here we would typically show a change password dialog or screen
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.lock_outline_rounded, color: Color(0xFF6950F4), size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontFamily: 'Inter', 
                            fontSize: 15, 
                            fontWeight: FontWeight.w600, 
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black54),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Dummy Success interaction
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: Colors.green,
                  )
                );
                Navigator.pop(context); // Go back after save
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6950F4),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: const Text(
                'Save Changes', 
                style: TextStyle(
                  fontFamily: 'Inter', 
                  fontSize: 16, 
                  color: Colors.white, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter', 
            fontSize: 13, 
            color: Colors.black54, 
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          style: const TextStyle(
            fontFamily: 'Inter', 
            fontSize: 15, 
            fontWeight: FontWeight.w500, 
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            suffixIcon: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6950F4)), // The requested pen symbol
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6950F4), width: 1.5), // Purple focus
            ),
          ),
        ),
      ],
    );
  }
}
