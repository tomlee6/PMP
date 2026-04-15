import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';

class CustomTimePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const CustomTimePickerField({
    Key? key,
    required this.controller,
    required this.labelText,
  }) : super(key: key);

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      // Format as "hh:mm a" exactly as in screenshot: "09:15 AM"
      controller.text = DateFormat('hh:mm a').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectTime(context),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a time';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: null,
        hintText: labelText,
        prefixIcon: const Icon(Icons.access_time, color: Colors.grey),
        suffixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Tap to change',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}
