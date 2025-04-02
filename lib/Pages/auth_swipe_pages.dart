import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yapper/Pages/swipe_pages_ui.dart';
import 'package:yapper/Services/api_services.dart';
import 'package:yapper/Util/app_routes.dart';

class AuthSwipePages extends StatefulWidget {
  const AuthSwipePages({super.key});

  @override
  State<AuthSwipePages> createState() => _AuthSwipePagesState();
}

class _AuthSwipePagesState extends State<AuthSwipePages> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _nickname = "";
  String _username = "";
  String _password = "";

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _registerUser() async {
    if (_nickname.isEmpty || _username.isEmpty || _password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields before registering.")),
      );
      return;
    }
    final response = await ApiService.signUp(_nickname, _username, _password);
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
      print("Registering user: $_nickname, $_username");
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          _buildNicknamePage(),
          _buildUsernamePage(),
          _buildPasswordPage(),
        ],
      ),
    );
  }

  Widget _buildNicknamePage() {
    return _buildPage(
      title: "Enter your Nickname",
      hintText: "Nickname",
      onNext: _goToNextPage,
      activeDotIndex: 0,
      onTextChanged: (value) => _nickname = value,
    );
  }

  Widget _buildUsernamePage() {
    return _buildPage(
      title: "Choose a Username",
      hintText: "Username",
      onNext: _goToNextPage,
      onBack: _goToPreviousPage,
      activeDotIndex: 1,
      onTextChanged: (value) => _username = value,
    );
  }

  Widget _buildPasswordPage() {
    return _buildPage(
      title: "Create a Password",
      hintText: "Password",
      onNext: _registerUser,
      onBack: _goToPreviousPage,
      activeDotIndex: 2,
      onTextChanged: (value) => _password = value,
    );
  }

  Widget _buildPage({
    required String title,
    required String hintText,
    bool isPassword = false,
    VoidCallback? onNext,
    VoidCallback? onBack,
    required int activeDotIndex,
    required ValueChanged<String> onTextChanged,
  }) {
    return SwipePagesUi.makeSwipePagesUI(
      title: title,
      hintText: hintText,
      isPassword: isPassword,
      onNext: onNext,
      onBack: onBack,
      activeDotIndex: activeDotIndex,
      onTextChanged: onTextChanged,
      isLastPage: activeDotIndex == 2,
    );
  }
}
