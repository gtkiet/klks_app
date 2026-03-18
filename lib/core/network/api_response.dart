class ApiResponse<T> {
  final bool isOk;
  final T? data;
  final List<String> errors;

  const ApiResponse({
    required this.isOk,
    this.data,
    this.errors = const [],
  });

  /// =========================
  /// ✅ SUCCESS
  /// =========================
  factory ApiResponse.success(T data) {
    return ApiResponse(
      isOk: true,
      data: data,
      errors: const [],
    );
  }

  /// =========================
  /// ❌ FAILURE
  /// =========================
  factory ApiResponse.failure({
    String? message,
    List<String>? errors,
  }) {
    return ApiResponse(
      isOk: false,
      data: null,
      errors: errors ??
          (message != null ? [message] : ["Đã có lỗi xảy ra"]),
    );
  }

  /// =========================
  /// 🔄 FROM JSON (API chuẩn của bạn)
  /// =========================
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    final isOk = json["isOk"] ?? false;

    // Parse errors
    final List<String> parsedErrors =
        (json["errors"] as List<dynamic>?)
                ?.map((e) => e["description"]?.toString() ?? "")
                .where((e) => e.isNotEmpty)
                .toList() ??
            [];

    return ApiResponse<T>(
      isOk: isOk,
      data: isOk && fromJsonT != null
          ? fromJsonT(json["result"])
          : json["result"],
      errors: parsedErrors,
    );
  }

  /// =========================
  /// 🧠 HELPER
  /// =========================
  String get message {
    if (errors.isNotEmpty) return errors.first;
    return isOk ? "Success" : "Đã có lỗi xảy ra";
  }

  bool get hasError => !isOk;

  @override
  String toString() {
    return 'ApiResponse(isOk: $isOk, data: $data, errors: $errors)';
  }
}