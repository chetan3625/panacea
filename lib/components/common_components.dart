import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final IconData? prefixIcon;
  final bool isNumber;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    required this.label,
    this.prefixIcon,
    this.isNumber = false,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      obscureText: obscureText,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label, // Used for forms
        hintText: label, // Used for login
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
        border: const OutlineInputBorder(),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}
