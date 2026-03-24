import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// ────────────── COMMON STYLES ──────────────
const double kFieldBorderRadius = 12.0;
const EdgeInsets kFieldContentPadding = EdgeInsets.symmetric(
  horizontal: 16,
  vertical: 15,
);

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

BoxDecoration kFieldDecoration({Color color = Colors.white}) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(kFieldBorderRadius),
  border: Border.all(color: const Color(0xFFE5E7EB)),
);

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
  final String? Function(String?)? validator;

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
      decoration: kFieldDecoration(),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: kInputTextStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: kHintTextStyle,
          border: InputBorder.none,
          contentPadding: kFieldContentPadding,
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
      decoration: kFieldDecoration(),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        style: kInputTextStyle,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: kHintTextStyle,
          border: InputBorder.none,
          contentPadding: kFieldContentPadding,
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
        padding: kFieldContentPadding,
        decoration: kFieldDecoration(),
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

/// ────────────── DROPDOWN FIELD ──────────────
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
      decoration: kFieldDecoration(),
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

/// ────────────── SEARCH FIELD ──────────────
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    required this.controller,
    this.hintText = 'Tìm kiếm',
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kFieldDecoration(),
      child: TextField(
        controller: controller,
        style: kInputTextStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: kHintTextStyle,
          border: InputBorder.none,
          contentPadding: kFieldContentPadding,
          prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF9CA3AF)),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}

/// ────────────── NUMBER FIELD ──────────────
class NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const NumberField({
    super.key,
    required this.controller,
    this.hintText = 'Nhập số',
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: hintText,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
}

/// ────────────── SWITCH FIELD ──────────────
class SwitchField extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const SwitchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: kLabelTextStyle),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF2563EB),
        ),
      ],
    );
  }
}

/// ────────────── MULTI-LINE TEXT FIELD ──────────────
class MultiLineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const MultiLineTextField({
    super.key,
    required this.controller,
    this.hintText = 'Nhập nội dung',
    this.maxLines = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kFieldDecoration(),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: kInputTextStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: kHintTextStyle,
          border: InputBorder.none,
          contentPadding: kFieldContentPadding,
        ),
      ),
    );
  }
}
