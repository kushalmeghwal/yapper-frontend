import 'dart:core';

class AppRoutes {
  static const String welcomePage = '/welcome'; //runs for few seconds
  static const String homePage = '/home'; //first actual landing page
  static const String guidePage = '/guide'; //crazy instructions are written in this page
  static const String registerPage = '/register'; // Contains nickname, username, and password pages
  static const String loginPage = '/login';//navigate to login page only after all three dot ••• pages are completed
  static const String searchPage = '/search';//already some recommendetions will the there,: how?
  static const String chatPage='/chat';//when a match found chatbox will be opened
  static const String profilePage='/profile';
  static const String googleLoginPage = '/google-login';
  static const String phoneLoginPage = '/phone-login';
  static const String allChatPage = '/all-chats';
}
