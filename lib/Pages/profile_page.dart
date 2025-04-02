import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
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
    await _secureStorage.write(key: 'nickname', value: _nicknameController.text);
    await _secureStorage.write(key: 'age', value: _ageController.text);
    await _secureStorage.write(key: 'passion', value: _passionController.text);
    await _secureStorage.write(key: 'job', value: _jobController.text);
    await _secureStorage.write(key: 'hobbies', value: _hobbiesController.text);
    await _secureStorage.write(key: 'bio', value: _bioController.text);

    if (_image != null) {
      await _secureStorage.write(key: 'profileImage', value: _image!.path);
    }

    if (!mounted) return;
    Navigator.pop(context);
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
    await TokenManager.deleteToken(); // Clear stored token
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppRoutes.loginPage); // Navigate to login
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
            _buildTextField("Nickname", _nicknameController),
            _buildTextField("Age", _ageController),
            _buildTextField("Passion", _passionController),
            _buildTextField("Job", _jobController),
            _buildTextField("Hobbies", _hobbiesController),
            _buildTextField("Bio", _bioController),
            ElevatedButton(onPressed: _saveProfile, child: const Text("Save Profile")),
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
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    );
  }
}
