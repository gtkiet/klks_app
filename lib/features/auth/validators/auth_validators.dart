class AuthValidators {
  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName không được để trống";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return "Email không được để trống";

    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) return "Email không hợp lệ";

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return "Mật khẩu không được để trống";
    if (value.length < 6) return "Mật khẩu tối thiểu 6 ký tự";
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return "SĐT không được để trống";
    if (value.length < 9) return "SĐT không hợp lệ";
    return null;
  }
}