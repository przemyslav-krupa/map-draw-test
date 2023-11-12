import 'dart:typed_data';
import 'dart:ui';

import 'package:draw_map/map_painter.dart';
import 'package:flutter/material.dart';

class MapWidget extends StatefulWidget {
  MapWidget({
    required this.vertices,
    super.key,
  });

  final Float32List vertices;

  @override
  _MapWidgetState createState() => _MapWidgetState();
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
  double realScale = 1.0;
  double currentScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) {
        resetMatrix = matrix.clone();
      },
      onScaleUpdate: (details) {
        setState(() {
          resetMatrix.translate(
              details.focalPointDelta.dx / (realScale * details.scale),
              details.focalPointDelta.dy / (realScale * details.scale));
          currentScale = details.scale;
          matrix = resetMatrix.clone()..scale(details.scale, details.scale);
        });
      },
      onScaleEnd: (details) {
        realScale = realScale * currentScale;
      },
      onDoubleTap: () {
        setState(() {
          matrix = Matrix4.identity();
        });
      },
      child: CustomPaint(
        painter: MapPainter(vertices: _vertices, matrix: matrix),
        size: Size.infinite,
      ),
    );
  }
}