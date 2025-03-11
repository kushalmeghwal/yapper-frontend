import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String chatRoomId;
  const ChatPage({super.key, required this.chatRoomId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {


  @override
  Widget build(BuildContext context) {
       return Scaffold(
      appBar: AppBar(title: const Text("Yap-Yap now")),
      
      body: Center(
        child: Text("bhaisahb match ho gya!!: match no. ${widget.chatRoomId}"),
      ),
    );
  }
}
