// lib\customers_screens\booking_details_screen.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? bookingData;

  const BookingDetailsScreen({super.key, this.bookingData});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isLoading = true;
  bool _isProcessingPayment = false;
  bool _isSubmittingReview = false;

  Map<String, dynamic> _details = <String, dynamic>{};
  Set<String> _historyStatuses = <String>{};

  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 0;
  String? _reviewId;

  @override
  void initState() {
    super.initState();
    _details = Map<String, dynamic>.from(widget.bookingData ?? const {});
    _loadBookingDetails();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadBookingDetails() async {
    final bookingId =
        (widget.bookingData?['bookingId'] as String?)?.trim() ?? '';
    if (bookingId.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    final client = Supabase.instance.client;
    try {
      final row = await client.from('bookings').select('''
            id,
            booking_code,
            booking_date,
            time_slot_text,
            quantity,
            unit_price,
            total_amount,
            payment_method,
            payment_status,
            payment_channel,
            payment_transaction_id,
            booking_status,
            created_at,
            service_id,
            customer_id,
            provider_id,
            services(name),
            provider_profiles(owner_name, business_name),
            locations(address_line, area, city)
          ''').eq('id', bookingId).maybeSingle();

      if (row == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      final historyRows = await client
          .from('booking_status_history')
          .select('status')
          .eq('booking_id', bookingId)
          .order('created_at', ascending: true);

      final existingReview = await client
          .from('reviews')
          .select('id, rating, comment')
          .eq('booking_id', bookingId)
          .maybeSingle();

      final customerId = row['customer_id'] as String?;
      final providerId = row['provider_id'] as String?;
      final profileIds = <String>{};
      if (customerId != null && customerId.isNotEmpty) {
        profileIds.add(customerId);
      }
      if (providerId != null && providerId.isNotEmpty) {
        profileIds.add(providerId);
      }

      final profileMap = <String, Map<String, dynamic>>{};
      if (profileIds.isNotEmpty) {
        final profileRows = await client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', profileIds.toList());
        for (final item in List<Map<String, dynamic>>.from(profileRows)) {
          final id = item['id'] as String?;
          if (id != null) profileMap[id] = item;
        }
      }

      final serviceMap = row['services'] as Map<String, dynamic>?;
      final providerMap = row['provider_profiles'] as Map<String, dynamic>?;
      final locationMap = row['locations'] as Map<String, dynamic>?;

      final ownerName = (providerMap?['owner_name'] as String?)?.trim() ?? '';
      final businessName =
          (providerMap?['business_name'] as String?)?.trim() ?? '';
      final providerName = ownerName.isNotEmpty ? ownerName : businessName;

      final addressLine =
          (locationMap?['address_line'] as String?)?.trim() ?? '';
      final area = (locationMap?['area'] as String?)?.trim() ?? '';
      final city = (locationMap?['city'] as String?)?.trim() ?? '';
      final address =
          [addressLine, area, city].where((e) => e.isNotEmpty).join(', ');

      final statusRaw = (row['booking_status'] as String?)?.trim() ?? 'pending';
      final paymentStatusRaw =
          (row['payment_status'] as String?)?.trim() ?? 'unpaid';
      final paymentMethodRaw =
          (row['payment_method'] as String?)?.trim() ?? 'offline';
      final paymentChannelRaw =
          (row['payment_channel'] as String?)?.trim() ?? '';

      _reviewId = existingReview?['id'] as String?;
      _selectedRating = (existingReview?['rating'] as num?)?.toInt() ?? 0;
      _reviewController.text =
          (existingReview?['comment'] as String?)?.trim() ?? '';

      final history = List<Map<String, dynamic>>.from(historyRows)
          .map((e) => (e['status'] as String?)?.trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toSet();
      history.add(statusRaw);

      if (!mounted) return;
      setState(() {
        _historyStatuses = history;
        _details = {
          ..._details,
          'bookingId': row['id'] as String? ?? '',
          'id': ((row['booking_code'] as String?)?.trim().isNotEmpty == true)
              ? (row['booking_code'] as String).trim()
              : (row['id'] as String? ?? ''),
          'statusRaw': statusRaw,
          'status': _statusLabel(statusRaw),
          'paymentStatusRaw': paymentStatusRaw,
          'paymentStatus': _paymentStatusLabel(paymentStatusRaw),
          'paymentMethodRaw': paymentMethodRaw,
          'paymentMethod':
              _paymentMethodLabel(paymentMethodRaw, paymentChannelRaw),
          'paymentTransactionId':
              (row['payment_transaction_id'] as String?)?.trim() ?? '',
          'serviceId': row['service_id'] as String? ?? '',
          'providerId': providerId ?? '',
          'customerId': customerId ?? '',
          'serviceName': (serviceMap?['name'] as String?)?.trim() ?? '',
          'providerName': providerName,
          'providerAvatarUrl': providerId == null
              ? ''
              : ((profileMap[providerId]?['avatar_url'] as String?)?.trim() ??
                  ''),
          'customerName': customerId == null
              ? ''
              : ((profileMap[customerId]?['full_name'] as String?)?.trim() ??
                  ''),
          'customerAvatarUrl': customerId == null
              ? ''
              : ((profileMap[customerId]?['avatar_url'] as String?)?.trim() ??
                  ''),
          'date': _formatBookingDate(
              (row['booking_date'] as String?)?.trim() ?? '',
              (row['time_slot_text'] as String?)?.trim() ?? ''),
          'address': address,
          'quantity': (row['quantity'] as num?)?.toInt() ?? 1,
          'unitPrice':
              _formatMoney((row['unit_price'] as num?)?.toDouble() ?? 0),
          'totalAmount':
              _formatMoney((row['total_amount'] as num?)?.toDouble() ?? 0),
        };
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load booking details.')),
      );
    }
  }

  String _statusLabel(String raw) {
    switch (raw) {
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Pending';
    }
  }

  String _paymentStatusLabel(String raw) {
    switch (raw) {
      case 'paid':
        return 'Paid';
      case 'refunded':
        return 'Refunded';
      case 'partial':
        return 'Partial';
      default:
        return 'Unpaid';
    }
  }

  String _paymentMethodLabel(String raw, String channel) {
    if (raw == 'online' && channel == 'bkash') return 'Online (bKash)';
    switch (raw) {
      case 'online':
        return 'Online';
      case 'cash':
        return 'Cash';
      case 'wallet':
        return 'Wallet';
      default:
        return 'Offline';
    }
  }

  String _formatMoney(double value) =>
      'BDT ${value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2)}';

  String _formatBookingDate(String bookingDate, String timeSlot) {
    if (bookingDate.isEmpty && timeSlot.isEmpty) {
      return '';
    }
    final dt = DateTime.tryParse(bookingDate);
    if (dt == null) {
      return '$bookingDate ${timeSlot.isEmpty ? '' : '- $timeSlot'}'.trim();
    }
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dateText = '${dt.day} ${monthNames[dt.month - 1]} ${dt.year}';
    return timeSlot.isEmpty ? dateText : '$dateText - $timeSlot';
  }

  bool get _canPay {
    final status = (_details['statusRaw'] as String?) ?? '';
    final payment = (_details['paymentStatusRaw'] as String?) ?? '';
    return status == 'completed' && payment != 'paid';
  }

  bool get _canReview {
    final status = (_details['statusRaw'] as String?) ?? '';
    final payment = (_details['paymentStatusRaw'] as String?) ?? '';
    return status == 'completed' && payment == 'paid';
  }

  Future<void> _updatePayment({
    required String paymentMethod,
    required String paymentStatus,
    required String paymentChannel,
    String? transactionId,
  }) async {
    final bookingId = (_details['bookingId'] as String?) ?? '';
    if (bookingId.isEmpty) return;

    setState(() => _isProcessingPayment = true);
    try {
      await Supabase.instance.client.from('bookings').update({
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
        'payment_channel': paymentChannel.isEmpty ? null : paymentChannel,
        'payment_transaction_id':
            (transactionId ?? '').isEmpty ? null : transactionId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            transactionId == null || transactionId.isEmpty
                ? 'Payment confirmed.'
                : 'Payment successful. Txn: $transactionId',
          ),
          backgroundColor: Colors.green,
        ),
      );
      await _loadBookingDetails();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not complete payment.')),
      );
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  Future<void> _showPaymentOptionsDialog() async {
    if (_isProcessingPayment) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Payment Method'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'offline'),
              child: const Text('Pay Offline')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, 'online'),
              child: const Text('Pay Online')),
        ],
      ),
    );

    if (choice == 'offline') {
      if (!mounted) return;
      final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Confirm Offline Payment'),
              content: const Text('Are you confirming you paid offline?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('No')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Confirm')),
              ],
            ),
          ) ??
          false;
      if (confirm) {
        await _updatePayment(
            paymentMethod: 'offline',
            paymentStatus: 'paid',
            paymentChannel: 'offline');
      }
      return;
    }

    if (choice == 'online') {
      if (!mounted) return;
      final pinController = TextEditingController();
      final pay = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('bKash Payment'),
              content: TextField(
                controller: pinController,
                maxLength: 5,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Enter bKash PIN'),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Pay')),
              ],
            ),
          ) ??
          false;
      if (!mounted) return;

      final pin = pinController.text.trim();
      pinController.dispose();
      if (!pay) return;
      if (pin.length != 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Invalid bKash PIN. Must be 5 digits.')),
          );
        }
        return;
      }

      final txnId =
          'BKX-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(900000) + 100000}';
      await _updatePayment(
        paymentMethod: 'online',
        paymentStatus: 'paid',
        paymentChannel: 'bkash',
        transactionId: txnId,
      );
    }
  }

  Future<void> _submitReview() async {
    if (_isSubmittingReview) return;

    final bookingId = (_details['bookingId'] as String?) ?? '';
    final serviceId = (_details['serviceId'] as String?) ?? '';
    final providerId = (_details['providerId'] as String?) ?? '';
    final customerId = (_details['customerId'] as String?) ?? '';

    if (bookingId.isEmpty ||
        serviceId.isEmpty ||
        providerId.isEmpty ||
        customerId.isEmpty) {
      return;
    }
    if (_selectedRating < 1 || _selectedRating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a rating between 1 and 5.')),
      );
      return;
    }

    setState(() => _isSubmittingReview = true);
    try {
      final payload = {
        'booking_id': bookingId,
        'customer_id': customerId,
        'provider_id': providerId,
        'service_id': serviceId,
        'rating': _selectedRating,
        'comment': _reviewController.text.trim().isEmpty
            ? null
            : _reviewController.text.trim(),
      };

      final client = Supabase.instance.client;
      if (_reviewId == null) {
        final inserted =
            await client.from('reviews').insert(payload).select('id').single();
        _reviewId = inserted['id'] as String?;
      } else {
        await client.from('reviews').update(payload).eq('id', _reviewId!);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review submitted.')));
      await _loadBookingDetails();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit review.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  Color _statusBg(String status) => status == 'Completed'
      ? const Color(0xFFD5F5E3)
      : status == 'Rejected'
          ? const Color(0xFFFADBD8)
          : status == 'Accepted'
              ? const Color(0xFFD4C4F7)
              : status == 'In Progress'
                  ? const Color(0xFFE2E4FF)
                  : status == 'Cancelled'
                      ? const Color(0xFFF5E6E6)
                      : const Color(0xFFFDF0D5);

  Color _statusText(String status) => status == 'Completed'
      ? const Color(0xFF27AE60)
      : status == 'Rejected'
          ? const Color(0xFFE74C3C)
          : status == 'Accepted'
              ? const Color(0xFF6950F4)
              : status == 'In Progress'
                  ? const Color(0xFF5D5FEF)
                  : status == 'Cancelled'
                      ? const Color(0xFFB23B3B)
                      : const Color(0xFFF39C12);

  bool _isStepDone(String step) => _historyStatuses.contains(step);

  @override
  Widget build(BuildContext context) {
    final status = (_details['status'] as String?) ?? 'Pending';
    final providerAvatarUrl = (_details['providerAvatarUrl'] as String?) ?? '';
    final customerAvatarUrl = (_details['customerAvatarUrl'] as String?) ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Booking Details',
            style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: Colors.black)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    'Booking ID: ${_details['id'] ?? ''}',
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700))),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                  color: _statusBg(status),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(status,
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _statusText(status))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_details['date'] as String? ?? '',
                            style: const TextStyle(
                                fontFamily: 'Inter', color: Colors.black54)),
                        const SizedBox(height: 10),
                        _progress(),
                        const SizedBox(height: 12),
                        _summaryRow(
                            'Address', _details['address'] as String? ?? ''),
                        const SizedBox(height: 8),
                        _summaryRow(
                            'Total', _details['totalAmount'] as String? ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFE8F4FD),
                          backgroundImage: providerAvatarUrl.isEmpty
                              ? null
                              : NetworkImage(providerAvatarUrl),
                          child: providerAvatarUrl.isEmpty
                              ? const Icon(Icons.person, color: Colors.black54)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Service Provider',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: Colors.black54)),
                              Text(_details['providerName'] as String? ?? '',
                                  style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Payment',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        _summaryRow('Method',
                            _details['paymentMethod'] as String? ?? 'Offline'),
                        const SizedBox(height: 6),
                        _summaryRow('Status',
                            _details['paymentStatus'] as String? ?? 'Unpaid'),
                        if (((_details['paymentTransactionId'] as String?) ??
                                '')
                            .isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _summaryRow('Txn ID',
                              _details['paymentTransactionId'] as String),
                        ],
                        if (_canPay) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isProcessingPayment
                                  ? null
                                  : _showPaymentOptionsDialog,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6950F4)),
                              child: Text(_isProcessingPayment
                                  ? 'Processing...'
                                  : 'Pay Now'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Service Summary',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(_details['serviceName'] as String? ?? '',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        _summaryRow('Qty', '${_details['quantity'] ?? 1}'),
                        const SizedBox(height: 6),
                        _summaryRow('Unit Price',
                            _details['unitPrice'] as String? ?? ''),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: const Color(0xFFE8F4FD),
                              backgroundImage: customerAvatarUrl.isEmpty
                                  ? null
                                  : NetworkImage(customerAvatarUrl),
                              child: customerAvatarUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 16, color: Colors.black54)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    _details['customerName'] as String? ?? '',
                                    style:
                                        const TextStyle(fontFamily: 'Inter'))),
                          ],
                        )
                      ],
                    ),
                  ),
                  if (_canReview || _reviewId != null) ...[
                    const SizedBox(height: 12),
                    _card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _reviewId == null
                                  ? 'Write Review'
                                  : 'Your Review',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (i) {
                              final v = i + 1;
                              return IconButton(
                                onPressed: _canReview
                                    ? () => setState(() => _selectedRating = v)
                                    : null,
                                icon: Icon(
                                    v <= _selectedRating
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    color: const Color(0xFFFFB300)),
                              );
                            }),
                          ),
                          TextField(
                            controller: _reviewController,
                            enabled: _canReview,
                            maxLines: 3,
                            decoration: const InputDecoration(
                                hintText: 'Write your comment',
                                border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (_canReview && !_isSubmittingReview)
                                  ? _submitReview
                                  : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6950F4)),
                              child: Text(_isSubmittingReview
                                  ? 'Submitting...'
                                  : (_reviewId == null
                                      ? 'Send Review'
                                      : 'Update Review')),
                            ),
                          )
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
    );
  }

  Widget _card({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2))
          ],
        ),
        child: child,
      );

  Widget _summaryRow(String label, String value) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 90,
              child: Text('$label:',
                  style: const TextStyle(
                      fontFamily: 'Inter', color: Colors.black45))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontFamily: 'Inter', color: Colors.black87))),
        ],
      );

  Widget _progress() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _step('Accepted', _isStepDone('accepted')),
          Expanded(child: Container(height: 1, color: Colors.black12)),
          _step('In progress', _isStepDone('in_progress')),
          Expanded(child: Container(height: 1, color: Colors.black12)),
          _step('Completed', _isStepDone('completed')),
          Expanded(child: Container(height: 1, color: Colors.black12)),
          _step(
              'Rejected', _isStepDone('rejected') || _isStepDone('cancelled')),
        ],
      );

  Widget _step(String label, bool done) => Column(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor:
                done ? const Color(0xFF6950F4) : const Color(0xFFF0F0F0),
            child: Icon(Icons.check,
                size: 12, color: done ? Colors.white : Colors.black38),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  color: done ? const Color(0xFF6950F4) : Colors.black38)),
        ],
      );
}
