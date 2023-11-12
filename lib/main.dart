import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:draw_map/model/paths.pb.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    loadProtobuf();
  }

  Future<void> loadProtobuf() async {
    print('Loading protobuf from bytes...');
    var t = DateTime.now();
    final bytes = await rootBundle.load('assets/map_data.bytes');
    final pathCollection =
        PathCollection.fromBuffer(bytes.buffer.asUint8List());
    print(
        'Protobuf loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    print('Paths count: ${pathCollection.paths.length}');
    print('Loading protobuf from json...');
    t = DateTime.now();
    final json = await rootBundle.loadString('assets/map_data.json');
    final pathCollectionFromJson = PathCollection.fromJson(json);
    print(
        'Json loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    print('Paths count: ${pathCollectionFromJson.paths.length}');
    print('Generating Float32List...');
    t = DateTime.now();
    final verticesList = <double>[];
    for (var i = 0; i < pathCollection.paths.length; i++) {
      verticesList.addAll(generateVerticesForPath(pathCollection.paths[i]));
    }
    final Float32List vertices = Float32List.fromList(verticesList);
    print(
        'Float32List generated in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    print('Saving Float32List...');
    t = DateTime.now();
    await writeData(vertices.buffer.asUint8List(), 'vertices.bytes');
    print(
        'Float32List saved in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    print('Multiplying...');
    t = DateTime.now();
    for (var element in vertices) {
      element = element * 5;
    }
    print(
        'Multiplied in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  }

  Future<void> loadJson() async {
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
    await writeString(pathCollection.writeToJson());
    print(
        'Json written in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
  }

  List<double> generateVerticesForPath(Path path) {
    final result = <double>[];
    for (var i = 0; i < path.points.length - 2; i++) {
      result.addAll(
          generateLine(path.points[i], path.points[i + 1], path.thickness)
              .expand(expandPoints));
    }
    return result;
  }

  Iterable<double> expandPoints(Vector2 point) sync* {
    yield point.x;
    yield point.y;
  }

  List<Vector2> generateLine(Vector2 a, Vector2 b, int thickness) {
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

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> writeData(List<int> bytes, String name) async {
  final path = await _localPath;
  final file = File('$path/$name');

  return file.writeAsBytes(bytes);
}

Future<File> writeString(String string) async {
  final path = await _localPath;
  final file = File('$path/map_data.json');

  return file.writeAsString(string);
}
