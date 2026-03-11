import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile.dart';
import '../config/api_config.dart';

class ProfileService {
  static const storage = FlutterSecureStorage();

  static Future<UserProfile?> getProfile() async {
    final accessToken = await storage.read(key: "accessToken");

    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/api/profile/get-profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    final data = jsonDecode(response.body);

    if (data["isOk"] == true) {
      return UserProfile.fromJson(data["result"]);
    }

    return null;
  }
}