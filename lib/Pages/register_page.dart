// No bottom text, only Register
// Successful registration leads to LoginPage

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:yapper/Services/api_services.dart';
import 'package:yapper/Util/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  void _registerUser() async {
    final nickname = _nicknameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (nickname.isEmpty || username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await ApiService.signUp(nickname, username, password);

    setState(() => _isLoading = false);

    if (response['success']) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.loginPage);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }

    if (kDebugMode) {
      print("Registering user: $nickname, $username");
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'lib/assets/logo.png',
                height: 80,
              ),
              const SizedBox(height: 40),

              // Nickname
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: "Nickname",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
