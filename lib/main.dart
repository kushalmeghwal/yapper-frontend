import 'package:flutter/material.dart';
import 'package:yapper/Pages/auth_swipe_pages.dart';
import 'package:yapper/Pages/chat_page.dart';
import 'package:yapper/Pages/guide_page.dart';
import 'package:yapper/Pages/home_page.dart';
import 'package:yapper/Pages/login_page.dart';
import 'package:yapper/Pages/search_page.dart';
import 'package:yapper/Pages/welcome_page.dart';
import 'package:yapper/Util/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.welcomePage, // the first landing page
      routes: {
        AppRoutes.welcomePage:(context)=>const WelcomePage(),
        AppRoutes.homePage:(context)=>const HomePage(),
        AppRoutes.guidePage:(context)=>const GuidePage(),
        AppRoutes.loginPage:(context)=>const LoginPage(),
        AppRoutes.searchPage:(context)=>const SearchPage(),
        AppRoutes.authSwipePages:(context) =>const AuthSwipePages(),
        AppRoutes.chatPage:(context) =>const ChatPage(chatRoomId: '1',),//findout how you get chatroomid
      },
    );
  }
}
