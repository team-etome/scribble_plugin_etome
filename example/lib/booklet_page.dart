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
  String permissionStatus = 'false';

  @override
  void initState() {
    // requestStoragePermission();
    loadImages();
    super.initState();
  }

  // Future<void> requestStoragePermission() async {
  //   var status = await Permission.storage.status;
  //   if (!status.isGranted) {
  //     await Permission.storage.request();
  //   } else {
  //     setState(() {
  //       permissionStatus = 'true';
  //     });
  //   }
  // }

  loadImages() async {
    await ImageBox.openBox();
    setState(() {
      imageList = ImageBox.box.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CanvasPage(
                      imageName: '',
                      index: imageList.length,
                    ),
                  ));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: imageList.isNotEmpty
          ? GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
                childAspectRatio: 1.0,
              ),
              itemCount: imageList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CanvasPage(
                            index: index,
                            bytes: imageList[index].byteList,
                            imageName: imageList[index].dateTime,
                          ),
                        ));
                  },
                  child: GridTile(
                    footer: Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.black54,
                      child: Text(
                        imageList[index].dateTime,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    child: Image.memory(
                      Uint8List.fromList(imageList[index].byteList),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Text('Add scribble $permissionStatus'),
            ),
    );
  }
}
