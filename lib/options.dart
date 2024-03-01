import 'dart:convert';
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
  static Future<void> load(String imageName) async {
    try {
      await platform.invokeMethod('load', {'imageName': imageName});
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

  /// Method to toggle overlay mode.
  static Future<void> isOverlay(bool isOverlay) async {
    try {
      await platform.invokeMethod('isOverlay', {'isOverlay': !isOverlay});
    } catch (e) {
      log("Error invoking isOverlay method: $e");
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

  /// Method to load the bitmap from bytearray.
  static Future<void> loadBitmapFromByteArray(Uint8List byteArray) async {
    try {
      String base64String = base64Encode(byteArray);
      await platform.invokeMethod('loadBitmapFromByteArray', {
        'byteArray': base64String,
      });
    } catch (e) {
      log("Error invoking loadBitmapFromByteArray method: $e");
      rethrow;
    }
  }

  /// Checks if the canvas is currently being written on.
  static Future<bool> isWriting() async {
    try {
      bool isWriting = await platform.invokeMethod('isWriting');
      return isWriting;
    } catch (e) {
      log("Error invoking isWriting method: $e");
      rethrow;
    }
  }

  /// Checks if the canvas is currently being written on.
  static Future<bool> isShown() async {
    try {
      bool isShown = await platform.invokeMethod('isShown');
      return isShown;
    } catch (e) {
      log("Error invoking isShown method: $e");
      rethrow;
    }
  }

  /// Checks if the canvas is currently being written on.
  static Future<bool> isInEditMode() async {
    try {
      bool isInEditMode = await platform.invokeMethod('isInEditMode');
      return isInEditMode;
    } catch (e) {
      log("Error invoking isInEditMode method: $e");
      rethrow;
    }
  }

  /// Checks if the canvas has been edited.
  static Future<bool> isEdited() async {
    try {
      bool isEdited = await platform.invokeMethod('isEdited');
      return isEdited;
    } catch (e) {
      log("Error invoking isWriting method: $e");
      rethrow;
    }
  }

  /// Method to refresh current view.
  static Future<void> refreshCurrentView() async {
    try {
      await platform.invokeMethod('refreshCurrentView');
    } catch (e) {
      log("Error invoking refreshCurrentView method: $e");
    }
  }

  /// Method to refresh drawable state.
  static Future<void> refreshDrawableState() async {
    try {
      await platform.invokeMethod('refreshDrawableState');
    } catch (e) {
      log("Error invoking refreshDrawableState method: $e");
    }
  }

  /// Method to set elevation.
  static Future<void> setElevation(double elevation) async {
    try {
      await platform.invokeMethod('setElevation', {'elevation': elevation});
    } catch (e) {
      log("Error invoking setElevation method: $e");
    }
  }

  /// Method to set isHovered.
  static Future<void> isHovered(bool hovered) async {
    try {
      await platform.invokeMethod('isHovered', {'hovered': hovered});
    } catch (e) {
      log("Error invoking isHovered method: $e");
    }
  }

  /// Method to refresh bitMap.
  static Future<void> refreshBitmap() async {
    try {
      await platform.invokeMethod(
        'refreshBitmap',
      );
    } catch (e) {
      log("Error invoking refreshBitmap method: $e");
    }
  }
}
