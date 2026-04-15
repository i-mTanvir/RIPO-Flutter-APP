import 'package:supabase_flutter/supabase_flutter.dart';

class ChatThread {
  const ChatThread({
    required this.conversationId,
    required this.peerUserId,
    required this.peerName,
    required this.peerRole,
    required this.peerAvatarUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  final String conversationId;
  final String peerUserId;
  final String peerName;
  final String peerRole;
  final String peerAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;

  bool get hasUnread => unreadCount > 0;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: (map['id'] as String?) ?? '',
      conversationId: (map['conversation_id'] as String?) ?? '',
      senderId: (map['sender_id'] as String?) ?? '',
      content: ((map['content'] as String?) ?? '').trim(),
      isRead: map['is_read'] == true,
      createdAt: ChatService.parseTimestamp(
        map['created_at'],
      ),
    );
  }

  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage copyWith({
    bool? isRead,
    String? content,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ChatUserCandidate {
  const ChatUserCandidate({
    required this.id,
    required this.fullName,
    required this.role,
    required this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String role;
  final String avatarUrl;
}

class ChatService {
  ChatService._();

  static final SupabaseClient _client = Supabase.instance.client;

  static String? get currentUserId => _client.auth.currentUser?.id;

  static DateTime parseTimestamp(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  static Future<List<ChatThread>> fetchThreads() async {
    final myId = currentUserId;
    if (myId == null) {
      return const <ChatThread>[];
    }

    final rows = await _client
        .from('conversations')
        .select(
            'id, customer_id, provider_id, last_message, last_message_at, created_at')
        .or('customer_id.eq.$myId,provider_id.eq.$myId')
        .order('last_message_at', ascending: false, nullsFirst: false)
        .order('created_at', ascending: false);

    final conversationRows = List<Map<String, dynamic>>.from(rows);
    if (conversationRows.isEmpty) {
      return const <ChatThread>[];
    }

    final conversationIds = conversationRows
        .map((row) => row['id'] as String?)
        .whereType<String>()
        .toList();

    final peerUserIds = <String>{};
    for (final row in conversationRows) {
      final first = row['customer_id'] as String?;
      final second = row['provider_id'] as String?;
      if (first == null || second == null) {
        continue;
      }
      peerUserIds.add(first == myId ? second : first);
    }

    final profileById = <String, Map<String, dynamic>>{};
    if (peerUserIds.isNotEmpty) {
      final profileRows = await _client
          .from('profiles')
          .select('id, full_name, role, avatar_url')
          .inFilter('id', peerUserIds.toList());

      for (final row in List<Map<String, dynamic>>.from(profileRows)) {
        final id = row['id'] as String?;
        if (id != null) {
          profileById[id] = row;
        }
      }
    }

    final unreadCountByConversation = <String, int>{};
    if (conversationIds.isNotEmpty) {
      final unreadRows = await _client
          .from('messages')
          .select('conversation_id')
          .inFilter('conversation_id', conversationIds)
          .neq('sender_id', myId)
          .eq('is_read', false);

      for (final row in List<Map<String, dynamic>>.from(unreadRows)) {
        final conversationId = row['conversation_id'] as String?;
        if (conversationId == null) {
          continue;
        }
        unreadCountByConversation.update(
          conversationId,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final threads = <ChatThread>[];
    for (final row in conversationRows) {
      final conversationId = row['id'] as String?;
      final first = row['customer_id'] as String?;
      final second = row['provider_id'] as String?;
      if (conversationId == null || first == null || second == null) {
        continue;
      }

      final peerId = first == myId ? second : first;
      final peerProfile = profileById[peerId];
      final peerName = _nameOrFallback(
        (peerProfile?['full_name'] as String?)?.trim(),
        peerId,
      );
      final peerRole = ((peerProfile?['role'] as String?) ?? 'customer').trim();
      final peerAvatarUrl =
          ((peerProfile?['avatar_url'] as String?) ?? '').trim();

      final lastMessage = ((row['last_message'] as String?) ?? '').trim();
      final fallbackTime = parseTimestamp(row['created_at']);
      final lastTime = row['last_message_at'] == null
          ? fallbackTime
          : parseTimestamp(row['last_message_at']);

      threads.add(
        ChatThread(
          conversationId: conversationId,
          peerUserId: peerId,
          peerName: peerName,
          peerRole: peerRole,
          peerAvatarUrl: peerAvatarUrl,
          lastMessage: lastMessage,
          lastMessageAt: lastTime,
          unreadCount: unreadCountByConversation[conversationId] ?? 0,
        ),
      );
    }

    threads.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return threads;
  }

  static Future<List<ChatMessage>> fetchMessages({
    required String conversationId,
  }) async {
    final rows = await _client
        .from('messages')
        .select('id, conversation_id, sender_id, content, is_read, created_at')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(rows)
        .map(ChatMessage.fromMap)
        .toList();
  }

  static Future<String> getOrCreateConversationId({
    required String peerUserId,
  }) async {
    final myId = currentUserId;
    if (myId == null) {
      throw const AuthException('You must be logged in to chat.');
    }
    if (peerUserId == myId) {
      throw const AuthException('Cannot create a conversation with yourself.');
    }

    final existing = await _findConversationByParticipants(
      userA: myId,
      userB: peerUserId,
    );

    if (existing != null && existing['id'] is String) {
      return existing['id'] as String;
    }

    final orderedPair = _orderedPair(myId, peerUserId);
    try {
      final inserted = await _client
          .from('conversations')
          .insert({
            'customer_id': orderedPair.first,
            'provider_id': orderedPair.second,
            'last_message': null,
            'last_message_at': null,
          })
          .select('id')
          .single();

      return inserted['id'] as String;
    } on PostgrestException {
      // Another client may have created the same conversation concurrently,
      // or legacy duplicate pairs may exist in reverse order.
      final recovered = await _findConversationByParticipants(
        userA: myId,
        userB: peerUserId,
      );
      if (recovered != null && recovered['id'] is String) {
        return recovered['id'] as String;
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> _findConversationByParticipants({
    required String userA,
    required String userB,
  }) {
    return _client
        .from('conversations')
        .select('id, created_at')
        .or(
          'and(customer_id.eq.$userA,provider_id.eq.$userB),'
          'and(customer_id.eq.$userB,provider_id.eq.$userA)',
        )
        .order('created_at', ascending: true)
        .limit(1)
        .maybeSingle();
  }

  static Future<ChatMessage> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final myId = currentUserId;
    if (myId == null) {
      throw const AuthException('You must be logged in to send messages.');
    }

    final message = content.trim();
    if (message.isEmpty) {
      throw const AuthException('Message cannot be empty.');
    }

    final inserted = await _client
        .from('messages')
        .insert({
          'conversation_id': conversationId,
          'sender_id': myId,
          'content': message,
          'is_read': false,
        })
        .select('id, conversation_id, sender_id, content, is_read, created_at')
        .single();

    return ChatMessage.fromMap(inserted);
  }

  static Future<void> markConversationAsRead({
    required String conversationId,
  }) async {
    final myId = currentUserId;
    if (myId == null) {
      return;
    }

    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', myId)
        .eq('is_read', false);
  }

  static Future<List<ChatUserCandidate>> fetchChatCandidates() async {
    final myId = currentUserId;
    if (myId == null) {
      return const <ChatUserCandidate>[];
    }

    final rows = await _client
        .from('profiles')
        .select('id, full_name, role, avatar_url, is_active')
        .neq('id', myId)
        .eq('is_active', true)
        .order('full_name', ascending: true);

    final candidates = <ChatUserCandidate>[];
    for (final row in List<Map<String, dynamic>>.from(rows)) {
      final id = row['id'] as String?;
      if (id == null || id.isEmpty) {
        continue;
      }

      candidates.add(
        ChatUserCandidate(
          id: id,
          fullName: _nameOrFallback((row['full_name'] as String?)?.trim(), id),
          role: ((row['role'] as String?) ?? 'customer').trim(),
          avatarUrl: ((row['avatar_url'] as String?) ?? '').trim(),
        ),
      );
    }

    return candidates;
  }

  static ({String first, String second}) _orderedPair(String a, String b) {
    return a.compareTo(b) <= 0 ? (first: a, second: b) : (first: b, second: a);
  }

  static String _nameOrFallback(String? value, String fallbackId) {
    if (value == null || value.isEmpty) {
      final suffix = fallbackId.length < 6
          ? fallbackId
          : fallbackId.substring(fallbackId.length - 6);
      return 'User $suffix';
    }
    return value;
  }
}
