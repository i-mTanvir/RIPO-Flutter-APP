import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderCategoryOption {
  const ProviderCategoryOption({
    required this.id,
    required this.name,
  });

  final String id;
  final String name;
}

class ProviderServiceRecord {
  const ProviderServiceRecord({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.variations,
    required this.faqs,
    required this.durationText,
    required this.regularPrice,
    required this.offerPrice,
    required this.isActive,
    required this.mediaUrls,
  });

  final String id;
  final String categoryId;
  final String categoryName;
  final String name;
  final String? description;
  final String? variations;
  final String? faqs;
  final String? durationText;
  final double regularPrice;
  final double? offerPrice;
  final bool isActive;
  final List<String> mediaUrls;

  String? get coverImageUrl => mediaUrls.isEmpty ? null : mediaUrls.first;
}

class ServiceUploadImage {
  const ServiceUploadImage({
    required this.fileName,
    required this.bytes,
    required this.contentType,
  });

  final String fileName;
  final Uint8List bytes;
  final String contentType;

  static Future<ServiceUploadImage> fromXFile(XFile file) async {
    return ServiceUploadImage(
      fileName: file.name,
      bytes: await file.readAsBytes(),
      contentType: _contentTypeForFileName(file.name),
    );
  }

  static String _contentTypeForFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}

class ProviderServiceInput {
  const ProviderServiceInput({
    required this.name,
    required this.categoryId,
    required this.regularPrice,
    required this.durationText,
    required this.existingImageUrls,
    required this.newImages,
    this.serviceId,
    this.description,
    this.variations,
    this.faqs,
    this.offerPrice,
  });

  final String? serviceId;
  final String name;
  final String categoryId;
  final double regularPrice;
  final double? offerPrice;
  final String? durationText;
  final String? description;
  final String? variations;
  final String? faqs;
  final List<String> existingImageUrls;
  final List<ServiceUploadImage> newImages;
}

class ProviderServiceService {
  ProviderServiceService._();

  static final SupabaseClient _client = Supabase.instance.client;
  static const String _bucket = 'service-media';

