// /// core/network/auth_api.dart

// import 'package:dio/dio.dart';

// import '../config/app_config.dart';

// /// ─────────────────────────────────────────────────────────
// /// AUTH API (SAFE - NO INTERCEPTOR)
// /// ─────────────────────────────────────────────────────────
// ///
// /// 🔥 QUAN TRỌNG:
// /// - Dùng Dio RIÊNG (không interceptor)
// /// - Tránh loop vô hạn khi refresh token
// ///
// class AuthApi {
//   AuthApi() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: AppConfig.baseUrl,
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         sendTimeout: const Duration(seconds: 30),
//         headers: {'Content-Type': 'application/json'},
//       ),
//     );
//   }

//   late final Dio _dio;

//   /// ===================== LOGIN =====================
//   Future<Response> login({required String username, required String password}) {
//     return _dio.post(
//       '/api/auth/login',
//       data: {'username': username, 'password': password},
//     );
//   }

//   /// ===================== REFRESH TOKEN =====================
//   Future<Response> refreshToken({required String refreshToken}) {
//     return _dio.post(
//       '/api/auth/refresh-token',
//       data: {'refreshToken': refreshToken},
//     );
//   }

//   /// ===================== REGISTER =====================
//   Future<Response> register({
//     required String email,
//     required String password,
//     required String confirmPassword,
//   }) {
//     return _dio.post(
//       '/api/auth/register',
//       data: {
//         "email": email,
//         "password": password,
//         "confirmPassword": confirmPassword,
//       },
//     );
//   }

//   /// ===================== LOGOUT =====================
//   Future<Response> logout() {
//     return _dio.post('/api/auth/logout');
//   }

//   /// ===================== PROFILE =====================
//   Future<Response> getProfile() {
//     return _dio.get('/api/auth/get-profile');
//   }

//   /// ===================== FORGOT PASSWORD =====================
//   Future<Response> forgotPassword({required String username}) {
//     return _dio.post('/api/auth/forgot-password', data: {'username': username});
//   }

//   /// ===================== RESET PASSWORD =====================
//   Future<Response> resetPassword({
//     required String username,
//     required String resetCode,
//     required String newPassword,
//     required String confirmPassword,
//   }) {
//     return _dio.post(
//       '/api/auth/reset-password',
//       data: {
//         'username': username,
//         'resetCode': resetCode,
//         'newPassword': newPassword,
//         'confirmPassword': confirmPassword,
//       },
//     );
//   }
// }
