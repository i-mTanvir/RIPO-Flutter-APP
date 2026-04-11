import 'package:flutter/material.dart';
import 'package:ripo/customers_screens/chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Dr. Sojib',
      'lastMessage': 'You reacted ❤️ to "Photo"',
      'time': '3/24/26',
      'isRead': true,
      'isOnline': true,
    },
    {
      'name': 'Abdullah Al Noman',
      'lastMessage': 'Voice call',
      'time': '3/24/26',
      'isRead': true,
      'isOnline': false,
    },
    {
      'name': 'Enaya Jannat',
      'lastMessage': 'I will be there in 10 mins',
      'time': '3/22/26',
      'isRead': false,
      'isOnline': true,
    },
    {
      'name': 'Jihan Apu',
      'lastMessage': 'Can you send the invoice?',
      'time': '3/21/26',
      'isRead': true,
      'isOnline': false,
    },
  ];

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
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: _chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(providerName: chat['name']),
                ),
              );
            },
            leading: Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 30, color: Colors.black45),
                ),
                if (chat['isOnline'] == true)
                  Positioned(
                    bottom: 0,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              chat['name'],
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: chat['isRead'] ? FontWeight.w600 : FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                chat['lastMessage'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: chat['isRead'] ? FontWeight.w500 : FontWeight.w700,
                  color: chat['isRead'] ? Colors.black54 : Colors.black87,
                ),
              ),
            ),
            trailing: Text(
              chat['time'],
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}
