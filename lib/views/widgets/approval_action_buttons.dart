import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ApprovalActionButtons extends StatelessWidget {
  final String primaryLabel;
  final String secondaryLabel;
  final IconData primaryIcon;
  final IconData secondaryIcon;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;
  final bool isLoading;

  const ApprovalActionButtons({
    Key? key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.primaryIcon,
    required this.secondaryIcon,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPrimaryPressed,
            icon: Icon(primaryIcon, color: Colors.white, size: 20),
            label: Text(
              primaryLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onSecondaryPressed,
            icon: Icon(secondaryIcon, color: Colors.white, size: 20),
            label: Text(
              secondaryLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
