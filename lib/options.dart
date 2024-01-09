import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:scribble_etome/models.dart';

class CanvasController {
  static const platform = MethodChannel('canvas_etome_options');

  static Future<void> undo() async {
    try {
      await platform.invokeMethod('undo');
    } catch (e) {
      log("Error invoking undo method: $e");
    }
  }

  static Future<void> redo() async {
    try {
      await platform.invokeMethod('redo');
    } catch (e) {
      log("Error invoking redo method: $e");
    }
  }

  static Future<void> clear() async {
    try {
      await platform.invokeMethod('clear');
    } catch (e) {
      log("Error invoking clear method: $e");
    }
  }

  static Future<void> destroy() async {
    try {
      await platform.invokeMethod('destroy');
    } catch (e) {
      log("Error invoking destroy method: $e");
    }
  }

  static Future<void> load(List<int> byteArray) async {
    try {
      await platform.invokeMethod('load', {'bitmap': byteArray});
    } catch (e) {
      log("Error invoking load method: $e");
    }
  }

  static Future<void> setPenType() async {
    try {
      await platform.invokeMethod('strokeType', 1);
    } catch (e) {
      log("Error invoking setPenstroke method: $e");
    }
  }

  static Future<void> setPenWidth(int penWidth) async {
    try {
      await platform.invokeMethod('penWidth', penWidth);
    } catch (e) {
      log("Error invoking setPenWidth method: $e");
    }
  }

  static Future<void> setEraserWidth(int eraserWidth) async {
    try {
      await platform.invokeMethod('eraserWidth', eraserWidth);
    } catch (e) {
      log("Error invoking setEraserWidth method: $e");
    }
  }

  static Future<void> isHandwriting(bool isHandwriting) async {
    try {
      await platform.invokeMethod('isHandwriting', isHandwriting);
    } catch (e) {
      log("Error invoking setEraserWidth method: $e");
    }
  }

  static save(String directoryPath) async {
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyyMMdd-HHmmss').format(now);
      final bitmap =
          await platform.invokeMethod('save', {"imageName": formattedDate});
      destroy();
      return SaveResult(
        bitmap: bitmap,
        dateTimeNow: formattedDate,
        directoryPath: directoryPath,
      );
    } catch (e) {
      log("Error invoking save method: $e");
      rethrow;
    }
  }
}
