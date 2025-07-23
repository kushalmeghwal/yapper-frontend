import 'package:flutter/material.dart';
import 'package:yapper/Util/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _goToRegister(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.registerPage);
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.loginPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_bubble_outline,
                    size: 100, color: Colors.deepPurple),
                const SizedBox(height: 20),
                const Text(
                  "Welcome to Yapper",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Meet new people & start meaningful conversations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                /// Register Button
                ElevatedButton(
                  onPressed: () => _goToRegister(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Register"),
                ),
                const SizedBox(height: 20),

                /// Login Button
                ElevatedButton(
                  onPressed: () => _goToLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
