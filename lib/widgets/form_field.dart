import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// ────────────── COMMON STYLES ──────────────
const TextStyle kLabelTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: Color(0xFF374151),
);

const TextStyle kInputTextStyle = TextStyle(
  fontSize: 15,
  color: Color(0xFF111827),
);

const TextStyle kHintTextStyle = TextStyle(
  fontSize: 15,
  color: Color(0xFF9CA3AF),
);

BoxDecoration kInputDecoration() => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: const Color(0xFFE5E7EB)),
);

EdgeInsets kContentPadding() =>
    const EdgeInsets.symmetric(horizontal: 16, vertical: 15);

/// ────────────── LABEL ──────────────
class LabelText extends StatelessWidget {
  final String text;
  const LabelText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: kLabelTextStyle);
  }
}

/// ────────────── CUSTOM TEXT FIELD ──────────────
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator; // thêm validator

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kInputDecoration(),
      child: TextFormField(
        // TextFormField để validator hoạt động
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: kInputTextStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: kHintTextStyle,
          border: InputBorder.none,
          contentPadding: kContentPadding(),
        ),
      ),
    );
  }
}

/// ────────────── PASSWORD FIELD ──────────────
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;

  const PasswordField({
    super.key,
    required this.controller,
    this.hintText = 'Nhập mật khẩu',
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kInputDecoration(),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        style: kInputTextStyle,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: kHintTextStyle,
          suffixIcon: IconButton(
            icon: Icon(
              _obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9CA3AF),
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: InputBorder.none,
          contentPadding: kContentPadding(),
        ),
      ),
    );
  }
}

/// ────────────── DATE FIELD ──────────────
class DateField extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final String placeholder;

  const DateField({
    super.key,
    required this.selectedDate,
    required this.onTap,
    this.placeholder = 'mm/dd/yyyy',
  });

  String _formatDate(DateTime date) => DateFormat('MM/dd/yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: kContentPadding(),
        decoration: kInputDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedDate != null ? _formatDate(selectedDate!) : placeholder,
                style: TextStyle(
                  fontSize: 15,
                  color: selectedDate != null
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }
}

/// ────────────── GENERIC DROPDOWN FIELD ──────────────
class DropdownField<T> extends StatelessWidget {
  final T? selectedValue;
  final List<T> options;
  final ValueChanged<T?> onChanged;
  final String hint;

  const DropdownField({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
    this.hint = 'Chọn giá trị',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: kInputDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: selectedValue,
          hint: Text(hint, style: kHintTextStyle),
          isExpanded: true,
          style: kInputTextStyle,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6B7280),
          ),
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// ────────────── SUBMIT BUTTON ──────────────
class SubmitButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;

  const SubmitButton({
    super.key,
    required this.onPressed,
    this.label = 'Xác nhận',
    this.isLoading = false,
    this.backgroundColor = const Color(0xFF2563EB),
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }
}

/// ────────────── LOGOUT BUTTON ──────────────
class LogoutButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const LogoutButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SubmitButton(
      onPressed: onPressed,
      label: 'Đăng xuất',
      isLoading: isLoading,
      backgroundColor: const Color(0xFFEF4444), // màu đỏ
      foregroundColor: Colors.white,
    );
  }
}

/// ────────────── EDIT BUTTON ──────────────
class EditButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const EditButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SubmitButton(
      onPressed: onPressed,
      label: 'Chỉnh sửa',
      isLoading: isLoading,
      backgroundColor: const Color(0xFF10B981), // màu xanh lá
      foregroundColor: Colors.white,
    );
  }
}

/// ────────────── CANCEL BUTTON ──────────────
class CancelButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const CancelButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SubmitButton(
      onPressed: onPressed,
      label: 'Hủy',
      isLoading: isLoading,
      backgroundColor: const Color(0xFF6B7280), // màu xám
      foregroundColor: Colors.white,
    );
  }
}
