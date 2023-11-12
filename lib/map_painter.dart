import 'dart:ui';

import 'package:flutter/material.dart';

class MapPainter extends CustomPainter {
  final Vertices vertices;
  final Matrix4 matrix;

  MapPainter({super.repaint, required this.vertices, required this.matrix});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.indigoAccent
      ..style = PaintingStyle.stroke;
    canvas.transform(matrix.storage);
    canvas.drawVertices(vertices, BlendMode.src, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
