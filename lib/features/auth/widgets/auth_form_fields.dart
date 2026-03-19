import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ===================
/// Text Field chuẩn UI + VALIDATOR
/// ===================
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: (_) => onChanged?.call(),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

/// ===================
/// Password Field + VALIDATOR
/// ===================
class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      validator: widget.validator,
      onChanged: (_) => widget.onChanged?.call(),
      decoration: InputDecoration(
        hintText: 'Nhập mật khẩu',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),

        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() => _obscure = !_obscure);
          },
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB)),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

/// ===================
/// Date Picker + VALIDATOR
/// ===================
class AuthDatePicker extends FormField<DateTime> {
  AuthDatePicker({
    super.key,
    super.initialValue,
    required void Function(DateTime) onPick,
    super.validator,
  }) : super(
         builder: (state) {
           final selectedDate = state.value;

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               GestureDetector(
                 onTap: () async {
                   final picked = await showDatePicker(
                     context: state.context,
                     initialDate: selectedDate ?? DateTime(2000, 1, 1),
                     firstDate: DateTime(1920),
                     lastDate: DateTime.now(),
                   );

                   if (picked != null) {
                     state.didChange(picked);
                     onPick(picked);
                   }
                 },
                 child: Container(
                   padding: const EdgeInsets.symmetric(
                     horizontal: 16,
                     vertical: 14,
                   ),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(
                       color: state.hasError
                           ? Colors.red
                           : const Color(0xFFE5E7EB),
                     ),
                   ),
                   child: Row(
                     children: [
                       Expanded(
                         child: Text(
                           selectedDate != null
                               ? "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}"
                               : 'mm/dd/yyyy',
                           style: TextStyle(
                             color: selectedDate != null
                                 ? const Color(0xFF111827)
                                 : const Color(0xFF9CA3AF),
                           ),
                         ),
                       ),
                       const Icon(Icons.calendar_today_outlined, size: 20),
                     ],
                   ),
                 ),
               ),

               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 6, left: 12),
                   child: Text(
                     state.errorText!,
                     style: const TextStyle(color: Colors.red, fontSize: 12),
                   ),
                 ),
             ],
           );
         },
       );
}

/// ===================
/// Dropdown + VALIDATOR
/// ===================
class AuthDropdown extends FormField<String> {
  AuthDropdown({
    super.key,
    required List<String> items,
    required String hint,
    super.initialValue,
    required void Function(String?) onChanged,
    super.validator,
  }) : super(
         builder: (state) {
           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 16),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(
                     color: state.hasError
                         ? Colors.red
                         : const Color(0xFFE5E7EB),
                   ),
                 ),
                 child: DropdownButtonHideUnderline(
                   child: DropdownButton<String>(
                     value: state.value,
                     hint: Text(
                       hint,
                       style: const TextStyle(color: Color(0xFF9CA3AF)),
                     ),
                     isExpanded: true,
                     items: items
                         .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                         .toList(),
                     onChanged: (val) {
                       state.didChange(val);
                       onChanged(val);
                     },
                   ),
                 ),
               ),

               if (state.hasError)
                 Padding(
                   padding: const EdgeInsets.only(top: 6, left: 12),
                   child: Text(
                     state.errorText!,
                     style: const TextStyle(color: Colors.red, fontSize: 12),
                   ),
                 ),
             ],
           );
         },
       );
}

/// ===================
/// Button (giữ nguyên)
/// ===================
class AuthPrimaryButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
