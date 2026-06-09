import 'package:flutter/material.dart';
import '../models/charity.dart';

class CharityAvatar extends StatelessWidget {
  final Charity charity;
  final double size;

  const CharityAvatar({super.key, required this.charity, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final color = Color(charity.colorValue);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(color: color.withOpacity(0.4), width: 1.5),
      ),
      child: Center(
        child: Text(
          charity.name.substring(0, 1).toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}