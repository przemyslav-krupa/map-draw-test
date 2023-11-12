import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:geojson_vi/geojson_vi.dart';

import 'file_io.dart';
import 'generators.dart';
import 'model/paths.pb.dart';

Future<Float32List> loadFloat32List() async {
  print('Loading Float32List from bytes...');
  var t = DateTime.now();
  final bytes = await rootBundle.load('assets/vertices.bytes');
  final vertices = bytes.buffer.asFloat32List();
  print(
      'Vertices loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  print('Vertex count: ${vertices.length}');
  return vertices;
}


Future<Float32List> loadProtobuf() async {
  print('Loading protobuf from bytes...');
  var t = DateTime.now();
  final bytes = await rootBundle.load('assets/map_data.bytes');
  final pathCollection =
  PathCollection.fromBuffer(bytes.buffer.asUint8List());
  print(
      'Protobuf loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  print('Paths count: ${pathCollection.paths.length}');
  // print('Loading protobuf from json...');
  // t = DateTime.now();
  // final json = await rootBundle.loadString('assets/map_data.json');
  // final pathCollectionFromJson = PathCollection.fromJson(json);
  // print(
  //     'Json loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  // print('Paths count: ${pathCollectionFromJson.paths.length}');
  print('Generating Float32List...');
  t = DateTime.now();
  final verticesList = <double>[];
  for (var i = 0; i < pathCollection.paths.length; i++) {
    verticesList.addAll(generateVerticesForPath(pathCollection.paths[i]));
  }
  final vertices = Float32List.fromList(verticesList);
  print(
      'Float32List generated in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  print('Saving Float32List...');
  t = DateTime.now();
  await writeData(vertices.buffer.asInt64List(), 'vertices.bytes');
  print(
      'Float32List saved in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  return vertices;
}


Future<PathCollection> loadGeoJson() async {
  ///load from json and save paths as serialized protobuf
  print('Loading json...');
  var t = DateTime.now();
  final json = await rootBundle.loadString('assets/export.geojson');
  print(
      'Json loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  print('Parsing json...');
  t = DateTime.now();
  final geojson = GeoJSONFeatureCollection.fromJSON(json);
  print(
      'Json loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  print('Features count: ${geojson.features.length}');
  final pathCollection = PathCollection();
  print('Converting paths...');
  t = DateTime.now();
  for (GeoJSONFeature? element in geojson.features) {
    if (element?.geometry != null &&
        element!.geometry.type == GeoJSONType.lineString) {
      final path = Path();
      path.thickness = switch (element.properties?['highway']) {
        'motorway' => 5,
        'motorway_link' => 5,
        'trunk' => 5,
        'trunk_link' => 5,
        'primary' => 4,
        'primary_link' => 4,
        'secondary' => 3,
        'secondary_link' => 3,
        'tertiary' => 2,
        'tertiary_link' => 2,
        _ => 1,
      };
      for (List<double> point
      in (element.geometry as GeoJSONLineString).coordinates) {
        path.points.add(Vector2(x: point[0], y: point[1]));
      }
      pathCollection.paths.add(path);
    }
  }
  print(
      'Paths converted in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  print('Writing to file...');
  t = DateTime.now();
  await writeData(pathCollection.writeToBuffer(), 'map_data.bytes');
  print(
      'Data written to file in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  print('Writing protobuf to json...');
  t = DateTime.now();
  await writeString(pathCollection.writeToJson(), 'map_data.json');
  print(
      'Json written in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  return pathCollection;
}
