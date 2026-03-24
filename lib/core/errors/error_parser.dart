// lib/core/errors/error_parser.dart

class ErrorParser {
  static String parse(dynamic data) {
    if (data == null) return 'Có lỗi xảy ra';

    try {
      if (data['errors'] != null && data['errors'].isNotEmpty) {
        return data['errors'][0]['description'] ?? 'Có lỗi xảy ra';
      }

      if (data['warningMessages'] != null &&
          data['warningMessages'].isNotEmpty) {
        return data['warningMessages'][0];
      }

      if (data['message'] != null) {
        return data['message'];
      }
    } catch (_) {
      return 'Có lỗi xảy ra';
    }

    return 'Có lỗi xảy ra';
  }
}