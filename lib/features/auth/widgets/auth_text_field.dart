import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      validator: validator,
      onTap: onTap,
      readOnly: readOnly,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00CC00)),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00CC00), width: 2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        fillColor: Colors.grey[900],
        filled: true,
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }
}