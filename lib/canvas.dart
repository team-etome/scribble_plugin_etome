import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scribble_etome/options.dart';

///Main canvas, call it on a full sized page(or almost full sized page)
class CanvasEtome extends StatelessWidget {
  const CanvasEtome(
      {super.key,
      this.topPaddingHeight = 0,
      this.imageName,
      this.saveFolder,
      this.drawingTool = DrawingTool.ballPointPen,
      this.penWidthValue = 3,
      this.isHandwriting = true});
  final int topPaddingHeight;
  final String? imageName;
  final String? saveFolder;
  final DrawingTool drawingTool;
  final int penWidthValue;
  final bool isHandwriting;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'leywin/etome/scribble_etome';
    String? saveFolderPath =
        saveFolder != null ? '/storage/emulated/0/$saveFolder/' : null;
    final Map<String, dynamic> creationParams = <String, dynamic>{
      "topPaddingHeight": topPaddingHeight,
      "imageName": imageName,
      "saveFolderPath": saveFolderPath,
      "drawingToolIndex": drawingTool.index,
      "penWidthValue": penWidthValue,
      "isHandwriting": isHandwriting,
    };

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
