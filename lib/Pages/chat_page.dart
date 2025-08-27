import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:yapper/Pages/all_chats_page.dart';
import 'package:yapper/Services/recent_chats_manager.dart';
import 'package:yapper/Services/socket_services.dart';
import 'package:yapper/Services/token_manager.dart';

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
    // Join chat room
    _socketService.joinChatRoom(widget.chatRoomId);

    // Assign socket callbacks
    _socketService.onMessageReceived = _onMessageReceived;
    _socketService.onChatHistoryReceived = _onChatHistoryReceived;

    // Connect socket with userId from token if needed
    String userId = widget.userId;
    if (userId.isEmpty) {
      final token = await TokenManager.getToken();
      if (token != null && !JwtDecoder.isExpired(token)) {
        final decoded = JwtDecoder.decode(token);
        userId = decoded["userId"] ?? '';
      }
    }
    if (userId.isEmpty) return;

    _socketService.connect(userId, _onMatchFound);

    // Fetch chat history
    if (widget.chatRoomId.isNotEmpty && widget.chatRoomId != 'chat_NaN_NaN') {
      _socketService.getChatHistory(widget.chatRoomId);
    }
  }

  void _onMatchFound(String chatRoomId, String receiverId, String receiverNickname) {
    // Currently no navigation needed, can update state if desired
  }

  void _onMessageReceived(Map<String, dynamic> data) {
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

    // Update recent chats
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
    setState(() {
      _messages
        ..clear()
        ..addAll(messages.map((msg) => {
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

    final now = DateTime.now();
    _socketService.sendMessage(widget.chatRoomId, widget.userId, widget.receiverId, text);

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

  void _returnToAllChats() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AllChatPage(userId: widget.userId)),
    );
  }

  @override
  void dispose() {
    _socketService.leaveChatRoom(widget.chatRoomId);
    _messageController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) =>
      '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

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
            Text(message['message'], style: TextStyle(color: isMe ? Colors.white : Colors.black)),
            Text(_formatTimestamp(message['timestamp']),
                style: TextStyle(fontSize: 12, color: isMe ? Colors.white70 : Colors.black54)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _returnToAllChats();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.receiverNickname),
          backgroundColor: Colors.deepPurple,
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed: _returnToAllChats,
              tooltip: 'All Chats',
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
                  _messages[_messages.length - 1 - index],
                ),
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
            color: Colors.deepPurple,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
