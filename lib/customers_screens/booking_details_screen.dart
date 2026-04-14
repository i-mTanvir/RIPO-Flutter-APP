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
  Map<String, dynamic> _details = <String, dynamic>{};
  Set<String> _historyStatuses = <String>{};

  @override
  void initState() {
    super.initState();
    _details = Map<String, dynamic>.from(widget.bookingData ?? const {});
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    final bookingId = (widget.bookingData?['bookingId'] as String?)?.trim() ?? '';
    if (bookingId.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    final client = Supabase.instance.client;
    try {
      final row = await client
          .from('bookings')
          .select('''
            id,
            booking_code,
            booking_date,
            time_slot_text,
            scheduled_at,
            quantity,
            unit_price,
            total_amount,
            payment_method,
            payment_status,
            booking_status,
            created_at,
            service_id,
            customer_id,
            provider_id,
            customer_note,
            provider_note,
            services(name),
            provider_profiles(owner_name, business_name),
            locations(address_line, area, city)
          ''')
          .eq('id', bookingId)
          .maybeSingle();

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

      final serviceMap = row['services'] as Map<String, dynamic>?;
      final providerMap = row['provider_profiles'] as Map<String, dynamic>?;
      final locationMap = row['locations'] as Map<String, dynamic>?;
      final customerId = row['customer_id'] as String?;
      final providerId = row['provider_id'] as String?;

      final ownerName = (providerMap?['owner_name'] as String?)?.trim() ?? '';
      final businessName = (providerMap?['business_name'] as String?)?.trim() ?? '';
      final providerName = ownerName.isNotEmpty ? ownerName : businessName;

      final profileIds = <String>{};
      if (customerId != null && customerId.isNotEmpty) profileIds.add(customerId);
      if (providerId != null && providerId.isNotEmpty) profileIds.add(providerId);
      final profileMap = <String, Map<String, dynamic>>{};
      if (profileIds.isNotEmpty) {
        final profileRows = await client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', profileIds.toList());
        for (final item in List<Map<String, dynamic>>.from(profileRows)) {
          final id = item['id'] as String?;
          if (id != null) {
            profileMap[id] = item;
          }
        }
      }

      final providerAvatarUrl = providerId == null
          ? ''
          : ((profileMap[providerId]?['avatar_url'] as String?)?.trim() ?? '');
      final customerAvatarUrl = customerId == null
          ? ''
          : ((profileMap[customerId]?['avatar_url'] as String?)?.trim() ?? '');
      final customerName = customerId == null
          ? ''
          : ((profileMap[customerId]?['full_name'] as String?)?.trim() ?? '');

      final addressLine = (locationMap?['address_line'] as String?)?.trim() ?? '';
      final area = (locationMap?['area'] as String?)?.trim() ?? '';
      final city = (locationMap?['city'] as String?)?.trim() ?? '';
      final address = [addressLine, area, city].where((e) => e.isNotEmpty).join(', ');

      final qty = (row['quantity'] as num?)?.toInt() ?? 1;
      final unitPrice = (row['unit_price'] as num?)?.toDouble() ?? 0;
      final total = (row['total_amount'] as num?)?.toDouble() ?? 0;
      final statusRaw = (row['booking_status'] as String?)?.trim() ?? 'pending';

      final history = List<Map<String, dynamic>>.from(historyRows)
          .map((e) => (e['status'] as String?)?.trim() ?? '')
          .where((e) => e.isNotEmpty)
          .toSet();
      history.add(statusRaw);

      if (!mounted) return;
      setState(() {
        _historyStatuses = history;
        _details = <String, dynamic>{
          ..._details,
          'bookingId': row['id'] as String? ?? '',
          'id': (row['booking_code'] as String?)?.trim().isNotEmpty == true
              ? (row['booking_code'] as String).trim()
              : (row['id'] as String?) ?? '',
          'statusRaw': statusRaw,
          'status': _statusLabel(statusRaw),
          'serviceName': (serviceMap?['name'] as String?)?.trim() ?? '',
          'providerName': providerName,
          'providerAvatarUrl': providerAvatarUrl,
          'customerAvatarUrl': customerAvatarUrl,
          'customerName': customerName,
          'date': _formatBookingDate(
            (row['booking_date'] as String?)?.trim() ?? '',
            (row['time_slot_text'] as String?)?.trim() ?? '',
          ),
          'address': address,
          'price': _formatMoney(total),
          'quantity': qty,
          'unitPrice': _formatMoney(unitPrice),
          'totalAmount': _formatMoney(total),
          'paymentMethod': _paymentMethodLabel((row['payment_method'] as String?)?.trim() ?? ''),
          'paymentStatus': _paymentStatusLabel((row['payment_status'] as String?)?.trim() ?? ''),
          'createdAt': (row['created_at'] as String?)?.trim() ?? '',
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
      case 'pending':
        return 'Pending';
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
      case 'unpaid':
      default:
        return 'Unpaid';
    }
  }

  String _paymentMethodLabel(String raw) {
    switch (raw) {
      case 'cash':
        return 'Cash';
      case 'online':
        return 'Online';
      case 'wallet':
        return 'Wallet';
      case 'offline':
      default:
        return 'Offline';
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
    return timeSlot.isEmpty ? dateText : '$dateText - $timeSlot';
  }

  String _formatMoney(double value) {
    return 'BDT ${value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2)}';
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFDF0D5);
      case 'Accepted':
        return const Color(0xFFD4C4F7);
      case 'In Progress':
        return const Color(0xFFE2E4FF);
      case 'Rejected':
        return const Color(0xFFFADBD8);
      case 'Completed':
        return const Color(0xFFD5F5E3);
      case 'Cancelled':
        return const Color(0xFFF5E6E6);
      default:
        return const Color(0xFFF0F0F0);
    }
  }

  Color _statusText(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF39C12);
      case 'Accepted':
        return const Color(0xFF6950F4);
      case 'In Progress':
        return const Color(0xFF5D5FEF);
      case 'Rejected':
        return const Color(0xFFE74C3C);
      case 'Completed':
        return const Color(0xFF27AE60);
      case 'Cancelled':
        return const Color(0xFFB23B3B);
      default:
        return Colors.black54;
    }
  }

  bool _isStepDone(String step) => _historyStatuses.contains(step);

  @override
  Widget build(BuildContext context) {
    final status = (_details['status'] as String?) ?? 'Pending';
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
        title: const Text(
          'Booking Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _statusBg(status),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _statusText(status),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildBookingInfoCard(),
                  const SizedBox(height: 16),
                  _buildServiceProviderCard(),
                  const SizedBox(height: 16),
                  _buildPaymentMethodCard(),
                  const SizedBox(height: 16),
                  _buildServiceSummaryCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Booking Id: ',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: (_details['id'] as String?) ?? '',
                            style: const TextStyle(color: Color(0xFF6950F4)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (_details['date'] as String?) ?? '',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressTracker(),
          const SizedBox(height: 24),
          const Text(
            'Booking Summary',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Booking Date:', (_details['date'] as String?) ?? ''),
          const SizedBox(height: 6),
          _buildSummaryRow('Address:', (_details['address'] as String?) ?? ''),
          const SizedBox(height: 12),
          _buildBookedByRow(),
        ],
      ),
    );
  }

  Widget _buildBookedByRow() {
    final customerName = (_details['customerName'] as String?) ?? '';
    final customerAvatarUrl = (_details['customerAvatarUrl'] as String?) ?? '';
    final ImageProvider? avatarProvider =
        customerAvatarUrl.isEmpty ? null : NetworkImage(customerAvatarUrl);

    return Row(
      children: [
        const SizedBox(
          width: 100,
          child: Text(
            'Booked By:',
            style: TextStyle(
              fontFamily: 'Inter',
              color: Colors.black38,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFE8F4FD),
            image: avatarProvider == null
                ? null
                : DecorationImage(image: avatarProvider, fit: BoxFit.cover),
          ),
          child: avatarProvider == null
              ? const Icon(Icons.person, size: 16, color: Colors.black54)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            customerName,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black38,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTracker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProgressStep('Accepted', _isStepDone('accepted')),
        Expanded(child: Container(height: 1, color: Colors.black12)),
        _buildProgressStep('In progress', _isStepDone('in_progress')),
        Expanded(child: Container(height: 1, color: Colors.black12)),
        _buildProgressStep('Completed', _isStepDone('completed')),
        Expanded(child: Container(height: 1, color: Colors.black12)),
        _buildProgressStep('Rejected', _isStepDone('rejected') || _isStepDone('cancelled')),
      ],
    );
  }

  Widget _buildProgressStep(String label, bool isDone) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFF6950F4) : const Color(0xFFF0F0F0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 14,
            color: isDone ? Colors.white : Colors.black38,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isDone ? const Color(0xFF6950F4) : Colors.black38,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceProviderCard() {
    final providerAvatarUrl = (_details['providerAvatarUrl'] as String?) ?? '';
    final ImageProvider? providerAvatar =
        providerAvatarUrl.isEmpty ? null : NetworkImage(providerAvatarUrl);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Service Provider',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Write Review',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                      image: providerAvatar == null
                          ? null
                          : DecorationImage(
                              image: providerAvatar,
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: providerAvatar == null
                        ? const Icon(Icons.person, size: 30, color: Colors.black54)
                        : null,
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (_details['providerName'] as String?) ?? '',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildActionBtn(Icons.phone, 'Call', const Color(0xFF6950F4), Colors.white),
                      const SizedBox(width: 10),
                      _buildActionBtn(
                          Icons.chat_outlined, 'Chat', const Color(0xFFF5F5F5), const Color(0xFF4285F4)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, Color bgColor, Color fgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: fgColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    final paymentStatus = (_details['paymentStatus'] as String?) ?? 'Unpaid';
    final paid = paymentStatus == 'Paid';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: paid ? const Color(0xFFD5F5E3) : const Color(0xFFFADBD8),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  paymentStatus,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: paid ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Payment by: ${_details['paymentMethod'] ?? 'Offline'}',
            style: const TextStyle(
              fontFamily: 'Inter',
              color: Colors.black38,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Total Amount:',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.black38,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                (_details['totalAmount'] as String?) ?? (_details['price'] as String?) ?? '',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Summary',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 16),
          Text(
            (_details['serviceName'] as String?) ?? '',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Qty: ',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black38,
                  ),
                  children: [
                    TextSpan(
                      text: '${_details['quantity'] ?? 1}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Text(
                (_details['unitPrice'] as String?) ?? '',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
