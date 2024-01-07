import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:scribble_etome/models.dart';
import 'package:scribble_etome/scribble_etome.dart';
import 'package:scribble_etome_example/booklet_page.dart';
import 'package:scribble_etome_example/models/image_model.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({
    super.key,
    this.index = 0,
    this.bytes,
    this.imageName,
  });
  final int index;
  final List<int>? bytes;
  final String? imageName;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: CanvasEtome(
              // bitMap: widget.bytes,
              imageName: widget.imageName ?? '',
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      CanvasEtomeOptions.undo();
                    },
                    child: const Text(
                      'Undo',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      CanvasEtomeOptions.redo();
                    },
                    child: const Text(
                      'Redo',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      CanvasEtomeOptions.clear();
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      CanvasEtomeOptions.setPenType();
                    },
                    child: const Text(
                      'Stroke',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final SaveResult saveResult =
                          await CanvasEtomeOptions.save();
                      await ImageBox.openBox();
                      final imageBox = ImageBox.box;
                      final imageList = imageBox.values.toList();
                      final intIndex = imageList.indexWhere(
                          (element) => element.index == widget.index);

                      if (intIndex == -1) {
                        await imageBox.add(ImageModel(
                            index: widget.index,
                            dateTime: saveResult.dateTimeNow,
                            byteList: saveResult.bitmap));
                      } else {
                        await imageBox.putAt(
                            intIndex,
                            ImageModel(
                                index: widget.index,
                                dateTime: saveResult.dateTimeNow,
                                byteList: saveResult.bitmap));
                      }

                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const BookletPage();
                        },
                      ));
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
