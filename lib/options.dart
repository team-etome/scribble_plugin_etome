import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:scribble_etome/models.dart';

/// Enum to represent different drawing tools.
enum DrawingTool { ballPointPen, fountainPen, pencil, linearEraser, areaEraser }

class CanvasController {
  static const platform = MethodChannel('canvas_etome_options');

  /// Method to undo the last action.
  static Future<void> undo() async {
    try {
      await platform.invokeMethod('undo');
    } catch (e) {
      log("Error invoking undo method: $e");
    }
  }

  /// Method to redo the last undone action.
  static Future<void> redo() async {
    try {
      await platform.invokeMethod('redo');
    } catch (e) {
      log("Error invoking redo method: $e");
    }
  }

  /// Method to clear the canvas.
  static Future<void> clear() async {
    try {
      await platform.invokeMethod('clear');
    } catch (e) {
      log("Error invoking clear method: $e");
    }
  }

  /// Method to destroy the canvas.
  static Future<void> destroy() async {
    try {
      await platform.invokeMethod('destroy');
    } catch (e) {
      log("Error invoking destroy method: $e");
    }
  }

  /// Method to load a drawing from a byte array.
  static Future<void> load(String directoryPath) async {
    try {
      await platform.invokeMethod('load', {'directoryPath': directoryPath});
    } catch (e) {
      log("Error invoking load method: $e");
    }
  }

  /// Method to set the drawing tool (pen type).
  static Future<void> setDrawingTool(DrawingTool drawingType) async {
    try {
      await platform
          .invokeMethod('setPenStroke', {'strokeType': drawingType.index});
    } catch (e) {
      log("Error invoking setDrawingTool method: $e");
    }
  }

  /// Method to set the width of the pen.
  static Future<void> setPenWidth(int penWidth) async {
    try {
      await platform.invokeMethod('setPenWidth', {'penWidth': penWidth});
    } catch (e) {
      log("Error invoking setPenWidth method: $e");
    }
  }

  /// Method to set the width of the eraser.
  static Future<void> setEraserWidth(int eraserWidth) async {
    try {
      await platform
          .invokeMethod('setEraserWidth', {'eraserWidth': eraserWidth});
    } catch (e) {
      log("Error invoking setEraserWidth method: $e");
    }
  }

  /// Method to toggle handwriting mode.
  static Future<void> isHandwriting(bool isHandwriting) async {
    try {
      await platform
          .invokeMethod('isHandwriting', {'isHandwriting': isHandwriting});
    } catch (e) {
      log("Error invoking isHandwriting method: $e");
    }
  }

  /// Method to save the canvas drawing.
  static Future<SaveResult> save(String directoryPath) async {
    try {
      DateTime now = DateTime.now();
      final bitmap =
          await platform.invokeMethod('save', {"imageName": directoryPath});
      clear();
      return SaveResult(
        bitmap: bitmap,
        dateTimeNow: now.toString(),
        directoryPath: directoryPath,
      );
    } catch (e) {
      log("Error invoking save method: $e");
      rethrow;
    }
  }

  /// Method to get the current drawing bitmap.
  static Future<List<int>> getBitmap() async {
    try {
      List<int> bitmap = await platform.invokeMethod('getBitmap');
      return bitmap;
    } catch (e) {
      log("Error invoking getBitmap method: $e");
      rethrow;
    }
  }
}
