import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:async';

class SocketService with ChangeNotifier {
  static const String baseUrl = 'https://yapper-backend-vnvq.onrender.com';
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
  final Set<String> _processedMessageIds = {};

  void connect(String userId, Function(String, String, String) onMatchFoundCallback) {
    if (_userId != null && _isConnected) return; // Already connected
    _userId = userId;
    onMatchFound = onMatchFoundCallback;
    _initializeSocket();
  }

  void _initializeSocket() {
    if (_isInitializing) return;
    _isInitializing = true;

    socket = io.io(baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .setReconnectionAttempts(1000)
          .setReconnectionDelay(1000)
          .setTimeout(60000)
          .disableAutoConnect()
          .build(),
    );

    // Connect
    socket.connect();

    // Connect listener
    socket.onConnect((_) {
      _isConnected = true;
      _isInitializing = false;
      notifyListeners();
      if (_userId != null) socket.emit('userOnline', _userId);
      if (_userId != null) socket.emit('join', _userId);
      _startHeartbeat();
    });

    // Disconnect listener
    socket.onDisconnect((_) {
      _isConnected = false;
      _isInitializing = false;
      _stopHeartbeat();
      notifyListeners();
      Future.delayed(const Duration(seconds: 2), _initializeSocket); // Try reconnect
    });

    // Error handling
    socket.onConnectError((error) => _handleError(error));
    socket.onError((error) => _handleError(error));

    // Heartbeat response
    socket.on('pong', (_) => print('Received pong from server'));

    // Match found
    socket.on('matchFound', (data) {
      if (onMatchFound != null) {
        onMatchFound!(data['chatRoomId'], data['receiverId'], data['receiverNickname']);
      }
    });

    // All chats
    socket.on('allChats', (data) {
      if (onAllChatsReceived != null && data is List) {
        onAllChatsReceived!(List<Map<String, dynamic>>.from(data));
      }
    });

    // Chat history
    socket.on('chatHistory', (data) {
      if (onChatHistoryReceived != null) {
        onChatHistoryReceived!(data);
      }
    });

    // Incoming messages
    socket.on('receiveMessage', (data) {
      final messageId = '${data['chatRoomId']}_${data['senderId']}_${data['timestamp']}';
      if (_processedMessageIds.contains(messageId)) return;
      _processedMessageIds.add(messageId);
      if (_processedMessageIds.length > 1000) {
        _processedMessageIds.remove(_processedMessageIds.first);
      }
      if (onMessageReceived != null) onMessageReceived!(data);
    });
  }

  void _handleError(dynamic error) {
    print('Socket error: $error - Attempting to reconnect...');
    _isConnected = false;
    _isInitializing = false;
    _stopHeartbeat();
    notifyListeners();
    Future.delayed(const Duration(seconds: 2), _initializeSocket);
  }

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected) socket.emit('ping');
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void startSearching(String userId, String type, String mood) {
    if (!_isConnected) {
      socket.onConnect((_) => _emitSearch(userId, type, mood));
      _initializeSocket();
      return;
    }
    _emitSearch(userId, type, mood);
  }

  void _emitSearch(String userId, String type, String mood) {
    socket.emit('startSearching', {'userId': userId, 'type': type, 'mood': mood});
  }

  void stopSearching(String userId) {
    if (_isConnected) socket.emit('stopSearching', userId);
  }

  void sendMessage(String chatRoomId, String senderId, String receiverId, String message) {
    if (!_isConnected) {
      socket.onConnect((_) => _sendMessageInternal(chatRoomId, senderId, receiverId, message));
      _initializeSocket();
      return;
    }
    _sendMessageInternal(chatRoomId, senderId, receiverId, message);
  }

  void _sendMessageInternal(String chatRoomId, String senderId, String receiverId, String message) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final messageId = '${chatRoomId}_${senderId}_$timestamp';
    _processedMessageIds.add(messageId);

    socket.emit('sendMessage', {
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp
    });
  }

  void getChatHistory(String chatRoomId) {
    if (!_isConnected) {
      socket.onConnect((_) => _getChatHistoryInternal(chatRoomId));
      _initializeSocket();
      return;
    }
    _getChatHistoryInternal(chatRoomId);
  }

  void _getChatHistoryInternal(String chatRoomId) {
    socket.emit('getChatHistory', {'chatRoomId': chatRoomId});
  }

  void joinChatRoom(String chatRoomId) {
    if (_isConnected) socket.emit('joinRoom', chatRoomId);
  }

  void leaveChatRoom(String chatRoomId) {
    if (_isConnected) socket.emit('leaveRoom', chatRoomId);
  }

  void requestAllChats(String userId) {
    if (!_isConnected) {
      socket.onConnect((_) => socket.emit('getAllChats', {'userId': userId}));
      _initializeSocket();
      return;
    }
    socket.emit('getAllChats', {'userId': userId});
  }

  Future<void> cleanUpSocket() async {
    socket.off('matchFound');
    socket.off('allChats');
    socket.off('receiveMessage');
    socket.off('chatHistory');
    socket.off('connect');
    socket.off('disconnect');
    _stopHeartbeat();
    _processedMessageIds.clear();
    _isConnected = false;
    _isInitializing = false;
    _userId = null;
    socket.disconnect();
  }

  void disconnect() {
    cleanUpSocket();
    notifyListeners();
  }

  bool get isConnected => _isConnected;
}
