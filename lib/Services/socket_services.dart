import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

class SocketService with ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late io.Socket socket;
  Function(String, String, String)? onMatchFound;
  Function(Map<String, dynamic>)? onMessageReceived;
  Function(List<dynamic>)? onChatHistoryReceived;
  Function(List<Map<String, dynamic>>)? onAllChatsReceived;
  
  bool _isConnected = false;
  String? _userId;
  bool _isInitializing = false;
  Timer? _heartbeatTimer;
  Set<String> _processedMessageIds = {};

  void connect(
      String userId, Function(String, String, String) onMatchFoundCallback) {
    print("void connect chala");
    _userId = userId;
    onMatchFound = onMatchFoundCallback;
    _initializeSocket();
  }

  void _initializeSocket() async {
    if (_isInitializing) {
      print('Socket initialization already in progress...');
      return;
    }

    _isInitializing = true;
    print("initialise hua");

     if (_isConnected) {
    socket.off('matchFound'); 
  }

    try {
      socket = io.io(
        'http://10.0.2.2:3000',
        // 'https://yapper-backend-production.up.railway.app',
        // 'https: //230nlqqq-3000.inc1.devtunnels.ms',
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .setReconnectionAttempts(1000)
            .setReconnectionDelay(1000)
            .setTimeout(60000)
            .disableAutoConnect()
            .build(),
      );

      print("initialise hone ke bad");
      socket.connect();

      print("connect ke bad");
      socket.onConnect((_) {
        print('Connected to server');
        _isConnected = true;
        _isInitializing = false;
        notifyListeners();
    socket.emit('userOnline', _userId);
        // Start heartbeat
        _startHeartbeat();

        if (_userId != null) {
          socket.emit('join', _userId);
          print('Emitted join for $_userId');
        }
      });

      socket.onDisconnect((_) {
        print('Disconnected from server - Attempting to reconnect...');
        _isConnected = false;
        _isInitializing = false;
        _stopHeartbeat();
        notifyListeners();
        // Automatically try to reconnect
        _initializeSocket();
      });

      socket.onConnectError((error) {
        print('Connection error: $error - Attempting to reconnect...');
        _isConnected = false;
        _isInitializing = false;
        _stopHeartbeat();
        notifyListeners();
        // Automatically try to reconnect
        _initializeSocket();
      });

      socket.onError((error) {
        print('Socket error: $error - Attempting to reconnect...');
        _isConnected = false;
        _isInitializing = false;
        _stopHeartbeat();
        notifyListeners();
        // Automatically try to reconnect
        _initializeSocket();
      });

      socket.on('matchFound', (data) {
        print("Match found event received: $data");
        if (onMatchFound != null) {
          onMatchFound!(
              data['chatRoomId'], data['receiverId'], data['receiverNickname']);
        }
         _isConnected = true;
      });
      socket.on('allChats', (data) {
        if (onAllChatsReceived != null && data is List) {
          onAllChatsReceived!(List<Map<String, dynamic>>.from(data));
        }
      });
      socket.on('receiveMessage', (data) {
        print("Message received event: $data");
        // Generate a unique message ID
        final messageId =
            '${data['chatRoomId']}_${data['senderId']}_${data['timestamp']}';

        // Check if we've already processed this message
        if (_processedMessageIds.contains(messageId)) {
          print('Duplicate message received, ignoring: $messageId');
          return;
        }

        // Add to processed messages
        _processedMessageIds.add(messageId);

        // Keep only last 1000 message IDs
        if (_processedMessageIds.length > 1000) {
          _processedMessageIds = _processedMessageIds
              .skip(_processedMessageIds.length - 1000)
              .toSet();
        }

        if (onMessageReceived != null) {
          onMessageReceived!(data);
        }
      });

      socket.on('chatHistory', (data) {
        print("Chat history received: $data");
        if (onChatHistoryReceived != null) {
          onChatHistoryReceived!(data);
        }
      });

      socket.on('messageError', (data) {
        print("Message error received: $data");
      });

      socket.on('pong', (_) {
        print('Received pong from server');
      });
    } catch (error) {
      print('Error initializing socket: $error');
      _isConnected = false;
      _isInitializing = false;
      _stopHeartbeat();
      notifyListeners();
    }
  }
