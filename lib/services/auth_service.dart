import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

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
}
