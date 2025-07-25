import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = "auth_token";
  static const _keyUserId = "user_id";

  /// ✅ Save token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
        // Automatically decode and store userId if available
    Map<String, dynamic> decoded = JwtDecoder.decode(token);
    if (decoded.containsKey("userId")) {
      await saveUserId(decoded["userId"]);
    }
  }

  /// ✅ Retrieve token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// ✅ Delete token (for logout)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUserId); // Remove userId too
  }

  /// ✅ Save userId separately
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// ✅ Retrieve userId
  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }
    /// ✅ Check if token exists and is valid (optional helper)
  static Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && !JwtDecoder.isExpired(token);
  }
}
