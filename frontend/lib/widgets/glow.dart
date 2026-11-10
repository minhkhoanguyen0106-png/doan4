import 'package:flutter/material.dart';

class GlowWidget extends StatelessWidget {
  const GlowWidget({super.key, required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

