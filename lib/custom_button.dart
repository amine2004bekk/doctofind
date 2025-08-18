// Dans custom_button.dart
import 'package:flutter/material.dart';

class Mybutton extends StatefulWidget {
  final bool isOutlined;
  final String text;
  final Color bgColor;
  final Color textColor;
  final VoidCallback onPressed;  // Ajout du paramètre onPressed

  const Mybutton({
    super.key,
    required this.text,
    required this.isOutlined,
    required this.bgColor,
    required this.textColor,
    required this.onPressed,  
  });

  @override
  State<Mybutton> createState() => _MybuttonState();
}

class _MybuttonState extends State<Mybutton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.bgColor,
          side: widget.isOutlined ? const BorderSide(color: Colors.black) : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: widget.textColor,
          ),
        ),
      ),
    );
  }
}


