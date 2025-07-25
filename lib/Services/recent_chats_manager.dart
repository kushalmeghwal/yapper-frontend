class RecentChat {
  final String chatRoomId;
  final String receiverId;
  final String receiverNickname;
  final String lastMessage;
  final DateTime lastMessageTime;

  RecentChat({
    required this.chatRoomId,
    required this.receiverId,
    required this.receiverNickname,
    required this.lastMessage,
    required this.lastMessageTime,
  });
}

class RecentChatsManager {
  static final RecentChatsManager _instance = RecentChatsManager._internal();
  factory RecentChatsManager() => _instance;

  RecentChatsManager._internal();

  final List<RecentChat> _recentChats = [];

  List<RecentChat> get recentChats => List.unmodifiable(_recentChats);

  void addOrUpdateChat(RecentChat chat) {
    final index = _recentChats.indexWhere((c) => c.chatRoomId == chat.chatRoomId);
    if (index != -1) {
      _recentChats[index] = chat;
    } else {
      _recentChats.insert(0, chat);
    }
    _recentChats.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  void clear() {
  _recentChats.clear();
  }

  void removeChat(String chatRoomId) {
    _recentChats.removeWhere((c) => c.chatRoomId == chatRoomId);
  }

  void clearChats() {
    _recentChats.clear();
  }
}
