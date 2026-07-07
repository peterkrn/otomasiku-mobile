import 'package:flutter/material.dart';

class OtomasikuLogo extends StatelessWidget {
  const OtomasikuLogo({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.18),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFE7192D),
            alignment: Alignment.center,
            child: Icon(
              Icons.diamond_outlined,
              size: size * 0.5,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}
