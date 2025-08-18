import 'package:flutter/material.dart';
import 'package:flutter_application_2/main.dart';

class CustomAlertDialog {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
    Color? iconColor,
    String cancelText = '',
    String confirmText = '',
    VoidCallback? onCancel,
    VoidCallback? onConfirm,
    Color? confirmButtonColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Center(
          child: Row(
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: iconColor ?? Colors.blue,
                  size: 30,
                ),
              if (icon != null) const SizedBox(width: 8),
              Text(
                textAlign: TextAlign.center,
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmButtonColor ?? Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              confirmText,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// // ​‌‍‌⁡⁢⁣⁣Example usage⁡​
// class ExampleUsage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         CustomAlertDialog.show(
//   context: context,
//   title: 'Attention',
//   content: 'Action importante',
//   icon: Icons.warning,
//   iconColor: Colors.orange,
//   cancelText: 'Non',
//   confirmText: 'Oui',
//   confirmButtonColor: Colors.red,
//   onConfirm: () {
//     // Action de confirmation
//   },
//   onCancel: () {
//     // Action d'annulation
//   }
// );
//       },
//       child: Text('Montrer le dialogue'),
//     );
//   }
// } // Basic usage


// Full customization

