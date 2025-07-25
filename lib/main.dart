import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:yapper/Pages/all_chats_page.dart';
import 'package:yapper/Pages/register_page.dart';
import 'package:yapper/Pages/chat_page.dart';
import 'package:yapper/Pages/google_login_page.dart';
import 'package:yapper/Pages/guide_page.dart';
import 'package:yapper/Pages/home_page.dart';
import 'package:yapper/Pages/login_page.dart';
import 'package:yapper/Pages/phone_login_page.dart';
import 'package:yapper/Pages/profile_page.dart';
import 'package:yapper/Pages/search_page.dart';
import 'package:yapper/Pages/welcome_page.dart';
import 'package:yapper/Services/token_manager.dart';
import 'package:yapper/Util/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yapper/firebase_options.dart';

void main() async {
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print("🚨 FULL ERROR TRACE:");
    print(details.stack);
  };

  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Get user token
  String? userToken = await TokenManager.getToken();
  String? userId = await TokenManager.getUserId();
  if (userToken != null && !JwtDecoder.isExpired(userToken)) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(userToken);
    userId = decodedToken['userId'];
    // ✅ Save userId for future use
    if (userId != null) {
      await TokenManager.saveUserId(userId);
    }
  }
  // Run the app
  runApp(MyApp(token: userToken, userId: userId));
}

class MyApp extends StatelessWidget {
  final String? token;
  final String? userId;

  const MyApp({super.key, this.token, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // initialRoute: AppRoutes.welcomePage,
      initialRoute: (token != null && !JwtDecoder.isExpired(token!))
          ? AppRoutes.searchPage
          : AppRoutes.welcomePage,
      routes: {
        AppRoutes.welcomePage: (context) => const WelcomePage(),
        AppRoutes.homePage: (context) => const HomePage(),
        AppRoutes.guidePage: (context) => const GuidePage(),
        AppRoutes.loginPage: (context) => const LoginPage(),
        AppRoutes.searchPage: (context) => const SearchPage(),
        AppRoutes.registerPage: (context) => const RegisterPage(),
        AppRoutes.profilePage: (context) => const ProfilePage(),
        AppRoutes.googleLoginPage: (context) => const GoogleLoginPage(),
        AppRoutes.phoneLoginPage: (context) => const PhoneLoginPage(),
     
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.chatPage) {
          if (settings.arguments is Map<String, String>) {
            final args = settings.arguments as Map<String, String>;
            final requiredKeys = [
              "chatRoomId",
              "userId",
              "receiverId",
              "receiverNickname"
            ];

            if (requiredKeys.every((key) =>
                args.containsKey(key) && args[key]?.isNotEmpty == true)) {
              return MaterialPageRoute(
                builder: (context) => ChatPage(
                  chatRoomId: args["chatRoomId"]!,
                  userId: args["userId"]!,
                  receiverId: args["receiverId"]!,
                  receiverNickname: args["receiverNickname"]!,
                ),
              );
            } else {
              print("❌ Missing or empty required arguments: $args");
              return MaterialPageRoute(
                builder: (context) => const WelcomePage(),
              );
            }
          } else {
            print("❌ Invalid arguments passed: ${settings.arguments}");
            return MaterialPageRoute(
              builder: (context) => const WelcomePage(),
            );
          }
        }
        
        if (settings.name == AppRoutes.allChatPage) {
          final args = settings.arguments;
          if (args is String && args.isNotEmpty) {
            return MaterialPageRoute(
              builder: (context) => AllChatPage(userId: args),
            );
          } else {
            print("❌ userId not passed to AllChatPage");
            return MaterialPageRoute(
              builder: (context) => const WelcomePage(),
            );
          }
        }
        return null;
      },
    );
  }
}
