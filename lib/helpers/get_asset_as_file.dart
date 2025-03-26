import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<File> getAssetAsFile(String assetPath) async {
  // Get the temporary directory
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${assetPath.split('/').last}');

  // Check if file already exists to avoid unnecessary copying
  if (!file.existsSync()) {
    // Load asset as ByteData
    ByteData data = await rootBundle.load(assetPath);
    List<int> bytes = data.buffer.asUint8List();

    // Write the bytes to a new file
    await file.writeAsBytes(bytes);
  }

  return file;
}
