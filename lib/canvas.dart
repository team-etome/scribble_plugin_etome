import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scribble_etome/options.dart';

///Main canvas, call it on a full sized page(or almost full sized page)
class CanvasEtome extends StatelessWidget {
  const CanvasEtome(
      {super.key,
      this.topPaddingHeight = 0,
      this.imageName = '',
      this.saveFolderPath,
      this.drawingTool = DrawingTool.ballPointPen,
      this.penWidthValue = 3});
  final int topPaddingHeight;
  final String imageName;
  final String? saveFolderPath;
  final DrawingTool drawingTool;
  final int penWidthValue;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'leywin/etome/scribble_etome';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      "topPaddingHeight": topPaddingHeight,
      "imageName": imageName,
      "saveFolderPath": saveFolderPath,
      "drawingToolIndex": drawingTool.index,
      "penWidthValue": penWidthValue,
    };

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