  static String get _providerId {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('You must be logged in as a provider.');
    }
    return user.id;
  }

  static Future<List<ProviderCategoryOption>> fetchCategories() async {
    final response = await _client
        .from('service_categories')
        .select('id, name')
        .eq('is_active', true)
        .order('sort_order', ascending: true)
        .order('name', ascending: true);

    return (response as List<dynamic>)
        .map(
          (row) => ProviderCategoryOption(
            id: row['id'] as String,
            name: row['name'] as String,
          ),
        )
        .toList();
  }

  static Future<List<ProviderServiceRecord>> fetchProviderServices() async {
    final response = await _client
        .from('services')
        .select('''
          id,
          name,
          description,
          variations,
          faqs,
          duration_text,
          regular_price,
          offer_price,
          is_active,
          category_id,
          service_categories(name),
          service_media(file_url, is_cover, sort_order)
        ''')
        .eq('provider_id', _providerId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((row) {
      final media = List<Map<String, dynamic>>.from(
        row['service_media'] as List<dynamic>? ?? const [],
      )..sort((a, b) {
          final coverCompare = ((b['is_cover'] as bool? ?? false) ? 1 : 0)
              .compareTo((a['is_cover'] as bool? ?? false) ? 1 : 0);
          if (coverCompare != 0) {
            return coverCompare;
          }
          return (a['sort_order'] as int? ?? 0)
              .compareTo(b['sort_order'] as int? ?? 0);
        });

      return ProviderServiceRecord(
        id: row['id'] as String,
        name: row['name'] as String,
        categoryId: row['category_id'] as String,
        categoryName:
            (row['service_categories'] as Map<String, dynamic>?)?['name']
                    as String? ??
                'Unknown',
        description: row['description'] as String?,
        variations: row['variations'] as String?,
        faqs: row['faqs'] as String?,
        durationText: row['duration_text'] as String?,
        regularPrice: (row['regular_price'] as num).toDouble(),
        offerPrice: (row['offer_price'] as num?)?.toDouble(),
        isActive: row['is_active'] as bool? ?? true,
        mediaUrls: media
            .map((item) => item['file_url'] as String)
            .where((url) => url.isNotEmpty)
            .toList(),
      );
    }).toList();
  }

  static Future<void> saveService(ProviderServiceInput input) async {
    final providerId = _providerId;

    final servicePayload = {
      'provider_id': providerId,
      'category_id': input.categoryId,
      'name': input.name,
      'description': _nullableText(input.description),
      'variations': _nullableText(input.variations),
      'faqs': _nullableText(input.faqs),
      'duration_text': _nullableText(input.durationText),
      'regular_price': input.regularPrice,
      'offer_price': input.offerPrice,
      'is_active': true,
    };

    String serviceId;
    if (input.serviceId == null) {
      final inserted = await _client
          .from('services')
          .insert(servicePayload)
          .select('id')
          .single();
      serviceId = inserted['id'] as String;
    } else {
      serviceId = input.serviceId!;
      await _client.from('services').update(servicePayload).eq('id', serviceId);
    }

    final existingRows = input.serviceId == null
        ? <Map<String, dynamic>>[]
        : List<Map<String, dynamic>>.from(
            await _client
                .from('service_media')
                .select('id, file_url')
                .eq('service_id', serviceId),
          );

    final existingUrls = existingRows
        .map((row) => row['file_url'] as String)
        .where((url) => url.isNotEmpty)
        .toSet();
    final keptUrls = input.existingImageUrls.toSet();
    final removedUrls = existingUrls.difference(keptUrls);

    if (existingRows.isNotEmpty) {
      await _client.from('service_media').delete().eq('service_id', serviceId);
    }

    if (removedUrls.isNotEmpty) {
      final paths = removedUrls
          .map(_storagePathFromPublicUrl)
          .whereType<String>()
          .toList();
      if (paths.isNotEmpty) {
        await _client.storage.from(_bucket).remove(paths);
      }
    }

    final finalUrls = <String>[...input.existingImageUrls];
    for (final image in input.newImages) {
      final path = _buildStoragePath(
        providerId: providerId,
        serviceId: serviceId,
        fileName: image.fileName,
      );
      await _client.storage.from(_bucket).uploadBinary(
            path,
            image.bytes,
            fileOptions: FileOptions(
              contentType: image.contentType,
              upsert: true,
            ),
          );
      final publicUrl = _client.storage.from(_bucket).getPublicUrl(path);
      finalUrls.add(publicUrl);
    }

    if (finalUrls.isNotEmpty) {
      await _client.from('service_media').insert(
            finalUrls.asMap().entries.map((entry) {
              return {
                'service_id': serviceId,
                'file_url': entry.value,
                'is_cover': entry.key == 0,
                'sort_order': entry.key,
              };
            }).toList(),
          );
    }
  }

  static Future<void> toggleServiceActive({
    required String serviceId,
    required bool isActive,
  }) {
    return _client
        .from('services')
        .update({'is_active': isActive}).eq('id', serviceId);
  }

  static Future<void> deleteService(ProviderServiceRecord service) async {
    final paths = service.mediaUrls
        .map(_storagePathFromPublicUrl)
        .whereType<String>()
        .toList();
    if (paths.isNotEmpty) {
      await _client.storage.from(_bucket).remove(paths);
    }
    await _client.from('services').delete().eq('id', service.id);
  }

  static String? _nullableText(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static String _buildStoragePath({
    required String providerId,
    required String serviceId,
    required String fileName,
  }) {
    final sanitizedName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$providerId/$serviceId/$timestamp-$sanitizedName';
  }

  static String? _storagePathFromPublicUrl(String publicUrl) {
    final marker = '/storage/v1/object/public/$_bucket/';
    final index = publicUrl.indexOf(marker);
    if (index == -1) {
      return null;
    }
    return Uri.decodeComponent(publicUrl.substring(index + marker.length));
  }
}
