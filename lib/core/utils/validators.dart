typedef Validator = String? Function(String?);

class Validators {
  Validators._();

  // ── REQUIRED ─────────────────────────
  static String? required(String? value, {String field = 'Trường'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field không được để trống';
    }
    return null;
  }

  // ── EMAIL ────────────────────────────
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }

    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }

    return null;
  }

  // ── PASSWORD ─────────────────────────
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    if (value.length < 6) {
      return 'Min 6 characters';
    }

    return null;
  }

  // ── MIN LENGTH ───────────────────────
  static String? minLength(String? value, int length) {
    if (value == null || value.length < length) {
      return 'Tối thiểu $length ký tự';
    }
    return null;
  }

  // ── NUMBER ───────────────────────────
  static String? number(String? value) {
    if (value == null || value.isEmpty) return null;

    if (double.tryParse(value) == null) {
      return 'Số không hợp lệ';
    }

    return null;
  }
}

// ── COMBINE VALIDATORS (PRO) ───────────
Validator combine(List<Validator> validators) {
  return (value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) return result;
    }
    return null;
  };
}