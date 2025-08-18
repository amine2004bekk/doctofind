// ignore_for_file: file_names

import 'package:flutter/material.dart';


class MyTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const MyTextField({
    super.key,
    required this.hint,
    required this.icon,
    required this.isPassword,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        hintStyle: const TextStyle(fontSize: 14, color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
              color: Color.fromARGB(255, 41, 92, 201), width: 1),
        ),
      ),
    );
  }
}
