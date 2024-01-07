import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:scribble_etome/scribble_etome.dart';
import 'package:scribble_etome_example/booklet_page.dart';
import 'package:scribble_etome_example/models/image_model.dart';

class CanvasPage extends StatefulWidget {
  const CanvasPage({
    super.key,
    this.index = 0,
    this.bytes,
  });
  final int index;
  final List<int>? bytes;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          const Scaffold(
            body: CanvasEtome(
                // bitMap: widget.bytes,
                ),
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: TextButton(
              onPressed: () {
                CanvasEtomeOptions.clear();
              },
              child: const Text('clear'),
            ),
          ),
         
          Positioned(
            bottom: 50,
            right: 0,
            left: 0,
            child: TextButton(
              onPressed: () {
                if (widget.bytes != null) {
                  CanvasEtomeOptions.load(widget.bytes!);
                }
              },
              child: const Text('load'),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 50,
            child: TextButton(
              onPressed: () async {
                final List<int> bytes = await CanvasEtomeOptions.save();
                await ImageBox.openBox();
                final imageBox = ImageBox.box;
                final imageList = imageBox.values.toList();
                final intIndex = imageList
                    .indexWhere((element) => element.index == widget.index);

                if (intIndex == -1) {
                  await imageBox.add(ImageModel(
                      index: widget.index,
                      dateTime: DateTime.now().toString(),
                      byteList: bytes));
                } else {
                  await imageBox.putAt(
                      intIndex,
                      ImageModel(
                          index: widget.index,
                          dateTime: DateTime.now().toString(),
                          byteList: bytes));
                }

                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const BookletPage();
                  },
                ));
              },
              child: const Text('save'),
            ),
          ),
        ],
      ),
    );
  }
}
