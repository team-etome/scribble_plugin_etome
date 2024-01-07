import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:scribble_etome/models.dart';

class CanvasEtomeOptions {
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

  static Future<void> load(List<int> bitArray) async {
    try {
      await platform.invokeMethod('load', {'bitArray': bitArray});
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

  static Future<SaveResult> save() async {
    try {
      final dateTimeNow = DateTime.now().toString().replaceAll(' ', '_');
      final bitmap =
          await platform.invokeMethod('save', {"imageName": dateTimeNow});
      destroy();
      return SaveResult(
        bitmap: bitmap,
        dateTimeNow: dateTimeNow,
      );
    } catch (e) {
      log("Error invoking save method: $e");
      rethrow;
    }
  }
}
