// // lib/core/utils/validators.dart

// typedef Validator = String? Function(String?);

// class Validators {
//   Validators._();

//   // ── REQUIRED ─────────────────────────
//   static String? required(String? value, {String field = 'Trường'}) {
//     if (value == null || value.trim().isEmpty) {
//       return '$field không được để trống';
//     }
//     return null;
//   }

//   // ── EMAIL ────────────────────────────
//   static String? email(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Email không được để trống';
//     }

//     final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     if (!regex.hasMatch(value)) {
//       return 'Email không hợp lệ';
//     }

//     return null;
//   }

//   // ── PASSWORD ─────────────────────────
//   static String? password(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Mật khẩu không được để trống';
//     }

//     if (value.length < 6) {
//       return 'Min 6 characters';
//     }

//     return null;
//   }

//   // ── MIN LENGTH ───────────────────────
//   static String? minLength(String? value, int length) {
//     if (value == null || value.length < length) {
//       return 'Tối thiểu $length ký tự';
//     }
//     return null;
//   }

//   // ── NUMBER ───────────────────────────
//   static String? number(String? value) {
//     if (value == null || value.isEmpty) return null;

//     if (double.tryParse(value) == null) {
//       return 'Số không hợp lệ';
//     }

//     return null;
//   }
// }

// // ── COMBINE VALIDATORS (PRO) ───────────
// Validator combine(List<Validator> validators) {
//   return (value) {
//     for (final validator in validators) {
//       final result = validator(value);
//       if (result != null) return result;
//     }
//     return null;
//   };
// }

// lib/core/utils/validators.dart

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
  
  // ── NEW PASSWORD (register / reset — min 8) ──
  /// Dùng khi tạo hoặc đặt lại mật khẩu mới (yêu cầu chặt hơn login).
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }

    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }

    return null;
  }

  // ── CONFIRM PASSWORD ──────────────────
  /// [original] là giá trị của ô mật khẩu gốc cần so khớp.
  static Validator confirmPassword(String original) {
    return (value) {
      if (value == null || value.isEmpty) {
        return 'Vui lòng xác nhận mật khẩu';
      }
      if (value != original) {
        return 'Mật khẩu xác nhận không khớp';
      }
      return null;
    };
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
