import 'dart:typed_data';
import 'dart:ui';

import 'package:draw_map/map_painter.dart';
import 'package:flutter/material.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({
    required this.vertices,
    super.key,
  });

  final Float32List vertices;

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  void initState() {
    super.initState();
    _vertices = Vertices.raw(VertexMode.triangles, widget.vertices);
  }

  late final Vertices _vertices;
  Matrix4 matrix = Matrix4.identity();
  Matrix4 resetMatrix = Matrix4.identity();
  double resetScale = 1.0;
  double currentScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        resetMatrix = matrix.clone();
      },
      onScaleUpdate: (details) {
        setState(() {
          currentScale = details.scale;
          resetMatrix.translate(
              details.focalPointDelta.dx / (resetScale * currentScale),
              details.focalPointDelta.dy / (resetScale * currentScale));
          matrix = resetMatrix.clone()..scale(currentScale, currentScale);
        });
      },
      onScaleEnd: (details) {
        resetScale = resetScale * currentScale;
      },
      onDoubleTap: () {
        setState(() {
          matrix = Matrix4.identity();
          resetScale = 1;
        });
      },
      child: CustomPaint(
        painter: MapPainter(vertices: _vertices, matrix: matrix),
        size: Size.infinite,
      ),
    );
  }
}
