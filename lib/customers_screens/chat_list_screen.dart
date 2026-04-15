import 'package:flutter/material.dart';
import 'package:ripo/core/chat_service.dart';
import 'package:ripo/customers_screens/chat_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatThread> _threads = const <ChatThread>[];
  bool _isLoading = true;
  String? _errorMessage;
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _loadThreads();
    _subscribeToRealtime();
  }

  @override
  void dispose() {
    final channel = _realtimeChannel;
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel);
    }
    super.dispose();
  }

  Future<void> _loadThreads({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final threads = await ChatService.fetchThreads();
      if (!mounted) {
        return;
      }

      setState(() {
        _threads = threads;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load messages.';
      });
    }
  }

  void _subscribeToRealtime() {
    final userId = ChatService.currentUserId;
    if (userId == null) {
      return;
    }

    final client = Supabase.instance.client;
    final channel = client.channel('chat-list-$userId');

    void refresh(_) => _loadThreads(showLoader: false);

    channel
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        callback: refresh,
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'messages',
        callback: refresh,
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'conversations',
        callback: refresh,
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'conversations',
        callback: refresh,
      )
      ..subscribe();

    _realtimeChannel = channel;
  }

  Future<void> _openNewChatPicker() async {
    List<ChatUserCandidate> candidates;
    try {
      candidates = await ChatService.fetchChatCandidates();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load users.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No users found to start a chat.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<ChatUserCandidate>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Start New Chat',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: candidates.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (context, index) {
                    final candidate = candidates[index];
                    final avatarProvider = candidate.avatarUrl.isEmpty
                        ? null
                        : NetworkImage(candidate.avatarUrl);

                    return ListTile(
                      onTap: () => Navigator.of(context).pop(candidate),
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFF2EFFF),
                        backgroundImage: avatarProvider,
                        child: avatarProvider == null
                            ? const Icon(Icons.person_rounded,
                                color: Color(0xFF6950F4))
                            : null,
                      ),
                      title: Text(
                        candidate.fullName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        candidate.role.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          peerName: selected.fullName,
          peerUserId: selected.id,
          peerRole: selected.role,
          peerAvatarUrl: selected.avatarUrl,
        ),
      ),
    );

    await _loadThreads(showLoader: false);
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final sameDay = local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    if (sameDay) {
      final time = TimeOfDay.fromDateTime(local);
      return time.format(context);
    }
    return '${local.month}/${local.day}/${local.year.toString().substring(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontFamily: 'Inter',
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Color(0xFF6950F4)),
            onPressed: _openNewChatPicker,
            tooltip: 'New chat',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadThreads(showLoader: false),
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_errorMessage != null) {
              return ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (_threads.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 160),
                  Center(
                    child: Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Tap the edit icon to start chatting.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _threads.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Colors.black12),
              itemBuilder: (context, index) {
                final thread = _threads[index];
                final hasUnread = thread.hasUnread;
                final avatarProvider = thread.peerAvatarUrl.isEmpty
                    ? null
                    : NetworkImage(thread.peerAvatarUrl);

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          conversationId: thread.conversationId,
                          peerUserId: thread.peerUserId,
                          peerName: thread.peerName,
                          peerRole: thread.peerRole,
                          peerAvatarUrl: thread.peerAvatarUrl,
                        ),
                      ),
                    );
                    await _loadThreads(showLoader: false);
                  },
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xFFF2EFFF),
                    backgroundImage: avatarProvider,
                    child: avatarProvider == null
                        ? const Icon(Icons.person,
                            size: 28, color: Color(0xFF6950F4))
                        : null,
                  ),
                  title: Text(
                    thread.peerName,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      thread.lastMessage.isEmpty
                          ? 'Start a conversation'
                          : thread.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight:
                            hasUnread ? FontWeight.w700 : FontWeight.w500,
                        color: hasUnread ? Colors.black87 : Colors.black54,
                      ),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDate(thread.lastMessageAt),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (hasUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6950F4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            thread.unreadCount > 99
                                ? '99+'
                                : '${thread.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
