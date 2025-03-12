import 'package:flutter/material.dart';
import 'package:yapper/Util/app_routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _goToNicknamePage(BuildContext context) {
  Navigator.pushNamed(context, AppRoutes.authSwipePages);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Different background from WelcomePage
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _goToNicknamePage(context); // Swipe left to navigate
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome to Yapper! A place to meet new people and start meaningful conversations.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _goToNicknamePage(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple, // Match theme
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    "Start",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
