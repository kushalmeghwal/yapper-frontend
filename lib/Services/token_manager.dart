import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = "auth_token";
  static const _keyUserId = "user_id";

  /// ✅ Save token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
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
}
