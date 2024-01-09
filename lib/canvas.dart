import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CanvasEtome extends StatelessWidget {
  const CanvasEtome({super.key, this.topPaddingHeight = 30, this.imageName = ''});

  final int topPaddingHeight;
  final String imageName;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'leywin/etome/scribble_etome';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      "topPaddingHeight": topPaddingHeight ,
      "imageName": imageName,
    };

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
