import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProviderJobsScreen extends StatefulWidget {
  const ProviderJobsScreen({super.key});

  @override
  State<ProviderJobsScreen> createState() => _ProviderJobsScreenState();
}

class _ProviderJobsScreenState extends State<ProviderJobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _updatingBookingId;
  List<Map<String, dynamic>> _jobs = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadJobs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    final client = Supabase.instance.client;
    final providerId = client.auth.currentUser?.id;
    if (providerId == null) {
      if (!mounted) return;
      setState(() {
        _jobs = <Map<String, dynamic>>[];
        _isLoading = false;
      });
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final rows = await client
          .from('bookings')
          .select('''
            id,
            booking_code,
            booking_date,
            time_slot_text,
            total_amount,
            booking_status,
            customer_id,
            created_at,
            locations(address_line, area, city),
            services(name)
          ''')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      final bookings = List<Map<String, dynamic>>.from(rows);
      final customerIds = bookings
          .map((r) => r['customer_id'] as String?)
          .whereType<String>()
          .toSet()
          .toList();

      final customerNameById = <String, String>{};
      final customerAvatarById = <String, String>{};
      if (customerIds.isNotEmpty) {
        final profileRows = await client
            .from('profiles')
            .select('id, full_name, avatar_url')
            .inFilter('id', customerIds);
        for (final p in List<Map<String, dynamic>>.from(profileRows)) {
          final id = p['id'] as String?;
          final name = (p['full_name'] as String?)?.trim() ?? '';
          final avatarUrl = (p['avatar_url'] as String?)?.trim() ?? '';
          if (id != null) {
            customerNameById[id] = name;
            customerAvatarById[id] = avatarUrl;
          }
        }
      }

      final mapped = bookings.map((row) {
        final serviceMap = row['services'] as Map<String, dynamic>?;
        final locationMap = row['locations'] as Map<String, dynamic>?;
        final customerId = row['customer_id'] as String?;
        final amount = (row['total_amount'] as num?)?.toDouble() ?? 0;
        final addressLine = (locationMap?['address_line'] as String?)?.trim() ?? '';
        final area = (locationMap?['area'] as String?)?.trim() ?? '';
        final city = (locationMap?['city'] as String?)?.trim() ?? '';

        return <String, dynamic>{
          'id': row['id'],
          'bookingCode': (row['booking_code'] as String?)?.trim() ?? '',
          'statusRaw': (row['booking_status'] as String?)?.trim() ?? 'pending',
          'customerName': customerId == null ? '' : (customerNameById[customerId] ?? ''),
          'customerAvatarUrl':
              customerId == null ? '' : (customerAvatarById[customerId] ?? ''),
          'serviceName': (serviceMap?['name'] as String?)?.trim() ?? '',
          'address': [addressLine, area, city].where((e) => e.isNotEmpty).join(', '),
          'date': _formatBookingDate(
            (row['booking_date'] as String?)?.trim() ?? '',
            (row['time_slot_text'] as String?)?.trim() ?? '',
          ),
          'price': amount % 1 == 0 ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2),
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _jobs = mapped;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load jobs.')),
      );
    }
  }

  Future<void> _updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    if (_updatingBookingId != null) return;
    final client = Supabase.instance.client;
    final providerId = client.auth.currentUser?.id;
    if (providerId == null) return;

    setState(() => _updatingBookingId = bookingId);
    try {
      await client
          .from('bookings')
          .update({'booking_status': status}).eq('id', bookingId);
      await client.from('booking_status_history').insert({
        'booking_id': bookingId,
        'status': status,
        'changed_by': providerId,
        'note': 'Status updated by provider.',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job ${_prettyStatus(status)}.')),
      );
      await _loadJobs();
    } on PostgrestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update booking status.')),
      );
    } finally {
      if (mounted) setState(() => _updatingBookingId = null);
    }
  }

  String _formatBookingDate(String bookingDate, String slot) {
    if (bookingDate.isEmpty && slot.isEmpty) return '';
    final dt = DateTime.tryParse(bookingDate);
    if (dt == null) return '$bookingDate ${slot.isEmpty ? '' : '- $slot'}'.trim();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateText = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    return slot.isEmpty ? dateText : '$dateText, $slot';
  }

  String _prettyStatus(String raw) {
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

  List<Map<String, dynamic>> get _requestJobs =>
      _jobs.where((j) => (j['statusRaw'] as String) == 'pending').toList();

  List<Map<String, dynamic>> get _activeJobs => _jobs
      .where((j) => ['accepted', 'in_progress'].contains(j['statusRaw'] as String))
      .toList();

  List<Map<String, dynamic>> get _completedJobs => _jobs
      .where((j) => ['completed', 'rejected', 'cancelled'].contains(j['statusRaw'] as String))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildTabBar(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsTab(),
                    _buildActiveTab(),
                    _buildCompletedTab(),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Job Management',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadJobs,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500),
        labelColor: const Color(0xFF6950F4),
        unselectedLabelColor: Colors.black45,
        indicatorColor: const Color(0xFF6950F4),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'Requests'),
          Tab(text: 'Active'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildRequestsTab() {
    if (_requestJobs.isEmpty) return _buildEmpty('No pending requests.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _requestJobs.length,
      itemBuilder: (_, i) {
        final j = _requestJobs[i];
        final bookingId = j['id'] as String;
        final isUpdating = _updatingBookingId == bookingId;
        return Padding(
          padding: EdgeInsets.only(bottom: i == _requestJobs.length - 1 ? 0 : 16),
          child: _buildJobCard(
            status: 'Pending Request',
            statusColor: const Color(0xFFFF8F00),
            statusBgColor: const Color(0xFFFFF3E0),
            name: (j['customerName'] as String).isEmpty ? 'Customer' : j['customerName'] as String,
            service: j['serviceName'] as String,
            address: (j['address'] as String).isEmpty ? 'Address not provided' : j['address'] as String,
            date: j['date'] as String,
            price: j['price'] as String,
            customerAvatarUrl: j['customerAvatarUrl'] as String,
            showContactOptions: false,
            actionButtons: _buildActionButtons(
              negativeLabel: 'Decline',
              positiveLabel: 'Accept',
              onNegative: isUpdating
                  ? null
                  : () => _updateBookingStatus(bookingId: bookingId, status: 'rejected'),
              onPositive: isUpdating
                  ? null
                  : () => _updateBookingStatus(bookingId: bookingId, status: 'accepted'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveTab() {
    if (_activeJobs.isEmpty) return _buildEmpty('No active jobs.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeJobs.length,
      itemBuilder: (_, i) {
        final j = _activeJobs[i];
        final bookingId = j['id'] as String;
        final isUpdating = _updatingBookingId == bookingId;
        final statusRaw = j['statusRaw'] as String;
        return Padding(
          padding: EdgeInsets.only(bottom: i == _activeJobs.length - 1 ? 0 : 16),
          child: _buildJobCard(
            status: statusRaw == 'accepted' ? 'Accepted' : 'In Progress',
            statusColor: const Color(0xFF1E88E5),
            statusBgColor: const Color(0xFFE8F4FD),
            name: (j['customerName'] as String).isEmpty ? 'Customer' : j['customerName'] as String,
            service: j['serviceName'] as String,
            address: (j['address'] as String).isEmpty ? 'Address not provided' : j['address'] as String,
            date: j['date'] as String,
            price: j['price'] as String,
            customerAvatarUrl: j['customerAvatarUrl'] as String,
            showContactOptions: true,
            actionButtons: _buildActionButtons(
              negativeLabel: 'Cancel Job',
              positiveLabel: statusRaw == 'accepted' ? 'Start Job' : 'Mark Completed',
              onNegative: isUpdating
                  ? null
                  : () => _updateBookingStatus(bookingId: bookingId, status: 'cancelled'),
              onPositive: isUpdating
                  ? null
                  : () => _updateBookingStatus(
                        bookingId: bookingId,
                        status: statusRaw == 'accepted' ? 'in_progress' : 'completed',
                      ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    if (_completedJobs.isEmpty) return _buildEmpty('No completed/rejected jobs yet.');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedJobs.length,
      itemBuilder: (_, i) {
        final j = _completedJobs[i];
        final statusRaw = j['statusRaw'] as String;
        final isCompleted = statusRaw == 'completed';
        final statusColor = isCompleted
            ? const Color(0xFF43A047)
            : const Color(0xFFE74C3C);
        final statusBgColor = isCompleted
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFADBD8);
        return Padding(
          padding: EdgeInsets.only(bottom: i == _completedJobs.length - 1 ? 0 : 16),
          child: _buildJobCard(
            status: _prettyStatus(statusRaw),
            statusColor: statusColor,
            statusBgColor: statusBgColor,
            name: (j['customerName'] as String).isEmpty ? 'Customer' : j['customerName'] as String,
            service: j['serviceName'] as String,
            address: (j['address'] as String).isEmpty ? 'Address not provided' : j['address'] as String,
            date: j['date'] as String,
            price: j['price'] as String,
            customerAvatarUrl: j['customerAvatarUrl'] as String,
            isCompleted: isCompleted,
          ),
        );
      },
    );
  }

  Widget _buildEmpty(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Colors.black45,
        ),
      ),
    );
  }

  Widget _buildJobCard({
    required String status,
    required Color statusColor,
    required Color statusBgColor,
    required String name,
    required String service,
    required String address,
    required String date,
    required String price,
    required String customerAvatarUrl,
    bool showContactOptions = false,
    bool isCompleted = false,
    Widget? actionButtons,
  }) {
    final ImageProvider? avatarProvider =
        customerAvatarUrl.isEmpty ? null : NetworkImage(customerAvatarUrl);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                'BDT $price',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4FD),
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: avatarProvider == null
                    ? const Icon(Icons.person, color: Color(0xFF1E88E5), size: 26)
                    : Image(
                        image: avatarProvider,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Color(0xFF6950F4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (showContactOptions)
                Row(
                  children: [
                    _buildIconButton(Icons.chat_bubble_rounded, const Color(0xFF6950F4)),
                    const SizedBox(width: 8),
                    _buildIconButton(Icons.call_rounded, const Color(0xFF43A047)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.black12, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: Colors.black38),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.black38),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.black54),
                ),
              ),
            ],
          ),
          if (actionButtons != null) ...[
            const SizedBox(height: 20),
            actionButtons,
          ],
          if (isCompleted) ...[
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF43A047)),
                SizedBox(width: 6),
                Text(
                  'Payment Received',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF43A047),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildActionButtons({
    required String negativeLabel,
    required String positiveLabel,
    required VoidCallback? onNegative,
    required VoidCallback? onPositive,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onNegative,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF5252)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              negativeLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFFF5252),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onPositive,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6950F4),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(
              positiveLabel,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
