import 'package:flutter/material.dart';
import 'package:ripo/core/app_snackbar.dart';
import 'package:ripo/core/provider_service_service.dart';
import 'package:ripo/providers_screens/add_service_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({super.key});

  @override
  State<ProviderServicesScreen> createState() => _ProviderServicesScreenState();
}

class _ProviderServicesScreenState extends State<ProviderServicesScreen> {
  bool _isLoading = true;
  List<ProviderServiceRecord> _services = const [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final services = await ProviderServiceService.fetchProviderServices();
      if (!mounted) {
        return;
      }
      setState(() {
        _services = services;
        _isLoading = false;
      });
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }
      context.showAppSnackBar(error.message, isError: true);
      setState(() => _isLoading = false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showAppSnackBar('Could not load provider services.',
          isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openAddService({ProviderServiceRecord? service}) async {
    final didChange = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddServiceScreen(
          serviceData: service == null
              ? null
              : {
                  'id': service.id,
                  'name': service.name,
                  'categoryId': service.categoryId,
                  'categoryName': service.categoryName,
                  'regularPrice': service.regularPrice,
                  'offerPrice': service.offerPrice,
                  'durationText': service.durationText,
                  'description': service.description,
                  'variations': service.variations,
                  'faqs': service.faqs,
                  'serviceLocationId': service.serviceLocationId,
                  'serviceLocationText': service.serviceLocationText,
                  'serviceLatitude': service.serviceLatitude,
                  'serviceLongitude': service.serviceLongitude,
                  'mediaUrls': service.mediaUrls,
                },
        ),
      ),
    );

    if (didChange == true) {
      setState(() => _isLoading = true);
      await _loadServices();
    }
  }

  Future<void> _toggleActive(ProviderServiceRecord service) async {
    try {
      await ProviderServiceService.toggleServiceActive(
        serviceId: service.id,
        isActive: !service.isActive,
      );
      if (!mounted) {
        return;
      }
      context.showAppSnackBar(
        service.isActive ? 'Service paused.' : 'Service activated.',
      );
      setState(() => _isLoading = true);
      await _loadServices();
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }
      context.showAppSnackBar(error.message, isError: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showAppSnackBar('Could not update service status.',
          isError: true);
    }
  }

  Future<void> _deleteService(ProviderServiceRecord service) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Service'),
            content: Text('Delete "${service.name}" permanently?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    try {
      await ProviderServiceService.deleteService(service);
      if (!mounted) {
        return;
      }
      context.showAppSnackBar('Service deleted.');
      setState(() => _isLoading = true);
      await _loadServices();
    } on PostgrestException catch (error) {
      if (!mounted) {
        return;
      }
      context.showAppSnackBar(error.message, isError: true);
    } catch (error) {
      if (!mounted) {
        return;
      }
      context.showAppSnackBar('Could not delete service.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6950F4),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Portfolio',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() => _isLoading = true);
                    _loadServices();
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadServices,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 100,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: _services.length,
                    itemBuilder: (context, index) {
                      return _buildServiceCard(_services[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddService(),
        backgroundColor: const Color(0xFF6950F4),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.design_services_outlined,
            size: 80,
            color: Colors.black12,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Services Found',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first service.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Colors.black38,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _openAddService(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6950F4),
            ),
            child: const Text(
              'Add Service',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ProviderServiceRecord service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF5F5F5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: service.coverImageUrl == null
                      ? const Icon(Icons.image, color: Colors.black26)
                      : Image.network(
                          service.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, color: Colors.black26),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: service.isActive
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFECEFF1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.isActive ? 'ACTIVE' : 'PAUSED',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: service.isActive
                                    ? const Color(0xFF388E3C)
                                    : Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service.categoryName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            'BDT ${_formatPrice(service.offerPrice ?? service.regularPrice)}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF6950F4),
                            ),
                          ),
                          if (service.offerPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              'BDT ${_formatPrice(service.regularPrice)}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: Colors.black38,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if ((service.durationText ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          service.durationText!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.black12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _toggleActive(service),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          service.isActive
                              ? Icons.pause_circle_outline_rounded
                              : Icons.play_circle_outline_rounded,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          service.isActive ? 'Pause' : 'Activate',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.black12),
              Expanded(
                child: InkWell(
                  onTap: () => _openAddService(service: service),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined,
                            size: 18, color: Colors.black54),
                        SizedBox(width: 6),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 20, color: Colors.black12),
              Expanded(
                child: InkWell(
                  onTap: () => _deleteService(service),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Color(0xFFD32F2F),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Delete',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);
  }
}
