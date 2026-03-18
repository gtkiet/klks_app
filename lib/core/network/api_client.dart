import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../config/api_config.dart';
import '../storage/secure_storage.dart';
import '../auth/auth_helper.dart';
import '../../features/auth/services/auth_service.dart';

class ApiClient {
  static final SecureStorage _storage = SecureStorage();
  static final AuthService _authService = AuthService();

  static bool _isRefreshing = false;
  static final List<Function()> _queue = [];

  // =========================
  // GET
  // =========================
  static Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final res = await _sendRequest(method: "GET", path: path, headers: headers);
    return _handleResponse(res);
  }

  // =========================
  // POST
  // =========================
  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final res = await _sendRequest(
      method: "POST",
      path: path,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(res);
  }

  // =========================
  // PUT
  // =========================
  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final res = await _sendRequest(
      method: "PUT",
      path: path,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(res);
  }

  // =========================
  // CORE REQUEST
  // =========================
  static Future<http.Response> _sendRequest({
    required String method,
    required String path,
    Map<String, String>? headers,
    Object? body,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    final token = await _storage.getAccessToken();

    final requestHeaders = {
      "Content-Type": "application/json",
      ...?headers,
      if (token != null) "Authorization": "Bearer $token",
    };

    http.Response response;

    switch (method) {
      case "POST":
        response = await http
            .post(url, headers: requestHeaders, body: body)
            .timeout(const Duration(seconds: 15));
        break;

      case "PUT":
        response = await http
            .put(url, headers: requestHeaders, body: body)
            .timeout(const Duration(seconds: 15));
        break;

      case "GET":
      default:
        response = await http
            .get(url, headers: requestHeaders)
            .timeout(const Duration(seconds: 15));
    }

    if (response.statusCode == 401) {
      return _handle401(method, path, headers, body);
    }

    return response;
  }

  // =========================
  // HANDLE 401 (REFRESH TOKEN)
  // =========================
  static Future<http.Response> _handle401(
    String method,
    String path,
    Map<String, String>? headers,
    Object? body,
  ) async {
    if (_isRefreshing) {
      return _waitForRefresh(method, path, headers, body);
    }

    _isRefreshing = true;

    final success = await _authService.refreshAccessToken();

    _isRefreshing = false;

    // run queue
    for (var callback in _queue) {
      callback();
    }
    _queue.clear();

    if (!success) {
      await AuthHelper.forceLogout();
      throw Exception("SESSION_EXPIRED");
    }

    return _retry(method, path, headers, body);
  }

  // =========================
  // WAIT QUEUE
  // =========================
  static Future<http.Response> _waitForRefresh(
    String method,
    String path,
    Map<String, String>? headers,
    Object? body,
  ) {
    final completer = Completer<http.Response>();

    _queue.add(() async {
      try {
        final res = await _retry(method, path, headers, body);
        completer.complete(res);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  // =========================
  // RETRY AFTER REFRESH
  // =========================
  static Future<http.Response> _retry(
    String method,
    String path,
    Map<String, String>? headers,
    Object? body,
  ) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    final newToken = await _storage.getAccessToken();

    final requestHeaders = {
      "Content-Type": "application/json",
      ...?headers,
      if (newToken != null) "Authorization": "Bearer $newToken",
    };

    switch (method) {
      case "POST":
        return http.post(url, headers: requestHeaders, body: body);

      case "PUT":
        return http.put(url, headers: requestHeaders, body: body);

      case "GET":
      default:
        return http.get(url, headers: requestHeaders);
    }
  }

  // =========================
  // PARSE RESPONSE
  // =========================
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        return data;
      }

      return _error("Invalid response format");
    } catch (e) {
      return _error("Parse error");
    }
  }

  static Map<String, dynamic> _error(String message) {
    return {
      "isOk": false,
      "errors": [
        {"description": message},
      ],
    };
  }

  // =========================
  // UPLOAD FILE (BASIC)
  // =========================
  static Future<Map<String, dynamic>> uploadFile(
    String path, {
    required String fieldName,
    required String filePath,
    Map<String, String>? fields,
    String mimeType = "image/jpeg",
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}$path");

    final token = await _storage.getAccessToken();

    final request = http.MultipartRequest("POST", uri);

    request.headers.addAll({
      if (token != null) "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final mimeSplit = mimeType.split("/");

    request.files.add(
      await http.MultipartFile.fromPath(
        fieldName,
        filePath,
        contentType: MediaType(mimeSplit[0], mimeSplit[1]),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _handleResponse(response);
  }
}