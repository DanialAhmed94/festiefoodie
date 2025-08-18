import 'package:flutter/material.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

class SnackbarUtility {
  static void showSnackbar(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.success,
    Duration duration = const Duration(seconds: 3),
  }) {
    IconData icon;
    Color backgroundColor;

    switch (type) {
      case SnackbarType.success:
        icon = Icons.check_circle;
        backgroundColor = const Color(0xFFF96222); // Brand orange
        break;
      case SnackbarType.error:
        icon = Icons.error_outline;
        backgroundColor = Colors.red.shade600;
        break;
      case SnackbarType.warning:
        icon = Icons.warning_amber_rounded;
        backgroundColor = Colors.orange.shade600;
        break;
      case SnackbarType.info:
        icon = Icons.info_outline;
        backgroundColor = Colors.blue.shade600;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Convenience methods for different types
  static void showSuccess(BuildContext context, String message) {
    showSnackbar(context, message, type: SnackbarType.success);
  }

  static void showError(BuildContext context, String message) {
    showSnackbar(context, message, type: SnackbarType.error);
  }

  static void showWarning(BuildContext context, String message) {
    showSnackbar(context, message, type: SnackbarType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    showSnackbar(context, message, type: SnackbarType.info);
  }
}
