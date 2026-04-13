import 'package:flutter/material.dart';

class AddServiceScreen extends StatefulWidget {
  final Map<String, dynamic>? serviceData;
  const AddServiceScreen({super.key, this.serviceData});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory = 'AC Servicing';

  final List<String> _categories = [
    'AC Servicing',
    'AC Repair',
    'Cleaning',
    'Electronics',
    'Electronics Service',
    'Fan & Light Service',
    'Fridge Servicing',
    'Painting',
    'TV Repair',
    'Water Filter Servicing',
    'Plumbing',
    'House Cleaning'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.serviceData != null) {
      if (_categories.contains(widget.serviceData!['category'])) {
        _selectedCategory = widget.serviceData!['category'];
      }
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
        title: Text(
          widget.serviceData != null ? 'Edit Service' : 'Add New Service',
          style: const TextStyle(
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
              // ── Image Upload ──
              const Text('Service Media', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Mock Upload Button
                    Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0EEFF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF6950F4).withValues(alpha: 0.3),
                          width: 2,
                          style: BorderStyle.none,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _DashedRectPainter(color: const Color(0xFF6950F4).withValues(alpha: 0.5)),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF6950F4), size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF6950F4)),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Mock Image 1
                    Container(
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: AssetImage('lib/media/AC_servicing.png'), // Mock uploaded image
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black54,
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('You can add up to 5 images. First image will be the cover.', style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 24),

              // ── Basic Info ──
              const Text('Basic Information', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 16),
              
              _buildInputField(
                label: 'Service Name', 
                hint: 'e.g., Deep House Cleaning',
                initialValue: widget.serviceData?['name'],
              ),
              const SizedBox(height: 16),

              const Text('Category', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
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
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
                    onChanged: (String? newValue) {
                      setState(() {
                        if(newValue != null) _selectedCategory = newValue;
                      });
                    },
                    items: _categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Pricing ──
              const Text('Pricing & Duration', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 16),
              Row(
                children: [
                   Expanded(child: _buildInputField(
                     label: 'Regular Price (৳)', hint: 'e.g., 600', keyboardType: TextInputType.number,
                     initialValue: widget.serviceData?['originalPrice']?.toString(),
                   )),
                   const SizedBox(width: 16),
                   Expanded(child: _buildInputField(
                     label: 'Offer Price (৳)', hint: 'e.g., 500', keyboardType: TextInputType.number,
                     initialValue: widget.serviceData?['price']?.toString(),
                   )),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Service Duration (Mins)', hint: 'e.g., 30-45 mins', keyboardType: TextInputType.text,
                initialValue: widget.serviceData?['duration'],
              ),
              const SizedBox(height: 24),

              // ── Description & Details ──
              const Text('Provide Details', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black87)),
              const SizedBox(height: 16),
              _buildInputField(
                label: 'Service Description',
                hint: 'Overview of what is included in this service...',
                maxLines: 4,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Service Variations',
                hint: 'e.g. Standard AC Maintenance\nDeep Chemical Cleaning\n(Add each on a new line)',
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                label: 'Frequently Asked Questions (FAQs)',
                hint: 'e.g. Q: How long does it take?\nA: Typically 30-45 mins.\n(Add Q&A per line)',
                maxLines: 4,
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
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
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
              backgroundColor: const Color(0xFF6950F4),
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              widget.serviceData != null ? 'Save Changes' : 'Publish Service',
              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    String? initialValue,
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
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
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

// Custom Painter for dashed border
class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    // Simplistic dashed border drawing for a rounded rect is complex manually.
    // Instead, using a basic rectangular dashed outline for visual placeholder.
    // In a real app, use the `dotted_border` package.
    final RRect rect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16));
    
    // Hack: Draw a solid border for demonstration since standard flutter doesn't have dashed RRect yet
    canvas.drawRRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
