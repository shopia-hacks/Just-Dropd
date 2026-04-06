import 'package:flutter/material.dart';

class NumberBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double size;

  const NumberBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Georgia',
            fontSize: size * 0.42,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}