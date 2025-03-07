import 'package:flutter/material.dart';
import 'package:yapper/Pages/guide_page.dart';
import 'package:yapper/Pages/home_page.dart';
import 'package:yapper/Pages/login_page.dart';
import 'package:yapper/Pages/nickname_page.dart';
import 'package:yapper/Pages/password_page.dart';
import 'package:yapper/Pages/search_page.dart';
import 'package:yapper/Pages/username_page.dart';
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
      routes: {
        AppRoutes.homePage:(context)=>const HomePage(),
        AppRoutes.welcomePage:(context)=>const WelcomePage(),
        AppRoutes.guidePage:(context)=>const GuidePage(),
        AppRoutes.nicknamePage:(context)=>const NickNamePage(),
        AppRoutes.usernamePage:(context)=>const UserNamePage(),
        AppRoutes.passwordPage:(context)=>const PasswordPage(),
        AppRoutes.loginPage:(context)=>const LoginPage(),
        AppRoutes.searchPage:(context)=>const SearchPage(),
      },
    );
  }
}
