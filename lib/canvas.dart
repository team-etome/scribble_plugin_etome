import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CanvasEtome extends StatelessWidget {
  const CanvasEtome({super.key, this.appBarHeight = 30, this.bitMap});

  final int appBarHeight;
  final List<int>? bitMap;

  @override
  Widget build(BuildContext context) {
    const String viewType = 'leywin/etome/scribble_etome';
    final Map<String, dynamic> creationParams = <String, dynamic>{
      'appBarHeight': appBarHeight,
    };

    if (bitMap != null) {
      creationParams.addAll({
        'bitMap': bitMap,
      });
    }

    return AndroidView(
      viewType: viewType,
      layoutDirection: TextDirection.ltr,
      creationParams: creationParams,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
