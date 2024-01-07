import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:scribble_etome_example/canvas.dart';
import 'package:scribble_etome_example/models/image_model.dart';

class BookletPage extends StatefulWidget {
  const BookletPage({super.key});

  @override
  State<BookletPage> createState() => _BookletPageState();
}

class _BookletPageState extends State<BookletPage> {
  List<ImageModel> imageList = [];
  int pageIndex = 0;

  @override
  void initState() {
    loadImages();
    super.initState();
  }

  loadImages() async {
    await ImageBox.openBox();
    setState(() {
      imageList = ImageBox.box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageList.isNotEmpty) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return CanvasPage(
                          index: imageList.length,
                        );
                      },
                    ));
                  },
                  icon: const Icon(Icons.add))
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: List.generate(
                  imageList.length,
                  (index) => ListTile(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return CanvasPage(
                                  index: index, bytes: imageList[index].byteList);
                            },
                          ));
                        },
                        leading: SizedBox(
                            height: 200,
                            width: 200,
                            child: Image.memory(Uint8List.fromList(imageList[index].byteList))),
                        trailing: Text(imageList[index].dateTime),
                      )),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const CanvasPage();
                    },
                  ));
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
