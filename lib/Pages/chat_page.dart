import 'package:flutter/material.dart';
import 'package:yapper/Pages/all_chats_page.dart';
import 'package:yapper/Services/recent_chats_manager.dart';
import 'package:yapper/Services/socket_services.dart';
import 'package:yapper/Services/token_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:yapper/Util/app_routes.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  final String userId;
  final String receiverId;
  final String receiverNickname;

  const ChatPage({
    super.key,
    required this.chatRoomId,
    required this.userId,
    required this.receiverId,
    required this.receiverNickname,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _setupSocket();
  }

  Future<void> _setupSocket() async {
    print('Initializing chat...');
    _socketService.joinChatRoom(widget.chatRoomId);

    _socketService.onMessageReceived = _onMessageReceived;
    _socketService.onChatHistoryReceived = _onChatHistoryReceived;

    final token = await TokenManager.getToken();
    if (token == null) {
      print('No token found');
      return;
    }

    final decoded = JwtDecoder.decode(token);
    final userId = decoded["userId"];
    if (userId == null) {
      print('No userId in token');
      return;
    }

    _socketService.connect(userId, _onMatchFound);

    if (widget.chatRoomId.isEmpty || widget.chatRoomId == 'chat_NaN_NaN') {
      print('Invalid chatRoomId');
      return;
    }

    _socketService.getChatHistory(widget.chatRoomId);
  }

  void _onMatchFound(
      String chatRoomId, String receiverId, String receiverNickname) {
    print('Match found: $chatRoomId, $receiverId, $receiverNickname');
    // Can be used to navigate or update state if needed.
  }

  void _onMessageReceived(Map<String, dynamic> data) {
    print('Message received: $data');

    if (data['chatRoomId'] != widget.chatRoomId) return;

    final timestamp = data['timestamp'] is String
        ? DateTime.parse(data['timestamp'])
        : DateTime.fromMillisecondsSinceEpoch(data['timestamp']);

    setState(() {
      _messages.add({
        'senderId': data['senderId'],
        'message': data['message'],
        'timestamp': timestamp,
      });
    });

    RecentChatsManager().addOrUpdateChat(
      RecentChat(
        chatRoomId: widget.chatRoomId,
        receiverId: widget.receiverId,
        receiverNickname: widget.receiverNickname,
        lastMessage: data['message'],
        lastMessageTime: timestamp,
      ),
    );
  }

  void _onChatHistoryReceived(List<dynamic> messages) {
    print('Chat history received: $messages');

    setState(() {
      _messages.clear();
      _messages.addAll(messages.map((msg) => {
            'senderId': msg['senderId'],
            'message': msg['message'],
            'timestamp': msg['timestamp'] is String
                ? DateTime.parse(msg['timestamp'])
                : DateTime.fromMillisecondsSinceEpoch(msg['timestamp']),
          }));
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || widget.chatRoomId == 'chat_NaN_NaN') return;

    _socketService.sendMessage(
      widget.chatRoomId,
      widget.userId,
      widget.receiverId,
      text,
    );

    final now = DateTime.now();

    RecentChatsManager().addOrUpdateChat(
      RecentChat(
        chatRoomId: widget.chatRoomId,
        receiverId: widget.receiverId,
        receiverNickname: widget.receiverNickname,
        lastMessage: text,
        lastMessageTime: now,
      ),
    );

    _messageController.clear();
  }

  void _disconnectAndReturn(String route) {
    print('Disconnecting and returning to $route');
    // _socketService.leaveChatRoom(widget.chatRoomId);
    _socketService.disconnect();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AllChatPage(userId: widget.userId),
      ),
    );
  }

  void _returnToAllChat(String route) {
    print('returning to allchat page $route');
    // _socketService.leaveChatRoom(widget.chatRoomId);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AllChatPage(userId: widget.userId),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _socketService.leaveChatRoom(widget.chatRoomId);
    _messageController.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['senderId'] == widget.userId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['message'],
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            Text(
              _formatTimestamp(message['timestamp']),
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _disconnectAndReturn(AppRoutes.allChatPage);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.receiverNickname),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed: () => _returnToAllChat(AppRoutes.allChatPage),
              tooltip: 'All Chats',
            ),
            IconButton(
              icon: const Icon(Icons.call_end),
              onPressed: () => _disconnectAndReturn(AppRoutes.searchPage),
              tooltip: 'Disconnect',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) => _buildMessageBubble(
                    _messages[_messages.length - 1 - index]),
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Colors.deepPurple,
          ),
        ],
      ),
    );
  }
}
