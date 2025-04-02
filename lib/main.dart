import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:yapper/Pages/auth_swipe_pages.dart';
import 'package:yapper/Pages/chat_page.dart';
import 'package:yapper/Pages/guide_page.dart';
import 'package:yapper/Pages/home_page.dart';
import 'package:yapper/Pages/login_page.dart';
import 'package:yapper/Pages/profile_page.dart';
import 'package:yapper/Pages/search_page.dart';
import 'package:yapper/Pages/welcome_page.dart';
import 'package:yapper/Services/token_manager.dart';
import 'package:yapper/Util/app_routes.dart';

void main() async {
    FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print("🚨 FULL ERROR TRACE:");
    print(details.stack);  // ✅ Print full stack trace
  };
  WidgetsFlutterBinding.ensureInitialized();
  String? userToken = await TokenManager.getToken();
  runApp(MyApp(token: userToken));
}

class MyApp extends StatelessWidget {
  final token;
  const MyApp({this.token, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: (token != null && !JwtDecoder.isExpired(token!))
          ? AppRoutes.searchPage
          : AppRoutes.welcomePage, // the first landing page
      routes: {
        AppRoutes.welcomePage: (context) => const WelcomePage(),
        AppRoutes.homePage: (context) => const HomePage(),
        AppRoutes.guidePage: (context) => const GuidePage(),
        AppRoutes.loginPage: (context) => const LoginPage(),
        AppRoutes.searchPage: (context) => const SearchPage(),
        AppRoutes.authSwipePages: (context) => const AuthSwipePages(),
        AppRoutes.profilePage: (contex) => const ProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.chatPage) {
          // Ensure settings.arguments is not null and is a Map<String, String>
          if (settings.arguments is Map<String, String>) {
            final args = settings.arguments as Map<String, String>;

            // Check if all required keys exist and are non-null
            if (args.containsKey("chatRoomId") &&
                args.containsKey("userId") &&
                args.containsKey("receiverId") &&
                args.containsKey("receiverNickname")
              ) {
              return MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatRoomId: args["chatRoomId"] ?? "",
                  userId: args["userId"] ?? "",
                  receiverId: args["receiverId"] ?? "",
                  receiverNickname: args["receiverNickname"] ?? "",
                ),
              );
            } else {
              print("❌ Missing required arguments: $args");
            }
          } else {
            print("❌ Invalid arguments passed: ${settings.arguments}");
          }
        }
        return null;
      },
    );
  }
}
