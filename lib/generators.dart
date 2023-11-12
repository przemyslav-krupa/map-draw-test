import 'dart:math';

import 'model/paths.pb.dart';

const double scale = 1100.0;

List<double> generateVerticesForPath(Path path) {
  final result = <double>[];
  for (var i = 0; i < path.points.length - 1; i++) {
    Vector2 a = Vector2(
        x: (path.points[i].x - 16.8) * scale,
        y: (51.2 - path.points[i].y) * scale);
    Vector2 b = Vector2(
        x: (path.points[i + 1].x - 16.8) * scale,
        y: (51.2 - path.points[i + 1].y) * scale);
    result
        .addAll(generateLine(a, b, path.thickness * 0.1).expand(expandPoints));
  }
  return result;
}

Iterable<double> expandPoints(Vector2 point) sync* {
  yield point.x;
  yield point.y;
}

List<Vector2> generateLine(Vector2 a, Vector2 b, double thickness) {
  final result = <Vector2>[];
  final perp1a = Vector2(x: a.y - b.y, y: b.x - a.x);
  final perp1b = Vector2(x: b.y - a.y, y: a.x - b.x);
  final mag1a = sqrt(perp1a.x * perp1a.x + perp1a.y * perp1a.y);
  final mag1b = sqrt(perp1b.x * perp1b.x + perp1b.y * perp1b.y);
  final p1aNormalized =
      Vector2(x: perp1a.x * thickness / mag1a, y: perp1a.y * thickness / mag1a);
  final p1bNormalized =
      Vector2(x: perp1b.x * thickness / mag1b, y: perp1b.y * thickness / mag1b);
  result.add(Vector2(x: a.x + p1aNormalized.x, y: a.y + p1aNormalized.y));
  result.add(Vector2(x: b.x + p1aNormalized.x, y: b.y + p1aNormalized.y));
  result.add(Vector2(x: a.x + p1bNormalized.x, y: a.y + p1bNormalized.y));
  result.add(Vector2(x: a.x + p1bNormalized.x, y: a.y + p1bNormalized.y));
  result.add(Vector2(x: b.x + p1bNormalized.x, y: b.y + p1bNormalized.y));
  result.add(Vector2(x: b.x + p1aNormalized.x, y: b.y + p1aNormalized.y));

  return result;
}
