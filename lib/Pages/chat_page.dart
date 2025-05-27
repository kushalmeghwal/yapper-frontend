import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yapper/Services/socket_services.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String receiverId;
  final String chatRoomId;
  final String receiverNickname;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.receiverId,
    required this.chatRoomId,
    required this.receiverNickname,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService _socketService = SocketService();
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();

    // ✅ Correct function signature for connect
    _socketService.connect(widget.userId,
        (chatRoomId, receiverId, receiverNickname) {
      print("📩 Match found: $chatRoomId, $receiverId ($receiverNickname)");
    });

    // ✅ Listen for incoming messages
    _socketService.socket.on("receive_message", (data) {
      String senderId = data['senderId'];
      String message = data['message'];
      print(message);
      _onMessageReceived(senderId, message);
    });
  }

  void _onMessageReceived(String senderId, String message) {
    setState(() {
      messages.add("$senderId: $message");
    });
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _socketService.sendMessage(
          widget.userId, widget.receiverId, _messageController.text);
      setState(() {
        messages.add("Me: ${_messageController.text}");
      });
      _messageController.clear();
    }
  }

  Future<void> sendImage() async {
    // final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    // if (image != null) {
    //   _socketService.sendMessage(widget.userId, widget.receiverId, "📷 Image: ${image.path}");
    //   setState(() {
    //     messages.add("Me: 📷 Image Sent");
    //   });
    // }
  }

  void disconnectChat() {
    _socketService.disconnect();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with "), //${widget.receiverNickname}
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: disconnectChat,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(messages[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: sendImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: "Enter message"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
