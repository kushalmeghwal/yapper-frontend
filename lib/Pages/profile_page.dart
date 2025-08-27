import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yapper/Services/api_services.dart';
import 'package:yapper/Services/recent_chats_manager.dart';
import 'package:yapper/Services/socket_services.dart';
import 'package:yapper/Services/token_manager.dart';
import 'package:yapper/Util/app_routes.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  File? _image;

  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passionController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _hobbiesController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _nicknameController.text = await _secureStorage.read(key: 'nickname') ?? "";
    _usernameController.text = await _secureStorage.read(key: 'username') ?? "";
    _ageController.text = await _secureStorage.read(key: 'age') ?? "";
    _passionController.text = await _secureStorage.read(key: 'passion') ?? "";
    _jobController.text = await _secureStorage.read(key: 'job') ?? "";
    _hobbiesController.text = await _secureStorage.read(key: 'hobbies') ?? "";
    _bioController.text = await _secureStorage.read(key: 'bio') ?? "";

    String? imagePath = await _secureStorage.read(key: 'profileImage');
    if (imagePath != null) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    final username = _usernameController.text.trim();

    if (nickname.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nickname and Username are required')),
      );
      return;
    }
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final idToken = await firebaseUser!.getIdToken();
    if (idToken == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Failed to get ID Token')),
  );
  return;
}
    final token = await TokenManager.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      return;
    }

    final response = await ApiService.updateFirebaseUserProfile(
      idToken: idToken,
      nickname: nickname,
      username: username,
    );

    if (response['success']) {
      await _secureStorage.write(key: 'nickname', value: nickname);
      await _secureStorage.write(key: 'username', value: username);
      await _secureStorage.write(key: 'age', value: _ageController.text);
      await _secureStorage.write(key: 'passion', value: _passionController.text);
      await _secureStorage.write(key: 'job', value: _jobController.text);
      await _secureStorage.write(key: 'hobbies', value: _hobbiesController.text);
      await _secureStorage.write(key: 'bio', value: _bioController.text);

      if (_image != null) {
        await _secureStorage.write(key: 'profileImage', value: _image!.path);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.searchPage);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"])),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _logout() async {
    await SocketService().cleanUpSocket(); // properly cleans listeners and disconnects
    await TokenManager.deleteToken(); // clears secure storage tokens
    RecentChatsManager().clear();  // clear local chat cache
    SocketService().disconnect(); 
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.loginPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : const AssetImage("lib/assets/1083.jpg") as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField("Nickname (required)", _nicknameController),
            _buildTextField("Username (required)", _usernameController),
            _buildTextField("Age", _ageController),
            _buildTextField("Passion", _passionController),
            _buildTextField("Job", _jobController),
            _buildTextField("Hobbies", _hobbiesController),
            _buildTextField("Bio", _bioController),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: const Text("Update & Continue"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Logout", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
