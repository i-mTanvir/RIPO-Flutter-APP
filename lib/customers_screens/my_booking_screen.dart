// lib\customers_screens\my_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/booking_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({super.key});

  @override
  State<MyBookingScreen> createState() => _MyBookingScreenState();
}

class _MyBookingScreenState extends State<MyBookingScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _bookings = <Map<String, dynamic>>[];
  Map<String, Map<String, dynamic>> _reviewsByBooking = {};
  final Map<String, int> _draftRatings = {};
  final Map<String, String> _draftComments = {};
  final Set<String> _submittingReviewFor = {};
  final Set<String> _processingPaymentFor = {};

  final Map<String, Color> _bgColors = {
    'Pending': const Color(0xFFFDF0D5),
    'Accepted': const Color(0xFFD4C4F7),
    'In Progress': const Color(0xFFE2E4FF),
    'Rejected': const Color(0xFFFADBD8),
    'Completed': const Color(0xFFD5F5E3),
    'Cancelled': const Color(0xFFF5E6E6),
  };

  final Map<String, Color> _textColors = {
    'Pending': const Color(0xFFF39C12),
    'Accepted': const Color(0xFF6950F4),
    'In Progress': const Color(0xFF5D5FEF),
    'Rejected': const Color(0xFFE74C3C),
    'Completed': const Color(0xFF27AE60),
    'Cancelled': const Color(0xFFB23B3B),
  };

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _bookings = <Map<String, dynamic>>[];
        _isLoading = false;
      });
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final rows = await client.from('bookings').select('''
            id,
            booking_code,
            booking_date,
            time_slot_text,
            total_amount,
            booking_status,
            payment_method,
            payment_status,
            payment_channel,
            payment_transaction_id,
            created_at,
            service_id,
            provider_id,
            customer_id,
            services(name),
            provider_profiles(owner_name, business_name)
          ''').eq('customer_id', userId).order('created_at', ascending: false);

      final mapped = List<Map<String, dynamic>>.from(rows).map((row) {
        final serviceMap = row['services'] as Map<String, dynamic>?;
        final providerMap = row['provider_profiles'] as Map<String, dynamic>?;
        final serviceName = (serviceMap?['name'] as String?)?.trim() ?? '';
        final ownerName = (providerMap?['owner_name'] as String?)?.trim() ?? '';
        final businessName =
            (providerMap?['business_name'] as String?)?.trim() ?? '';
        final providerName = ownerName.isNotEmpty ? ownerName : businessName;

        final amount = (row['total_amount'] as num?)?.toDouble() ?? 0;
        final bookingDate = (row['booking_date'] as String?)?.trim() ?? '';
        final timeSlot = (row['time_slot_text'] as String?)?.trim() ?? '';
        final prettyDate = _formatBookingDate(bookingDate, timeSlot);
        final statusLabel =
            _statusLabel((row['booking_status'] as String?)?.trim() ?? '');
        final paymentStatusRaw =
            (row['payment_status'] as String?)?.trim() ?? 'unpaid';
        final paymentMethodRaw =
            (row['payment_method'] as String?)?.trim() ?? 'offline';
        final paymentChannelRaw =
            (row['payment_channel'] as String?)?.trim() ?? '';

        return <String, dynamic>{
          'id': (row['booking_code'] as String?)?.trim().isNotEmpty == true
              ? (row['booking_code'] as String).trim()
              : (row['id'] as String?) ?? '',
          'bookingId': row['id'],
          'serviceId': row['service_id'],
          'providerId': row['provider_id'],
          'customerId': row['customer_id'],
          'statusRaw': (row['booking_status'] as String?)?.trim() ?? 'pending',
          'paymentStatusRaw': paymentStatusRaw,
          'paymentStatus': _paymentStatusLabel(paymentStatusRaw),
          'paymentMethod':
              _paymentMethodLabel(paymentMethodRaw, paymentChannelRaw),
          'paymentTransactionId':
              (row['payment_transaction_id'] as String?)?.trim() ?? '',
          'serviceName': serviceName,
          'providerName': providerName,
          'price': 'BDT ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}',
          'date': prettyDate,
          'status': statusLabel,
        };
      }).toList();

      final bookingIds = mapped
          .map((e) => e['bookingId'] as String?)
          .whereType<String>()
          .toList();
      final reviewsByBooking = <String, Map<String, dynamic>>{};
      if (bookingIds.isNotEmpty) {
        final reviewRows = await client
            .from('reviews')
            .select('id, booking_id, rating, comment')
            .inFilter('booking_id', bookingIds);
        for (final r in List<Map<String, dynamic>>.from(reviewRows)) {
          final bId = r['booking_id'] as String?;
          if (bId != null) {
            reviewsByBooking[bId] = r;
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _bookings = mapped;
        _reviewsByBooking = reviewsByBooking;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load bookings.')),
      );
    }
  }

  String _statusLabel(String raw) {
    switch (raw) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'in_progress':
        return 'In Progress';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
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
      case 'unpaid':
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
      case 'offline':
      default:
        return 'Offline';
    }
  }

  bool _canPay(Map<String, dynamic> booking) =>
      booking['statusRaw'] == 'completed' &&
      booking['paymentStatusRaw'] != 'paid';

  bool _canReview(Map<String, dynamic> booking) =>
      booking['statusRaw'] == 'completed' &&
      booking['paymentStatusRaw'] == 'paid';

  Future<void> _showPaymentDialog(Map<String, dynamic> booking) async {
    final bookingId = booking['bookingId'] as String;
    if (_processingPaymentFor.contains(bookingId)) return;

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
      await _updatePayment(
          bookingId: bookingId,
          method: 'offline',
          channel: 'offline',
          txnId: '');
    } else if (choice == 'online') {
      if (!mounted) return;
      final pinController = TextEditingController();
      final pay = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('bKash PIN'),
              content: TextField(
                controller: pinController,
                maxLength: 5,
                obscureText: true,
                keyboardType: TextInputType.number,
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
            const SnackBar(content: Text('Invalid PIN. Must be 5 digits.')),
          );
        }
        return;
      }
      final txnId = 'BKX-${DateTime.now().millisecondsSinceEpoch}';
      await _updatePayment(
          bookingId: bookingId,
          method: 'online',
          channel: 'bkash',
          txnId: txnId);
    }
  }

  Future<void> _updatePayment({
    required String bookingId,
    required String method,
    required String channel,
    required String txnId,
  }) async {
    setState(() => _processingPaymentFor.add(bookingId));
    try {
      await Supabase.instance.client.from('bookings').update({
        'payment_method': method,
        'payment_status': 'paid',
        'payment_channel': channel,
        'payment_transaction_id': txnId.isEmpty ? null : txnId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(txnId.isEmpty
                ? 'Payment confirmed.'
                : 'Payment successful. Txn: $txnId')),
      );
      await _loadBookings();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not process payment.')),
      );
    } finally {
      if (mounted) setState(() => _processingPaymentFor.remove(bookingId));
    }
  }

  Future<void> _submitReview(Map<String, dynamic> booking) async {
    final bookingId = booking['bookingId'] as String;
    final serviceId = booking['serviceId'] as String;
    final providerId = booking['providerId'] as String;
    final customerId = booking['customerId'] as String;

    final rating = _draftRatings[bookingId] ??
        ((_reviewsByBooking[bookingId]?['rating'] as num?)?.toInt() ?? 0);
    final comment = (_draftComments[bookingId] ??
            ((_reviewsByBooking[bookingId]?['comment'] as String?) ?? ''))
        .trim();

    if (rating < 1 || rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a rating between 1 and 5.')),
      );
      return;
    }

    setState(() => _submittingReviewFor.add(bookingId));
    try {
      final existingReview = _reviewsByBooking[bookingId];
      final payload = {
        'booking_id': bookingId,
        'customer_id': customerId,
        'provider_id': providerId,
        'service_id': serviceId,
        'rating': rating,
        'comment': comment.isEmpty ? null : comment,
      };
      final client = Supabase.instance.client;
      if (existingReview == null) {
        final inserted = await client
            .from('reviews')
            .insert(payload)
            .select('id, booking_id, rating, comment')
            .single();
        _reviewsByBooking[bookingId] = inserted;
      } else {
        await client
            .from('reviews')
            .update(payload)
            .eq('id', existingReview['id']);
        _reviewsByBooking[bookingId] = {
          ...existingReview,
          'rating': rating,
          'comment': comment,
        };
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Review submitted.')));
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not submit review.')),
      );
    } finally {
      if (mounted) setState(() => _submittingReviewFor.remove(bookingId));
    }
  }

  String _formatBookingDate(String bookingDate, String timeSlot) {
    if (bookingDate.isEmpty && timeSlot.isEmpty) return '';
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
    if (timeSlot.isEmpty) return dateText;
    return '$dateText - $timeSlot';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        title: const Text(
          'My Booking',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _isLoading ? null : _loadBookings,
            child: Container(
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE2DCFE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Text(
                    'Refresh',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.refresh_rounded, size: 18, color: Colors.black87),
                ],
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(
                  child: Text(
                    'No bookings found.',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      color: Colors.black45,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final status = booking['status'] as String;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingDetailsScreen(bookingData: booking),
                            ),
                          ).then((_) => _loadBookings());
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFE0E0E0), width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Booking ID: ${booking['id']}',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _bgColors[status] ??
                                          const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _textColors[status] ??
                                            Colors.black54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                booking['serviceName'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Provider: ${booking['providerName']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Price: ${booking['price']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Booking Date: ${booking['date']}',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Payment: ${booking['paymentStatus']} (${booking['paymentMethod']})',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black45,
                                ),
                              ),
                              if (((booking['paymentTransactionId']
                                          as String?) ??
                                      '')
                                  .isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Txn ID: ${booking['paymentTransactionId']}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                              if (_canPay(booking)) ...[
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _processingPaymentFor
                                            .contains(booking['bookingId'])
                                        ? null
                                        : () => _showPaymentDialog(booking),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6950F4),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                    child: Text(
                                      _processingPaymentFor
                                              .contains(booking['bookingId'])
                                          ? 'Processing...'
                                          : 'Pay Now',
                                    ),
                                  ),
                                ),
                              ],
                              if (_canReview(booking) ||
                                  _reviewsByBooking
                                      .containsKey(booking['bookingId'])) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9F9FB),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: const Color(0xFFE0E0E0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _reviewsByBooking.containsKey(
                                                booking['bookingId'])
                                            ? 'Your Review'
                                            : 'Write Review',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: List.generate(5, (i) {
                                          final value = i + 1;
                                          final selected = (_draftRatings[
                                                      booking['bookingId']] ??
                                                  ((_reviewsByBooking[booking[
                                                                  'bookingId']]
                                                              ?[
                                                              'rating'] as num?)
                                                          ?.toInt() ??
                                                      0)) >=
                                              value;
                                          return IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                                minWidth: 30),
                                            onPressed: _canReview(booking)
                                                ? () => setState(() =>
                                                    _draftRatings[booking[
                                                        'bookingId']] = value)
                                                : null,
                                            icon: Icon(
                                              selected
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              color: const Color(0xFFFFB300),
                                            ),
                                          );
                                        }),
                                      ),
                                      TextFormField(
                                        initialValue: _draftComments[
                                                booking['bookingId']] ??
                                            ((_reviewsByBooking[
                                                        booking['bookingId']]
                                                    ?['comment'] as String?) ??
                                                ''),
                                        enabled: _canReview(booking),
                                        maxLines: 2,
                                        onChanged: (v) => _draftComments[
                                            booking['bookingId']] = v,
                                        decoration: const InputDecoration(
                                          hintText: 'Write comment...',
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: (_canReview(booking) &&
                                                  !_submittingReviewFor
                                                      .contains(
                                                          booking['bookingId']))
                                              ? () => _submitReview(booking)
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF6950F4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            _submittingReviewFor.contains(
                                                    booking['bookingId'])
                                                ? 'Submitting...'
                                                : (_reviewsByBooking
                                                        .containsKey(booking[
                                                            'bookingId'])
                                                    ? 'Update Review'
                                                    : 'Send Review'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
