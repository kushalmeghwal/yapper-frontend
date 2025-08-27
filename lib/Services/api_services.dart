import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 
  'https://yapper-backend-vnvq.onrender.com/api';
  // 'http://10.0.2.2:3000/api';
  // 'https://yapper-backend-production.up.railway.app/api';
  // 'https://230nlqqq-3000.inc1.devtunnels.ms/api';

  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"]) {
        return {
          "success": true,
          "token": data["token"],
          "message": data["message"]
        };
      } else {
        return {"success": false, "message": data["message"] ?? "Login failed"};
      }
    } catch (e) {
      print(" Error during login: $e");
      return {
        "success": false,
        "message": "An error occurred. Please try again later."
      };
    }
  }

  static Future<Map<String, dynamic>> signUp(
      String nickname, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nickname': nickname,
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"]) {
        return {"success": true, "message": "Registration successful"};
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Signup failed"
        };
      }
    } catch (e) {
      print(" Error during signup: $e");
      return {
        "success": false,
        "message": "An error occurred. Please try again later."
      };
    }
  }

  static Future<Map<String, dynamic>> updateFirebaseUserProfile({
    required String idToken,
    required String nickname,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/firebase/update-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'nickname': nickname,
          'username': username,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"]) {
        return {
          "success": true,
          "message": data["message"] ?? "Profile updated successfully"
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Profile update failed"
        };
      }
    } catch (e) {
      print("Error updating firebase profile: $e");
      return {
        "success": false,
        "message": "An error occurred. Please try again later."
      };
    }
  }
}
