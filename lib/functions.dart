import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<bool> saveBytes(List<int> bytes, String? imageName) async {
  try {
    final directory = Directory('/storage/emulated/0/Documents/Etome/');
    await directory.create(recursive: true);
    final filePath = '${directory.path}$imageName.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return true;
  } catch (e) {
    print('Error saving bytes: $e');
    return false;
  }
}
