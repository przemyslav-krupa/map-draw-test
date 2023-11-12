import 'dart:math';

import 'model/paths.pb.dart';

const double scale = 1000.0;

List<double> generateVerticesForPath(Path path) {
  final result = <double>[];
  for (var i = 0; i < path.points.length - 2; i++) {
    Vector2 a = Vector2(
        x: (17.3 - path.points[i].x) * scale,
        y: (-51 + path.points[i].y) * scale);
    Vector2 b = Vector2(
        x: (17.3 - path.points[i + 1].x) * scale,
        y: (-51 + path.points[i + 1].y) * scale);
    result.addAll(generateLine(a, b, path.thickness).expand(expandPoints));
  }
  return result;
}

Iterable<double> expandPoints(Vector2 point) sync* {
  yield point.x;
  yield point.y;
}

List<Vector2> generateLine(Vector2 a, Vector2 b, int thicknessValue) {
  final thickness = thicknessValue * 0.1;
  final result = <Vector2>[];
  final perp1 = Vector2(x: a.y - b.y, y: b.x - a.x);
  final perp2 = Vector2(x: b.y - a.y, y: a.x - b.x);
  final mag1 = sqrt(perp1.x * perp1.x + perp1.y * perp1.y);
  final mag2 = sqrt(perp2.x * perp2.x + perp2.y * perp2.y);
  final p1normalized =
  Vector2(x: perp1.x * thickness / mag1, y: perp1.y * thickness / mag1);
  final p2normalized =
  Vector2(x: perp2.x * thickness / mag2, y: perp2.y * thickness / mag2);
  result.add(Vector2(x: a.x + p1normalized.x, y: a.y + p1normalized.y));
  result.add(Vector2(x: b.x + p1normalized.x, y: b.y + p1normalized.y));
  result.add(Vector2(x: a.x + p2normalized.x, y: a.y + p2normalized.y));
  result.add(Vector2(x: a.x + p2normalized.x, y: a.y + p2normalized.y));
  result.add(Vector2(x: b.x + p2normalized.x, y: b.y + p2normalized.y));
  result.add(Vector2(x: b.x + p1normalized.x, y: b.y + p1normalized.y));
  return result;
}
