import 'package:flutter/material.dart';
import 'package:yapper/Util/app_routes.dart';
// import 'package:socket_io_client/socket_io_client.dart' as io;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _selectedChoice = "Rizler";
  bool _isSearching = false;
  String? _selectedMood;

  final List<String> _moods = [
    "Happy",
    "Sad",
    "Excited",
    "Sexy",
    "Horny",
    "Angry",
    "Nervous"
  ];

  // io.Socket? _socket;

  // @override
  // void initState() {
  //   super.initState();
  //   _socket = io.io("https://your-backend-url.com", <String, dynamic>{
  //     "transports": ["websocket"],
  //     "autoConnect": false,
  //   });
  //   _socket!.connect();
  //   _socket!.on("match_found", (data) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ChatPage(chatRoomId: data["roomId"]),
  //       ),
  //     );
  //   });
  // }

  void _chooseMood(String? mood) {
    setState(() {
      _selectedMood = mood;
    });
  }

  void _startSearching() {
    if (_selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a mood before searching.")),
      );
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // _socket!.emit("start_search", {"choice": _selectedChoice, "mood": _selectedMood});

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // ✅ Prevents calling Navigator if widget is disposed
      setState(() {
        _isSearching = false;
      });

      // Simulating a match found scenario
      Navigator.pushNamed(context, AppRoutes.chatPage);
    });
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Mood Selection using Radio Buttons
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
          const Text("Choose with whom you wanna yap", style: TextStyle(fontSize: 18)),
          // Choice Toggle Buttons
          ToggleButtons(
            isSelected: [
              _selectedChoice == "Rizler",
              _selectedChoice == "Gyaat"
            ],
            onPressed: (int index) {
              setState(() {
                _selectedChoice = index == 0 ? "Rizler" : "Gyaat";
              });
            },
            children: const [
              Padding(padding: EdgeInsets.all(10), child: Text("Rizler")),
              Padding(padding: EdgeInsets.all(10), child: Text("Gyaat"))
            ],
          ),
          const SizedBox(height: 20),

          // Search Button
          ElevatedButton(
            onPressed: _isSearching ? null : _startSearching,
            child: Text(_isSearching ? "Searching..." : "Search"),
          ),
        ],
      ),
    );
  }
}


