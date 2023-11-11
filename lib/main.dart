import 'dart:io';
import 'dart:typed_data';

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
    loadJson();

  }

  Future<void> loadJson() async {
    ///load from json and save paths as binary List<List<double>>
    // print('Loading json...');
    // var t = DateTime.now();
    // final json = await rootBundle.loadString('export.geojson');
    // print('Json loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    // print('Parsing json...');
    // t = DateTime.now();
    // final geojson = GeoJSONFeatureCollection.fromJSON(json);
    // print('Json loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    // print('Features count: ${geojson.features.length}');
    // final listOfPaths = <List<double>>[];
    // print('Converting paths...');
    // t = DateTime.now();
    // for (GeoJSONFeature? element in geojson.features) {
    //   if(element?.geometry != null && element!.geometry.type == GeoJSONType.lineString){
    //     final path = <double>[];
    //     for (List<double> point in (element.geometry as GeoJSONLineString).coordinates) {
    //       path.add(point[0]);
    //       path.add(point[1]);
    //     }
    //     listOfPaths.add(path);
    //   }
    // }
    // print('Paths converted in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    // print('Writing to file...');
    // t = DateTime.now();
    // await writeData(listOfPaths);
    // print('Data written to file in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');

    print('Loading json...');
    var t = DateTime.now();
    final json = await rootBundle.loadString('export.geojson');
    print('Json loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    print('Parsing json...');
    t = DateTime.now();
    final geojson = GeoJSONFeatureCollection.fromJSON(json);
    print('Json loaded in: ${DateTime.now().millisecondsSinceEpoch - t.millisecondsSinceEpoch}');
    print('Features count: ${geojson.features.length}');
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

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/map_data.binary');
}

Future<File> writeData(List<List<double>> data) async {
  final file = await _localFile;

  Uint8List bytes = serializeData(data);

  return file.writeAsBytes(bytes);
}


// Function to serialize List<List<double>> to bytes
Uint8List serializeData(List<List<double>> data) {
  final byteData = Uint8List(8 * data.length * data[0].length);

  int offset = 0;
  for (final row in data) {
    for (final doubleVal in row) {
      byteData.buffer.asByteData().setFloat64(offset, doubleVal, Endian.little);
      offset += 8; // Double takes 8 bytes
    }
  }
  return byteData;
}

// Function to deserialize bytes back to List<List<double>>
List<List<double>> deserializeData(Uint8List byteData) {
  final dataList = <List<double>>[];
  final dataLength = byteData.lengthInBytes ~/ 8; // Double takes 8 bytes

  for (var i = 0; i < dataLength; i++) {
    final doubleVal = byteData.buffer.asByteData().getFloat64(i * 8, Endian.little);
    if (i % 3 == 0) {
      dataList.add(<double>[]);
    }
    dataList.last.add(doubleVal);
  }

  return dataList;
}