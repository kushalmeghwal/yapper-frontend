import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:yapper/Pages/chat_page.dart';
import 'package:yapper/Services/socket_services.dart';
import 'package:yapper/Util/app_routes.dart';
import 'package:yapper/Services/token_manager.dart';
import 'dart:io';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _selectedChoice="Rizzler";
  bool _isSearching = false;
  String? _selectedMood;
  String? _profileImagePath;
  String? _userId;
  final bool _isConnected = false;
  final List<String> _moods = [
    "Happy",
    "Sad",
    "Excited",
    "Lazy",
    "Thirsty",
    "Angry",
    "Nervous"
  ];
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    String? token = await TokenManager.getToken();
    print('token-');
    print(token);
    if (token == null) return; // Exit if no token is found

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String? userId = decodedToken["userId"] ?? decodedToken["user_id"] ?? decodedToken["sub"];
    print(userId);
    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      print("1");
      _socketService.connect(userId, _onMatchFound);
    }
  }

  void _onMatchFound(
      String chatRoomId, String receiverId, String receiverNickname) {
    print('Match found with chatRoomId: $chatRoomId');

    if (_userId == null) {
      print("Cannot navigate, _userId is null!");
      return;
    }
    if (!mounted) return;

    // Validate chat room ID
    if (chatRoomId.isEmpty || chatRoomId == 'chat_NaN_NaN') {
      print('Invalid chat room ID received: $chatRoomId');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatRoomId: chatRoomId,
          userId: _userId!,
          receiverId: receiverId,
          receiverNickname: receiverNickname,
        ),
      ),
    ).then((_) {
      setState(() {
        _isSearching = false;
      });
    });
  }

  void _chooseMood(String? mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  void _goToAllChatPage() {
    if (_userId != null) {
      Navigator.pushNamed(context, AppRoutes.allChatPage, arguments: _userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID is not available.")),
      );
    }
  }

  void _startSearching() {
    print('search click hua');
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a mood before searching.")),
      );
      return;
    }
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("User ID is not available. Please log in again.")),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    print('Starting search with:');
    print('userId: $_userId');
    print('type: $_selectedChoice');
    print('mood: $_selectedMood');

    _socketService.startSearching(_userId!, _selectedChoice, _selectedMood!);
    print("call ke bad");

      // ⏳ Timeout after 30 seconds if no match found
  Future.delayed(const Duration(seconds: 30), () {
    if (mounted && _isSearching) {
      setState(() {
        _isSearching = false;
      });
    }
  });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
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
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "YAPPER!!",
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: _goToAllChatPage,
            tooltip: 'All Chats',
          ),
        ],
        leading: GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profilePage),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: _profileImagePath != null
                  ? FileImage(File(_profileImagePath!))
                  : null,
              child: _profileImagePath == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Choose Your Mood", style: TextStyle(fontSize: 18)),
            Column(
              children: _moods.map((mood) {
                return RadioListTile<String>(
                  title: Text(mood),
                  value: mood,
                  groupValue: _selectedMood,
                  onChanged: _chooseMood,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Choose with whom you wanna yap",
                style: TextStyle(fontSize: 18)),
            ToggleButtons(
              isSelected: [
                _selectedChoice == "Rizzler",
                _selectedChoice == "Shawty"
              ],
              onPressed: (int index) {
                setState(() {
                  _selectedChoice = index == 0 ? "Rizzler" : "Shawty";
                });
              },
              children: const [
                Padding(padding: EdgeInsets.all(10), child: Text("Rizzler")),
                Padding(padding: EdgeInsets.all(10), child: Text("Shawty"))
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSearching ? null : _startSearching,
              child: Text(_isSearching ? "Searching..." : "Search"),
            ),
          ],
        ),
      ),
    );
  }
}
