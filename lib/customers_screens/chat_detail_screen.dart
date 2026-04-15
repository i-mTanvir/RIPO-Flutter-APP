// lib\customers_screens\chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:ripo/core/chat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    super.key,
    required this.peerName,
    this.peerUserId,
    this.conversationId,
    this.peerRole,
    this.peerAvatarUrl,
  });

  final String peerName;
  final String? peerUserId;
  final String? conversationId;
  final String? peerRole;
  final String? peerAvatarUrl;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = <ChatMessage>[];

  RealtimeChannel? _channel;
  String? _conversationId;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;

  String get _myUserId => ChatService.currentUserId ?? '';
  bool get _hasText => _messageController.text.trim().isNotEmpty;
  bool get _canSend => !_isSending && !_isLoading && _hasText;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onComposerChanged);
    _conversationId = widget.conversationId;
    _bootstrapChat();
  }

  void _onComposerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _messageController.removeListener(_onComposerChanged);
    _messageController.dispose();
    _scrollController.dispose();
    final channel = _channel;
    if (channel != null) {
      Supabase.instance.client.removeChannel(channel);
    }
    super.dispose();
  }

  Future<void> _bootstrapChat() async {
    if (_myUserId.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please login to use chat.';
      });
      return;
    }

    try {
      if ((_conversationId ?? '').isEmpty) {
        final peerId = widget.peerUserId;
        if (peerId == null || peerId.isEmpty) {
          throw const AuthException('Cannot open chat without a recipient.');
        }
        _conversationId = await ChatService.getOrCreateConversationId(
          peerUserId: peerId,
        );
      }

      final messages = await ChatService.fetchMessages(
        conversationId: _conversationId!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _messages
          ..clear()
          ..addAll(messages);
        _isLoading = false;
      });

      _subscribeToMessages();
      await ChatService.markConversationAsRead(
          conversationId: _conversationId!);
      _scrollToBottom(animated: false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not open this conversation.';
      });
    }
  }

  void _subscribeToMessages() {
    final conversationId = _conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      return;
    }

    final client = Supabase.instance.client;
    final channel = client.channel(
      'chat-$conversationId-${DateTime.now().millisecondsSinceEpoch}',
    );

    channel
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'conversation_id',
          value: conversationId,
        ),
        callback: (payload) async {
          final incoming = ChatMessage.fromMap(payload.newRecord);
          _upsertMessage(incoming);

          if (incoming.senderId != _myUserId) {
            await ChatService.markConversationAsRead(
                conversationId: conversationId);
          }
        },
      )
      ..onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'messages',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'conversation_id',
          value: conversationId,
        ),
        callback: (payload) {
          final updated = ChatMessage.fromMap(payload.newRecord);
          _upsertMessage(updated);
        },
      )
      ..subscribe();

    _channel = channel;
  }

  void _upsertMessage(ChatMessage message) {
    if (!mounted) {
      return;
    }

    setState(() {
      final index = _messages.indexWhere((item) => item.id == message.id);
      if (index >= 0) {
        _messages[index] = message;
      } else {
        _messages.add(message);
      }
      _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    if (_isSending || _isLoading) {
      return;
    }

    final text = _messageController.text.trim();
    if (text.isEmpty) {
      return;
    }

    var conversationId = _conversationId;
    if (conversationId == null || conversationId.isEmpty) {
      final peerId = widget.peerUserId;
      if (peerId == null || peerId.isEmpty) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat recipient is missing.')),
        );
        return;
      }

      try {
        conversationId = await ChatService.getOrCreateConversationId(
          peerUserId: peerId,
        );
        _conversationId = conversationId;
        if (_channel == null) {
          _subscribeToMessages();
        }
      } catch (error) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorTextFrom(error, 'Could not open this chat.')),
          ),
        );
        return;
      }
    }

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final sent = await ChatService.sendMessage(
        conversationId: conversationId,
        content: text,
      );
      _upsertMessage(sent);
      if (!mounted) {
        return;
      }
      setState(() => _isSending = false);
    } catch (error) {
      if (!mounted) {
        return;
      }
      _messageController.text = text;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorTextFrom(error, 'Could not send message.')),
        ),
      );
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      final position = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
        return;
      }
      _scrollController.jumpTo(position);
    });
  }

  String _formatMessageTime(DateTime time) {
    return TimeOfDay.fromDateTime(time.toLocal()).format(context);
  }

  String _errorTextFrom(Object error, String fallback) {
    if (error is AuthException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    if (error is PostgrestException && error.message.trim().isNotEmpty) {
      return error.message;
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = (widget.peerAvatarUrl ?? '').trim().isEmpty
        ? null
        : NetworkImage((widget.peerAvatarUrl ?? '').trim());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: avatarProvider == null
                      ? const Icon(Icons.person,
                          size: 20, color: Colors.black45)
                      : ClipOval(
                          child: Image(
                            image: avatarProvider,
                            width: 36,
                            height: 36,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
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
                  widget.peerName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  (widget.peerRole ?? '').isEmpty
                      ? 'Supabase chat'
                      : '${widget.peerRole} user',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF6950F4), size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded,
                color: Colors.black54, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_errorMessage != null) {
                  return Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                if (_messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isMe = msg.senderId == _myUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            Container(
                              width: 28,
                              height: 28,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person,
                                  size: 16, color: Colors.black45),
                            ),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(16, 10, 14, 8),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? const Color(0xFF6950F4)
                                    : const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    msg.content,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _formatMessageTime(msg.createdAt),
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 10,
                                          color: isMe
                                              ? Colors.white70
                                              : Colors.black45,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          msg.isRead
                                              ? Icons.done_all_rounded
                                              : Icons.done_rounded,
                                          size: 14,
                                          color: msg.isRead
                                              ? const Color(0xFFB3E5FC)
                                              : Colors.white70,
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
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

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(
                10, 10, 10, 24), // Accounts for safer bottom area
            decoration: const BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Colors.black12, width: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFF6950F4), size: 28),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt,
                      color: Colors.black45, size: 24),
                  onPressed: () {},
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      enabled: !_isLoading,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.sentiment_satisfied_rounded,
                              color: Colors.black45),
                          onPressed: () {},
                        ),
                      ),
                      onSubmitted: (_) {
                        _sendMessage();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: _canSend
                      ? const Color(0xFF6950F4)
                      : const Color(0xFFB8AEDC),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _canSend
                        ? () {
                            _sendMessage();
                          }
                        : null,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
