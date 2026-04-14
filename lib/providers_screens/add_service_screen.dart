import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ripo/core/app_snackbar.dart';
import 'package:ripo/core/provider_service_service.dart';
import 'package:ripo/core/provider_location_service.dart';
import 'package:ripo/customers_screens/location_picker_bottom_sheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key, this.serviceData});

  final Map<String, dynamic>? serviceData;

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _regularPriceController = TextEditingController();
  final _offerPriceController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _variationsController = TextEditingController();
  final _faqsController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isSaving = false;
  bool _isLoadingCategories = true;
  bool _isLoadingProviderLocation = true;
  String? _selectedCategoryId;
  String? _providerLocationId;
  String _providerLocationText = 'Location not set';
  double? _providerLatitude;
  double? _providerLongitude;
  List<ProviderCategoryOption> _categories = const [];
  final List<_SelectedServiceImage> _images = [];

  bool get _isEditing => widget.serviceData != null;

  // ✅ FIX 1: Synchronous pop — no deferred callbacks that trigger
  //    mouse_tracker updates on a half-navigated widget tree.
  void _popScreen<T extends Object?>([T? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  void initState() {
    super.initState();
    _populateInitialValues();
    _loadCategories();
    _loadProviderLocation();
  }

  void _populateInitialValues() {
    final data = widget.serviceData;
    if (data == null) return;

    _nameController.text = (data['name'] as String?) ?? '';
    _regularPriceController.text = _decimalText(
        (data['regularPrice'] ?? data['originalPrice']) as Object?);
    _offerPriceController.text =
        _decimalText(data['offerPrice'] ?? data['price']);
    _durationController.text =
        (data['durationText'] ?? data['duration'] ?? '') as String;
    _descriptionController.text = (data['description'] as String?) ?? '';
    _variationsController.text = (data['variations'] as String?) ?? '';
    _faqsController.text = (data['faqs'] as String?) ?? '';
    _providerLocationId = (data['serviceLocationId'] as String?)?.trim();
    _providerLocationText = (data['serviceLocationText'] as String?)?.trim() ??
        _providerLocationText;
    _providerLatitude = (data['serviceLatitude'] as num?)?.toDouble();
    _providerLongitude = (data['serviceLongitude'] as num?)?.toDouble();

    for (final url in _extractMediaUrls(data)) {
      _images.add(_SelectedServiceImage.remote(url));
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ProviderServiceService.fetchCategories();
      if (!mounted) return;

      final initialCategoryId = widget.serviceData?['categoryId'] as String?;
      final initialCategoryName = (widget.serviceData?['categoryName'] ??
          widget.serviceData?['category']) as String?;

      String? selectedId = initialCategoryId;
      if (selectedId == null && initialCategoryName != null) {
        for (final category in categories) {
          if (category.name == initialCategoryName) {
            selectedId = category.id;
            break;
          }
        }
      }
      selectedId ??= categories.isNotEmpty ? categories.first.id : null;

      setState(() {
        _categories = categories;
        _selectedCategoryId = selectedId;
        _isLoadingCategories = false;
      });
    } on PostgrestException catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(error.message, isError: true);
      setState(() => _isLoadingCategories = false);
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar('Could not load service categories.',
          isError: true);
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadProviderLocation() async {
    try {
      final saved = await ProviderLocationService.getDefaultLocation();
      if (!mounted) return;

      setState(() {
        if (saved != null) {
          _providerLocationId ??= saved.locationId;
          _providerLocationText = _providerLocationText == 'Location not set'
              ? saved.address
              : _providerLocationText;
          _providerLatitude ??= saved.latitude;
          _providerLongitude ??= saved.longitude;
        }
        _isLoadingProviderLocation = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingProviderLocation = false);
    }
  }

  Future<void> _editProviderLocation() async {
    final picked = await LocationPickerBottomSheet.show(
      context,
      initialLatitude: _providerLatitude,
      initialLongitude: _providerLongitude,
      initialAddress: _providerLocationText,
    );
    if (!mounted || picked == null) return;

    try {
      final locationId = await ProviderLocationService.setDefaultLocation(
        latitude: picked.latitude,
        longitude: picked.longitude,
        address: picked.address,
      );

      if (!mounted) return;
      setState(() {
        _providerLocationId = locationId;
        _providerLocationText = picked.address;
        _providerLatitude = picked.latitude;
        _providerLongitude = picked.longitude;
      });
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar('Could not update provider location.',
          isError: true);
    }
  }

  Future<void> _pickImages() async {
    final remaining = 5 - _images.length;
    if (remaining <= 0) {
      context.showAppSnackBar('You can add up to 5 images only.',
          isError: true);
      return;
    }

    try {
      final List<XFile> picked;
      if (kIsWeb) {
        final file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        picked = file == null ? [] : [file];
      } else {
        picked = await _imagePicker.pickMultiImage(
          limit: remaining,
          imageQuality: 85,
        );
      }

      if (picked.isEmpty || !mounted) return;

      final newItems = <_SelectedServiceImage>[];
      for (final file in picked.take(remaining)) {
        final uploadImage = await ServiceUploadImage.fromXFile(file);
        newItems.add(
          _SelectedServiceImage.local(
            fileName: uploadImage.fileName,
            bytes: uploadImage.bytes,
            contentType: uploadImage.contentType,
          ),
        );
      }

      if (!mounted) return;
      setState(() => _images.addAll(newItems));
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar('Could not pick image. Please try again.',
          isError: true);
    }
  }

  void _removeImage(_SelectedServiceImage image) {
    setState(() => _images.remove(image));
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      context.showAppSnackBar('Select a category.', isError: true);
      return;
    }

    if (_images.isEmpty) {
      context.showAppSnackBar('Add at least one service image.', isError: true);
      return;
    }
    if (_providerLocationId == null ||
        _providerLocationId!.isEmpty ||
        _providerLatitude == null ||
        _providerLongitude == null) {
      context.showAppSnackBar(
          'Set provider location before publishing service.',
          isError: true);
      return;
    }

    final regularPrice = double.tryParse(_regularPriceController.text.trim());
    final offerText = _offerPriceController.text.trim();
    final offerPrice = offerText.isEmpty ? null : double.tryParse(offerText);

    if (regularPrice == null || regularPrice <= 0) {
      context.showAppSnackBar('Enter a valid regular price.', isError: true);
      return;
    }
    if (offerText.isNotEmpty && (offerPrice == null || offerPrice < 0)) {
      context.showAppSnackBar('Enter a valid offer price.', isError: true);
      return;
    }
    if (offerPrice != null && offerPrice > regularPrice) {
      context.showAppSnackBar(
          'Offer price cannot be greater than regular price.',
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ProviderServiceService.saveService(
        ProviderServiceInput(
          serviceId: widget.serviceData?['id'] as String?,
          name: _nameController.text.trim(),
          categoryId: _selectedCategoryId!,
          regularPrice: regularPrice,
          offerPrice: offerPrice,
          durationText: _durationController.text.trim(),
          serviceLocationId: _providerLocationId!,
          serviceLocationText: _providerLocationText,
          serviceLatitude: _providerLatitude!,
          serviceLongitude: _providerLongitude!,
          description: _descriptionController.text.trim(),
          variations: _variationsController.text.trim(),
          faqs: _faqsController.text.trim(),
          existingImageUrls:
              _images.where((i) => i.isRemote).map((i) => i.url!).toList(),
          newImages: _images
              .where((i) => !i.isRemote)
              .map((i) => ServiceUploadImage(
                    fileName: i.fileName!,
                    bytes: i.bytes!,
                    contentType: i.contentType!,
                  ))
              .toList(),
        ),
      );

      if (!mounted) return;
      // ✅ FIX 2: Reset _isSaving BEFORE popping so the widget is in a
      //    clean state when Flutter tears it down. No overlay / AbsorbPointer
      //    is active during the navigation transition.
      setState(() => _isSaving = false);
      _popScreen(true);
    } on StorageException catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(error.message, isError: true);
      setState(() => _isSaving = false);
    } on PostgrestException catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(error.message, isError: true);
      setState(() => _isSaving = false);
    } on AuthException catch (error) {
      if (!mounted) return;
      context.showAppSnackBar(error.message, isError: true);
      setState(() => _isSaving = false);
    } catch (_) {
      if (!mounted) return;
      context.showAppSnackBar('Could not save service.', isError: true);
      setState(() => _isSaving = false);
    }
    // ✅ No finally needed — every path above handles _isSaving explicitly.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regularPriceController.dispose();
    _offerPriceController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _variationsController.dispose();
    _faqsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSaving,
      child: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isSaving,
            child: Scaffold(
              backgroundColor: const Color(0xFFF4F4F8),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.black87),
                title: Text(
                  _isEditing ? 'Edit Service' : 'Add New Service',
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
                      const Text(
                        'Service Media',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _images.length + 1,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (_, index) {
                            if (index == 0) return _buildAddPhotoCard();
                            return _buildImageCard(
                                _images[index - 1], index - 1);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You can add up to 5 images. First image will be the cover.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _nameController,
                        label: 'Service Name',
                        hint: 'e.g., Deep House Cleaning',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Service name is required.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCategoryDropdown(),
                      const SizedBox(height: 24),
                      const Text(
                        'Pricing & Duration',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              controller: _regularPriceController,
                              label: 'Regular Price (BDT)',
                              hint: 'e.g., 600',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInputField(
                              controller: _offerPriceController,
                              label: 'Offer Price (BDT)',
                              hint: 'e.g., 500',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _durationController,
                        label: 'Service Duration',
                        hint: 'e.g., 30-45 mins',
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Provide Details',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        controller: _descriptionController,
                        label: 'Service Description',
                        hint: 'Overview of what is included in this service...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _variationsController,
                        label: 'Service Variations',
                        hint:
                            'e.g. Standard AC Maintenance\nDeep Chemical Cleaning',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildInputField(
                        controller: _faqsController,
                        label: 'Frequently Asked Questions (FAQs)',
                        hint:
                            'e.g. Q: How long does it take?\nA: Typically 30-45 mins.',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      _buildProviderLocationCard(),
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
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed:
                        _isSaving || _isLoadingCategories ? null : _saveService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6950F4),
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      _isSaving
                          ? 'Saving...'
                          : _isEditing
                              ? 'Save Changes'
                              : 'Publish Service',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isSaving)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddPhotoCard() {
    return GestureDetector(
      onTap: _isSaving ? null : _pickImages,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF0EEFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: CustomPaint(
                // ✅ FIX 3: Now actually draws a dashed border
                painter: _DashedRectPainter(
                  color: const Color(0xFF6950F4).withValues(alpha: 0.5),
                ),
              ),
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded,
                    color: Color(0xFF6950F4), size: 32),
                SizedBox(height: 8),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6950F4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(_SelectedServiceImage image, int index) {
    return Container(
      width: 120,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image.isRemote
              ? Image.network(image.url!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder())
              : Image.memory(image.bytes!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildImagePlaceholder()),
          if (index == 0)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Cover',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () => _removeImage(image),
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.white,
      child: const Icon(Icons.image_outlined, color: Colors.black26, size: 32),
    );
  }

  Widget _buildCategoryDropdown() {
    if (_isLoadingCategories) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.black54),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          onChanged: (value) => setState(() => _selectedCategoryId = value),
          items: _categories
              .map((c) =>
                  DropdownMenuItem<String>(value: c.id, child: Text(c.name)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildProviderLocationCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Provider Location',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: _isSaving ? null : _editProviderLocation,
                tooltip: 'Edit provider location',
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: Color(0xFF6950F4),
                ),
              ),
            ],
          ),
          if (_isLoadingProviderLocation)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(minHeight: 2),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _providerLocationText,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38),
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

  String _decimalText(Object? value) {
    if (value == null) return '';
    if (value is num) {
      return value % 1 == 0 ? value.toInt().toString() : value.toString();
    }
    return value.toString();
  }

  List<String> _extractMediaUrls(Map<String, dynamic> data) {
    final dynamic raw = data['mediaUrls'] ?? data['media_urls'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    final image = data['image'];
    if (image is String && image.startsWith('http')) return [image];
    return const [];
  }
}

// ─────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────

class _SelectedServiceImage {
  const _SelectedServiceImage._({
    required this.isRemote,
    this.url,
    this.fileName,
    this.bytes,
    this.contentType,
  });

  factory _SelectedServiceImage.remote(String url) =>
      _SelectedServiceImage._(isRemote: true, url: url);

  factory _SelectedServiceImage.local({
    required String fileName,
    required Uint8List bytes,
    required String contentType,
  }) =>
      _SelectedServiceImage._(
        isRemote: false,
        fileName: fileName,
        bytes: bytes,
        contentType: contentType,
      );

  final bool isRemote;
  final String? url;
  final String? fileName;
  final Uint8List? bytes;
  final String? contentType;
}

// ─────────────────────────────────────────────
// ✅ FIX 3: Proper dashed border painter
// ─────────────────────────────────────────────

class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    const dashWidth = 6.0;
    const dashGap = 4.0;
    const radius = 16.0;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter old) => old.color != color;
}
