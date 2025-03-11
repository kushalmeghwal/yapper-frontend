import 'package:flutter/material.dart';
import 'package:yapper/Pages/swipe_pages_ui.dart';
import 'package:yapper/Util/app_routes.dart';

class AuthSwipePages extends StatefulWidget {
  const AuthSwipePages({super.key});

  @override
  State<AuthSwipePages> createState() => _AuthSwipePagesState();
}

class _AuthSwipePagesState extends State<AuthSwipePages> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.loginPage);
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
    );
  }

  Widget _buildUsernamePage() {
    return _buildPage(
      title: "Choose a Username",
      hintText: "Username",
      onNext: _goToNextPage,
      onBack: _goToPreviousPage,
      activeDotIndex: 1,
    );
  }

  Widget _buildPasswordPage() {
    return _buildPage(
      title: "Set your Password",
      hintText: "Password",
      isPassword: true,
      onNext: _goToNextPage,
      onBack: _goToPreviousPage,
      activeDotIndex: 2,
    );
  }

  Widget _buildPage({
    required String title,
    required String hintText,
    bool isPassword = false,
    VoidCallback? onNext,
    VoidCallback? onBack,
    required int activeDotIndex,
  }) {
      return SwipePagesUi.makeSwipePagesUI(
      title: title,
      hintText: hintText,
      isPassword: isPassword,
      onNext: onNext,
      onBack: onBack,
      activeDotIndex: activeDotIndex,
    );
  }
}
