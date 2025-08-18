// ignore_for_file: file_names

import 'package:flutter/material.dart';

class MyCustomSocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final String iconPath;

  const MyCustomSocialButton({
    super.key,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
    );
  }
}
