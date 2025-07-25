import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:yapper/Services/recent_chats_manager.dart';
import 'package:yapper/Services/socket_services.dart';
import 'package:yapper/Pages/chat_page.dart';
import 'package:yapper/Services/token_manager.dart';
import 'package:yapper/Util/app_routes.dart';
import 'package:yapper/Services/api_services.dart';

class AllChatPage extends StatefulWidget {
  final String? userId;

  const AllChatPage({super.key, required this.userId});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  final SocketService _socketService = SocketService();
   String? userId;
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
     _initUserAndSocket();
  }
  Future<void> _initUserAndSocket() async {
    userId = widget.userId;

    if (userId == null) {
      final token = await TokenManager.getToken();
      if (token != null && !JwtDecoder.isExpired(token)) {
        final decoded = JwtDecoder.decode(token);
        userId = decoded['userId'];
      }
    }

    if (userId == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.loginPage);
      }
      return;
    }

   
    _connectSocket();
    setState(() => _isLoading = false);
  }




  void _connectSocket() {
    _socketService.onAllChatsReceived = _onAllChatsReceived;
    _socketService.connect(widget.userId!, _onMatchFound); 
    _socketService.requestAllChats(widget.userId!);
  }

  void _onAllChatsReceived(List<Map<String, dynamic>> chatList) {
      print('🔁 Received all chats: ${chatList.length}');
     for (var chat in chatList) {
    RecentChatsManager().addOrUpdateChat(RecentChat(
      chatRoomId: chat['chatRoomId'],
      receiverId: chat['receiverId'],
      receiverNickname: chat['receiverNickname'],
      lastMessage: chat['lastMessage'],
      lastMessageTime: DateTime.parse(chat['lastMessageTime']),
    ));
  }
    setState(() {}); // Triggers rebuild to show updated chat list
  }

   void _onMatchFound(String chatRoomId, String receiverId, String receiverNickname) {

    RecentChatsManager().addOrUpdateChat(
    RecentChat(
      chatRoomId: chatRoomId,
      receiverId: receiverId,
      receiverNickname: receiverNickname,
      lastMessage: '', 
      lastMessageTime: DateTime.now(),
    ),
  );
  if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatRoomId: chatRoomId,
          userId: userId!,
          receiverId: receiverId,
          receiverNickname: receiverNickname,
        ),
      ),
    );
  }

  void _goToChatPage(RecentChat chat) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatRoomId: chat.chatRoomId,
          userId: widget.userId!,
          receiverId: chat.receiverId,
          receiverNickname: chat.receiverNickname,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.removeMatchFoundListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<RecentChat> chats = RecentChatsManager().recentChats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.deepPurple,
      ),
      body: chats.isEmpty
          ? const Center(child: Text("No recent chats"))
          : ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(chat.receiverNickname),
                  subtitle: Text(chat.lastMessage),
                  trailing: Text(
                    '${chat.lastMessageTime.hour}:${chat.lastMessageTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () => _goToChatPage(chat),
                );
              },
            ),
    );
  }
}
