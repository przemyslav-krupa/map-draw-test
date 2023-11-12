
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> writeData(List<int> bytes, String name) async {
  final path = await localPath;
  final file = File('$path/$name');

  return file.writeAsBytes(bytes);
}

Future<File> writeString(String string, String name) async {
  final path = await localPath;
  final file = File('$path/$name');

  return file.writeAsString(string);
}