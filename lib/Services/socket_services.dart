import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService  with ChangeNotifier {
  late io.Socket socket;
  List<Map<String, String>> messages = [];
  void connect(String userId, Function(String, String, String) onMatchFound) {
    print('in connect socket service');
    socket = io.io("http://10.0.2.2:3000", <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    print("Connecting to socket server...");
    socket.onConnect((_) {
      print("Connected to server");
      socket.emit("join", {"userId": userId});
    });

    socket.on("match_found", (data) {
      if (data == null ||
          !data.containsKey("chatRoomId") ||
          !data.containsKey("receiverId") ||
          !data.containsKey("receiverNickname")) {
        print("❌ Invalid match_found data received: $data");
        return;
      }

      String? chatRoomId = data["chatRoomId"];
      String? receiverId = data["receiverId"];
      String? receiverNickname = data["receiverNickname"];

      if (chatRoomId == null ||
          receiverId == null ||
          receiverNickname == null) {
        print(
            "❌ Missing values in match_found event: chatRoomId=$chatRoomId, receiverId=$receiverId, receiverNickname=$receiverNickname");
        return;
      }

      // ✅ Join the chat room immediately
      socket.emit("join_chat", {"chatRoomId": chatRoomId});
      print(
          "✅ Match found! Chat Room: $chatRoomId with $receiverId ($receiverNickname)");

      // ✅ Ensure onMatchFound is not null before calling
      if (onMatchFound != null) {
        onMatchFound(chatRoomId, receiverId, receiverNickname);
      } else {
        print("❌ onMatchFound callback is null!");
      }
    });

    socket.on("receive_message", (data) {
      print(
          "📥 New message received from ${data['senderId']}: ${data['message']}");

      // ✅ Debugging: Ensure message list updates
      if (data.containsKey("message") && data.containsKey("senderId")) {
        messages.add({
          "senderId": data["senderId"],
          "message": data["message"],
        });
        print("✅ Messages list updated: $messages");
         notifyListeners(); // ✅ Fix: Notify UI
      }
    });

    socket.onDisconnect((_) => print("Disconnected from server"));
  }

  void startSearching(String userId, String choice, String mood) {
    print(
        "🔍 Sending search request for userId: $userId, Mood: $mood, Choice: $choice");
    socket.emit("start_search", {
      "userId": userId,
      "choice": choice,
      "mood": mood,
    });
  }

  void sendMessage(String chatRoomId, String senderId, String message) {
    socket.emit("send_message", {
      // ✅ Correct event name
      "chatRoomId": chatRoomId,
      "senderId": senderId,
      "message": message,
    });
  }

  void disconnect() {
    socket.disconnect();
  }
}
