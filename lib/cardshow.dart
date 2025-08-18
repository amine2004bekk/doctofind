import 'package:flutter/material.dart';

class Cardshow extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback press;

  const Cardshow({
    super.key,
    required this.press,
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: InkWell(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0), color: Colors.blue),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Icon(icon),
            ],
          ),
        ),
      ),
    );
  }
}
