// core/errors/app_exception.dart

enum ErrorType { network, unauthorized, validation, server, unknown }

class AppException implements Exception {
  final String message;
  final ErrorType type;
  final int? code;

  AppException(this.message, {this.type = ErrorType.unknown, this.code});

  @override
  String toString() => message;
}
