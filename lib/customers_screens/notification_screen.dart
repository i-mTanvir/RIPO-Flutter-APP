import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

enum NotifType { booking, offer, system, promo }

class NotifItem {
  final String id;
  final NotifType type;
  final String title;
  final String body;
  final String timeAgo;
  bool isRead;

  NotifItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Sample data ──────────────────────────────────────────────────────────

  final List<NotifItem> _notifications = [
    NotifItem(
      id: '1',
      type: NotifType.booking,
      title: 'Booking Confirmed!',
      body:
          'Your AC Servicing booking has been confirmed for tomorrow at 10:00 AM.',
      timeAgo: '2 min ago',
      isRead: false,
    ),
    NotifItem(
      id: '2',
      type: NotifType.offer,
      title: '🎉 Special Offer – 50% OFF',
      body:
          'House Cleaning service is 50% off today only. Book now before offer expires!',
      timeAgo: '15 min ago',
      isRead: false,
    ),
    NotifItem(
      id: '3',
      type: NotifType.booking,
      title: 'Provider On The Way',
      body:
          'Your provider Rahim Ahmed is heading to your location. ETA: 20 minutes.',
      timeAgo: '1 hr ago',
      isRead: false,
    ),
    NotifItem(
      id: '4',
      type: NotifType.system,
      title: 'Payment Successful',
      body:
          'Payment of ৳1,200 for AC Servicing was received successfully. Thank you!',
      timeAgo: '3 hrs ago',
      isRead: true,
    ),
    NotifItem(
      id: '5',
      type: NotifType.promo,
      title: 'New Services Available',
      body:
          'Water Filter Installation and Paint Services are now available in your area.',
      timeAgo: '5 hrs ago',
      isRead: true,
    ),
    NotifItem(
      id: '6',
      type: NotifType.booking,
      title: 'Service Completed ✅',
      body:
          'Your Fan & Light Service has been completed. Please rate your experience.',
      timeAgo: 'Yesterday',
      isRead: true,
    ),
    NotifItem(
      id: '7',
      type: NotifType.offer,
      title: 'Weekend Deal – 30% OFF',
      body:
          'Laundry & Washing service is 30% OFF this weekend. Don\'t miss out!',
      timeAgo: '2 days ago',
      isRead: true,
    ),
    NotifItem(
      id: '8',
      type: NotifType.system,
      title: 'Profile Updated',
      body: 'Your profile information has been updated successfully.',
      timeAgo: '3 days ago',
      isRead: true,
    ),
    NotifItem(
      id: '9',
      type: NotifType.promo,
      title: 'Refer & Earn 🎁',
      body:
          'Invite friends and earn ৳200 credit for each successful referral. Share now!',
      timeAgo: '1 week ago',
      isRead: true,
    ),
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  List<NotifItem> get _allNotifications => _notifications;

  List<NotifItem> get _bookingNotifications =>
      _notifications.where((n) => n.type == NotifType.booking).toList();

  List<NotifItem> get _promoNotifications => _notifications
      .where((n) => n.type == NotifType.offer || n.type == NotifType.promo)
      .toList();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'All notifications marked as read',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        backgroundColor: const Color(0xFF6950F4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markSingleRead(NotifItem item) {
    setState(() => item.isRead = true);
  }

  void _deleteNotification(NotifItem item) {
    setState(() => _notifications.remove(item));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotifList(_allNotifications),
                _buildNotifList(_bookingNotifications),
                _buildNotifList(_promoNotifications),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB8A8F8), Color(0xFFE8D8FF)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 16, 20),
          child: Row(
            children: [
              // Back button
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.black87, size: 20),
              ),

              // Title + badge
              Expanded(
                child: Row(
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    if (_unreadCount > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6950F4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Mark all read
              if (_unreadCount > 0)
                GestureDetector(
                  onTap: _markAllRead,
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6950F4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ───────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        labelColor: const Color(0xFF6950F4),
        unselectedLabelColor: Colors.black45,
        indicatorColor: const Color(0xFF6950F4),
        indicatorWeight: 3,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Bookings'),
          Tab(text: 'Promotions'),
        ],
      ),
    );
  }

  // ── Notification List ────────────────────────────────────────────────────

  Widget _buildNotifList(List<NotifItem> items) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // Group by date for section dividers
    final unread = items.where((n) => !n.isRead).toList();
    final read = items.where((n) => n.isRead).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        if (unread.isNotEmpty) ...[
          _buildSectionLabel('New'),
          ...unread.map((n) => _buildNotifCard(n)),
        ],
        if (read.isNotEmpty) ...[
          _buildSectionLabel('Earlier'),
          ...read.map((n) => _buildNotifCard(n)),
        ],
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black38,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildNotifCard(NotifItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      onDismissed: (_) => _deleteNotification(item),
      child: GestureDetector(
        onTap: () => _markSingleRead(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: BoxDecoration(
            color: item.isRead ? Colors.white : const Color(0xFFF0EEFF),
            borderRadius: BorderRadius.circular(14),
            border: item.isRead
                ? null
                : Border.all(color: const Color(0xFFDDD5FF), width: 1),
            boxShadow: [
              BoxShadow(
                color: item.isRead
                    ? const Color(0x0A000000)
                    : const Color(0x186950F4),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container
                _buildNotifIcon(item.type),
                const SizedBox(width: 14),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: item.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          // Unread dot
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 8, top: 4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6950F4),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.body,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 12, color: Colors.black38),
                          const SizedBox(width: 4),
                          Text(
                            item.timeAgo,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotifIcon(NotifType type) {
    late IconData icon;
    late Color bg;
    late Color iconColor;

    switch (type) {
      case NotifType.booking:
        icon = Icons.calendar_month_rounded;
        bg = const Color(0xFFE8F4FD);
        iconColor = const Color(0xFF1E88E5);
        break;
      case NotifType.offer:
        icon = Icons.local_offer_rounded;
        bg = const Color(0xFFFFF3E0);
        iconColor = const Color(0xFFFF8F00);
        break;
      case NotifType.system:
        icon = Icons.check_circle_rounded;
        bg = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF43A047);
        break;
      case NotifType.promo:
        icon = Icons.campaign_rounded;
        bg = const Color(0xFFEDE9FF);
        iconColor = const Color(0xFF6950F4);
        break;
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 44,
              color: Color(0xFF6950F4),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Notifications',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You're all caught up!\nWe'll notify you when something new arrives.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.black38,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
