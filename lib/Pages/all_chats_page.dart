import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:yapper/Services/recent_chats_manager.dart';
import 'package:yapper/Services/socket_services.dart';
import 'package:yapper/Pages/chat_page.dart';
import 'package:yapper/Services/token_manager.dart';
import 'package:yapper/Util/app_routes.dart';

class AllChatPage extends StatefulWidget {
  final String? userId;

  const AllChatPage({super.key, this.userId});

  @override
  State<AllChatPage> createState() => _AllChatPageState();
}

class _AllChatPageState extends State<AllChatPage> {
  final SocketService _socketService = SocketService();
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initUserAndSocket();
  }

  Future<void> _initUserAndSocket() async {
    // Get userId from widget or token
    _userId = widget.userId;
    if (_userId == null) {
      final token = await TokenManager.getToken();
      if (token != null && !JwtDecoder.isExpired(token)) {
        final decoded = JwtDecoder.decode(token);
        _userId = decoded['userId'];
      }
    }

    if (_userId == null) {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.loginPage);
      return;
    }

    _connectSocket();
    setState(() => _isLoading = false);
  }

  void _connectSocket() {
    _socketService.onAllChatsReceived = _onAllChatsReceived;
    _socketService.onMatchFound = _onMatchFound;
    _socketService.connect(_userId!, _onMatchFound);
    _socketService.requestAllChats(_userId!);
  }

  void _onAllChatsReceived(List<Map<String, dynamic>> chatList) {
    for (var chat in chatList) {
      RecentChatsManager().addOrUpdateChat(RecentChat(
        chatRoomId: chat['chatRoomId'],
        receiverId: chat['receiverId'],
        receiverNickname: chat['receiverNickname'],
        lastMessage: chat['lastMessage'],
        lastMessageTime: DateTime.parse(chat['lastMessageTime']),
      ));
    }
    if (mounted) setState(() {}); // Rebuild UI with updated chat list
  }

  void _onMatchFound(String chatRoomId, String receiverId, String receiverNickname) {
    RecentChatsManager().addOrUpdateChat(RecentChat(
      chatRoomId: chatRoomId,
      receiverId: receiverId,
      receiverNickname: receiverNickname,
      lastMessage: '',
      lastMessageTime: DateTime.now(),
    ));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatRoomId: chatRoomId,
          userId: _userId!,
          receiverId: receiverId,
          receiverNickname: receiverNickname,
        ),
      ),
    );
  }

  void _goToChatPage(RecentChat chat) {
    if (_userId == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatRoomId: chat.chatRoomId,
          userId: _userId!,
          receiverId: chat.receiverId,
          receiverNickname: chat.receiverNickname,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _socketService.onMatchFound = null;
    _socketService.onAllChatsReceived = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chats = RecentChatsManager().recentChats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : chats.isEmpty
              ? const Center(child: Text("No recent chats"))
              : ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final hour = chat.lastMessageTime.hour.toString().padLeft(2, '0');
                    final minute = chat.lastMessageTime.minute.toString().padLeft(2, '0');
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(chat.receiverNickname),
                      subtitle: Text(chat.lastMessage),
                      trailing: Text('$hour:$minute', style: const TextStyle(fontSize: 12)),
                      onTap: () => _goToChatPage(chat),
                    );
                  },
                ),
    );
  }
}
