import 'package:flutter/material.dart';
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
  final bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    print('ChatPage initialized with:');
    print('chatRoomId: ${widget.chatRoomId}');
    print('userId: ${widget.userId}');
    print('receiverId: ${widget.receiverId}');
    _initializeChat();
  }

  void _initializeChat() async {
    print('Initializing chat...');
    String? token = await TokenManager.getToken();
    if (token == null) {
      print('No token found');
      return;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String? userId = decodedToken["userId"];
    if (userId == null) {
      print('No userId in token');
      return;
    }

    print('Connecting socket service...');
    _socketService.connect(userId, _onMatchFound);
    _socketService.onMessageReceived = _onMessageReceived;
    _socketService.onChatHistoryReceived = _onChatHistoryReceived;
    
    // Ensure we have a valid chat room ID
    if (widget.chatRoomId.isEmpty || widget.chatRoomId == 'chat_NaN_NaN') {
      print('Invalid chat room ID: ${widget.chatRoomId}');
      return;
    }
    
    print('Getting chat history for room: ${widget.chatRoomId}');
    _socketService.getChatHistory(widget.chatRoomId);
  }

  void _onMatchFound(String chatRoomId, String receiverId, String receiverNickname) {
    print('Match found: $chatRoomId, $receiverId, $receiverNickname');
  }

  void _onMessageReceived(Map<String, dynamic> data) {
    print('Message received: $data');
    if (data['chatRoomId'] != widget.chatRoomId) {
      print('Message for different chat room, ignoring');
      return;
    }
    
    setState(() {
      _messages.add({
        'senderId': data['senderId'],
        'message': data['message'],
        'timestamp': data['timestamp'] is String 
            ? DateTime.parse(data['timestamp'])
            : DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
      });
    });
    print('Current messages: $_messages');
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
      }).toList());
    });
    print('Updated messages after history: $_messages');
  }

 void _sendMessage() {
  if (_messageController.text.trim().isEmpty) return;

  // Ensure we have a valid chat room ID
  if (widget.chatRoomId.isEmpty || widget.chatRoomId == 'chat_NaN_NaN') {
    print('Cannot send message: Invalid chat room ID');
    return;
  }

  final messageText = _messageController.text.trim();

  print('Sending message: $messageText');
  _socketService.sendMessage(
    widget.chatRoomId,
    widget.userId,
    widget.receiverId,
    messageText,
  );

  _messageController.clear();
}

  void _disconnectAndReturn() {
    print('Disconnecting and returning to search page');
    _socketService.disconnect();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.searchPage);
  }

  @override
  void dispose() {
    print('Disposing chat page');
    _socketService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverNickname),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end),
            onPressed: _disconnectAndReturn,
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
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                final isMe = message['senderId'] == widget.userId;
                print('Building message: $message, isMe: $isMe');

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
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
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
              },
            ),
          ),
          Container(
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
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
