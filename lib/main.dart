import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'loaders.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Float32List vertices = Float32List(2);
  final _counter = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SizedBox.expand(
        child: Center(
          child: FutureBuilder<Float32List>(
              future: loadProtobuf(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                return CustomPaint(
                  painter: MapPainter(
                    vertices: snapshot.data!,
                    repaint: _counter,
                  ),
                  size: const Size(1000, 1000),
                );
              }),
        ),
      ),
    );
  }
}

class MapPainter extends CustomPainter {
  final Float32List vertices;

  MapPainter({super.repaint, required this.vertices});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..color = Colors.indigoAccent
      ..style = PaintingStyle.stroke;

    canvas.drawVertices(
        Vertices.raw(VertexMode.triangles, vertices), BlendMode.src, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
