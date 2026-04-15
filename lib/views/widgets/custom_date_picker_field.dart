import 'package:flutter/material.dart';

class CustomDatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback onTap;
  final String? Function(String?)? validator;

  const CustomDatePickerField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onTap,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: const Icon(Icons.calendar_today_outlined),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
