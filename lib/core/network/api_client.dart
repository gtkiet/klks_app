import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../config/api_config.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'api_response.dart';

class ApiClient {
  static final SecureStorage _storage = SecureStorage();

  /// Inject từ main.dart
  static AuthProvider? _authProvider;

  static void setAuthProvider(AuthProvider provider) {
    _authProvider = provider;
  }

  /// Refresh queue control
  static bool _isRefreshing = false;
  static Completer<void>? _refreshCompleter;

  static const _timeout = Duration(seconds: 15);

  // =========================
  // PUBLIC APIs (GENERIC)
  // =========================

  static Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? headers,
    T Function(dynamic json)? fromJsonT,
  }) async {
    final res = await _request("GET", path, headers: headers);
    return _parse<T>(res, fromJsonT);
  }

  static Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, String>? headers,
    Object? body,
    T Function(dynamic json)? fromJsonT,
  }) async {
    final res = await _request(
      "POST",
      path,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse<T>(res, fromJsonT);
  }

  static Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, String>? headers,
    Object? body,
    T Function(dynamic json)? fromJsonT,
  }) async {
    final res = await _request(
      "PUT",
      path,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _parse<T>(res, fromJsonT);
  }

  // =========================
  // CORE REQUEST (AUTO RETRY)
  // =========================

  static Future<http.Response> _request(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
    bool isRetry = false,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}$path");

    final token = await _storage.getAccessToken();

    final requestHeaders = {
      "Content-Type": "application/json",
      ...?headers,
      if (token != null) "Authorization": "Bearer $token",
    };

    http.Response response;

    try {
      switch (method) {
        case "POST":
          response = await http
              .post(url, headers: requestHeaders, body: body)
              .timeout(_timeout);
          break;

        case "PUT":
          response = await http
              .put(url, headers: requestHeaders, body: body)
              .timeout(_timeout);
          break;

        case "GET":
        default:
          response = await http
              .get(url, headers: requestHeaders)
              .timeout(_timeout);
      }
    } on TimeoutException {
      throw Exception("REQUEST_TIMEOUT");
    } catch (_) {
      throw Exception("NETWORK_ERROR");
    }

    /// 🔴 401 → refresh token
    if (response.statusCode == 401 && !isRetry) {
      await _handleRefresh();

      return _request(
        method,
        path,
        headers: headers,
        body: body,
        isRetry: true,
      );
    }

    return response;
  }

  // =========================
  // REFRESH TOKEN (QUEUE SAFE)
  // =========================

  static Future<void> _handleRefresh() async {
    if (_isRefreshing) {
      return _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final success = await _refreshTokenRaw();

      if (!success) {
        _authProvider?.forceLogout();
        throw Exception("SESSION_EXPIRED");
      }

      _refreshCompleter?.complete();
    } catch (e) {
      _refreshCompleter?.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// 🔥 KHÔNG dùng ApiClient
  static Future<bool> _refreshTokenRaw() async {
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null) return false;

    try {
      final url =
          Uri.parse("${ApiConfig.baseUrl}/api/auth/refresh-token");

      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"refreshToken": refreshToken}),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (data["isOk"] == true && data["result"] != null) {
        await _storage.saveTokens(
          accessToken: data["result"]["accessToken"],
          refreshToken: data["result"]["refreshToken"],
        );

        return true;
      }
    } catch (_) {}

    return false;
  }

  // =========================
  // RESPONSE PARSER (GENERIC)
  // =========================

  static ApiResponse<T> _parse<T>(
    http.Response response,
    T Function(dynamic json)? fromJsonT,
  ) {
    try {
      final json = jsonDecode(response.body);

      if (json is! Map<String, dynamic>) {
        return ApiResponse.failure(message: "Invalid response format");
      }

      return ApiResponse<T>.fromJson(json, fromJsonT);
    } catch (_) {
      return ApiResponse.failure(message: "Parse error");
    }
  }

  // =========================
  // UPLOAD FILE
  // =========================

  static Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required String fieldName,
    required String filePath,
    Map<String, String>? fields,
    String mimeType = "image/jpeg",
    T Function(dynamic json)? fromJsonT,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}$path");

    Future<http.Response> send() async {
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

      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    }

    try {
      var response = await send();

      if (response.statusCode == 401) {
        await _handleRefresh();
        response = await send();
      }

      return _parse<T>(response, fromJsonT);
    } catch (_) {
      return ApiResponse.failure(message: "Upload failed");
    }
  }
}