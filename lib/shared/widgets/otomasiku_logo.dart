import 'package:flutter/material.dart';

class OtomasikuLogo extends StatelessWidget {
  const OtomasikuLogo({
    super.key,
    this.size = 40,
    this.classic = false,
  });

  final double size;
  final bool classic;

  @override
  Widget build(BuildContext context) {
    final gap = size * 0.05;
    final diamondSize = size * 0.22;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE7192D),
        borderRadius: BorderRadius.circular(classic ? size * 0.12 : size * 0.18),
        boxShadow: classic
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFE7192D).withValues(alpha: 0.28),
                  blurRadius: size * 0.28,
                  offset: Offset(0, size * 0.1),
                ),
              ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Diamond(size: diamondSize),
                SizedBox(width: gap),
                _Diamond(size: diamondSize),
              ],
            ),
            SizedBox(height: gap),
            _Diamond(size: diamondSize),
          ],
        ),
      ),
    );
  }
}

class _Diamond extends StatelessWidget {
  const _Diamond({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785398,
      child: Container(
        width: size,
        height: size,
        color: Colors.white,
      ),
    );
  }
}
