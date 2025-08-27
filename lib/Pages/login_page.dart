import 'package:flutter/material.dart';
import 'package:yapper/Services/token_manager.dart';
import 'package:yapper/Util/app_routes.dart';
import 'package:yapper/Services/api_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final storage = const FlutterSecureStorage();

  void _login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both username and password."),
        ),
      );
      return;
    }

    final response = await ApiService.login(
        _usernameController.text, _passwordController.text);

    if (response['success']) {
      if (!mounted) return;
      await TokenManager.saveToken(response['token']);
      Navigator.pushReplacementNamed(context, AppRoutes.searchPage);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  void _goToGoogleLogin() {
    Navigator.pushNamed(context, AppRoutes.googleLoginPage);
  }

  // void _goToPhoneLogin() {
  //   Navigator.pushNamed(context, AppRoutes.phoneLoginPage);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Text(
                "Login",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Username
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Login"),
              ),

              const SizedBox(height: 20),
              const Text("OR"),
              const SizedBox(height: 20),

              // Google Login
              ElevatedButton.icon(
                onPressed: _goToGoogleLogin,
                icon: const Icon(Icons.g_mobiledata),
                label: const Text("Login with Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 15),

              // Phone Login
              // ElevatedButton.icon(
              //   onPressed: _goToPhoneLogin,
              //   icon: const Icon(Icons.phone),
              //   label: const Text("Login with Phone"),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.green[700],
              //     foregroundColor: Colors.white,
              //     minimumSize: const Size(double.infinity, 50),
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10)),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}