Future<void> cleanUpSocket() async {
socket?.off('matchFound');
  socket?.off('allChats');
  socket?.off('message');
  socket?.off('chatHistory');
  socket?.off('connect');
  socket?.off('disconnect');
  socket?.disconnect();
  _userId = null;
}

  void _startHeartbeat() {
    _stopHeartbeat(); // Clear any existing heartbeat
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        print('Sending heartbeat ping');
        socket.emit('ping');
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }
  void removeMatchFoundListener() {
  socket.off('matchFound');
    onMatchFound = null;
   }

  // Start searching for a match
  void startSearching(String userId, String type, String mood) {
    print("Starting search - UserId: $userId, Type: $type, Mood: $mood");
    if (!_isConnected) {
      print('🔌 Not connected. Cannot start searching.');
      _initializeSocket();
      // Wait for connection before starting search
      socket.onConnect((_) {
        print('Reconnected, now starting search...');
        _startSearchingInternal(userId, type, mood);
      });
      return;
    }
    _startSearchingInternal(userId, type, mood);
  }

  void leaveChatRoom(String chatRoomId) {
    if (socket.connected) {
      print('Leaving chat room: $chatRoomId');
      socket.emit('leave_chat', chatRoomId);
    } else {
      print('Socket not connected. Cannot leave room.');
    }
  }

  void _startSearchingInternal(String userId, String type, String mood) {
    print('Emitting startSearching event');
    socket
        .emit('startSearching', {'userId': userId, 'type': type, 'mood': mood});
    print("Search request emitted");
  }

  //all chats
  void requestAllChats(String userId) {
    print("Requesting all chats for user: $userId");
    if (!_isConnected) {
      print('🔌 Not connected. Cannot request all chats.');
      _initializeSocket();
      socket.onConnect((_) {
        socket.emit('getAllChats', {'userId': userId});
      });
      return;
    }
    socket.emit('getAllChats', {'userId': userId});
  }

  // Stop searching for a match
  void stopSearching(String userId) {
    print("Stopping search for user: $userId");
    if (!_isConnected) {
      print('🔌 Not connected. Cannot stop searching.');
      return;
    }
    socket.emit('stopSearching', userId);
    print("Stop search request emitted");
  }

  void joinChatRoom(String chatRoomId) {
    if (socket.connected) {
      print('Joining chat room: $chatRoomId');
      socket.emit('join_chat', chatRoomId);
    } else {
      print('Socket not connected. Cannot join room.');
    }
  }

  void sendMessage(
      String chatRoomId, String senderId, String receiverId, String message) {
    print("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅1");
    print(
        "Sending message - chatRoomId: $chatRoomId, senderId: $senderId, receiverId: $receiverId, message: $message");
    print(
        "Current connection state - isConnected: $_isConnected, isInitializing: $_isInitializing");

    // Ensure we're connected before sending
    if (!_isConnected) {
      print('Socket not connected. Attempting to reconnect...');
      _initializeSocket();
      // Wait for connection before sending
      socket.onConnect((_) {
        print('Reconnected, now sending message...');
        print("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅2");
        _sendMessageInternal(chatRoomId, senderId, receiverId, message);
      });
      return;
    }
    print("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅3");
    _sendMessageInternal(chatRoomId, senderId, receiverId, message);
  }

  void _sendMessageInternal(
      String chatRoomId, String senderId, String receiverId, String message) {
    print("Sending message internally - chatRoomId: $chatRoomId");
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final messageData = {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp
    };

    // Add to processed messages immediately to prevent duplicates
    final messageId = '${chatRoomId}_${senderId}_$timestamp';
    _processedMessageIds.add(messageId);
    print("✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅4");
    socket.emit('sendMessage', messageData);
    print("Message emit completed");
  }

  void getChatHistory(String chatRoomId) {
    print("Getting chat history for room: $chatRoomId");
    if (!_isConnected) {
      print('Socket not connected. Attempting to reconnect...');
      _initializeSocket();
      // Wait for connection before getting history
      socket.onConnect((_) {
        print('Reconnected, now getting chat history...');
        _getChatHistoryInternal(chatRoomId);
      });
      return;
    }
    _getChatHistoryInternal(chatRoomId);
  }

  void _getChatHistoryInternal(String chatRoomId) {
    print("Getting chat history internally for room: $chatRoomId");
    socket.emit('getChatHistory', {'chatRoomId': chatRoomId});
    print("Chat history request emitted");
  }


  // Only call this when user explicitly logs out
  void disconnect() {
    _stopHeartbeat();
     socket.off('matchFound');
       socket.off('message');
  socket.off('allChats');
    socket.disconnect();
    _isConnected = false;
    _isInitializing = false;
    _processedMessageIds.clear();
    notifyListeners();
  }


  bool get isConnected => _isConnected;
}
