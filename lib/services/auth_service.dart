import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String idCard,
    required String dob,
    required int gioiTinhId,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "idCard": idCard,
        "dob": dob,
        "gioiTinhId": gioiTinhId,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    return jsonDecode(response.body);
  }

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    final data = jsonDecode(response.body);

    if (data["isOk"] == true) {
      final accessToken = data["result"]["accessToken"];
      final refreshToken = data["result"]["refreshToken"];

      await storage.write(key: "accessToken", value: accessToken);
      await storage.write(key: "refreshToken", value: refreshToken);
    }

    return data;
  }

  Future<Map<String, dynamic>> forgotPassword({
    required String username,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/forgot-password");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username}),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String username,
    required String resetCode,
    required String newPassword,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/auth/reset-password");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "resetCode": resetCode,
        "newPassword": newPassword,
      }),
    );

    return jsonDecode(response.body);
  }
}
