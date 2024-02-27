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
    this.imageName,
  });
  final int index;
  final List<int>? bytes;
  final String? imageName;

  @override
  State<CanvasPage> createState() => _CanvasPageState();
}

class _CanvasPageState extends State<CanvasPage> {
  List<int>? currentBitmap;
  bool isOverlay = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: CanvasEtome(
              // bitMap: widget.bytes,
              imageName: widget.imageName ?? '',
              saveFolder: 'EtomeRocks',
              // topPaddingHeight: 150,
              drawingTool: DrawingTool.pencil,
              penWidthValue: 10,
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
                      if (currentBitmap != null) {
                        CanvasController.loadBitmapFromByteArray(
                            Uint8List.fromList(currentBitmap!));
                      } else {
                        print('currentBitmap is empty');
                      }
                    },
                    child: const Text(
                      'Load',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      CanvasController.undo();
                    },
                    child: const Text(
                      'Undo',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      CanvasController.redo();
                    },
                    child: const Text(
                      'Redo',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      CanvasController.clear();
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // final bitmap = await CanvasController.getBitmap();
                      // setState(() {
                      //   currentBitmap = bitmap;
                      // });
                      CanvasController.isOverlay(isOverlay);
                      setState(() {
                        isOverlay = !isOverlay;
                      });
                    },
                    child: const Text(
                      'Overlay',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // final directoryPath = await getExternalStorageDirectory();
                      final SaveResult saveResult =
                          await CanvasController.save('wow');
                      // // final isSaved = await saveToFile(
                      // //     saveResult.bitmap, saveResult.dateTimeNow);

                      // final isSaved = await FileStorage.writeCounter(
                      //     saveResult.bitmap, "geeksforgeeks.png");

                      // dio.post('http://192.168.1.51:8000/api/scribble',
                      //     data: map);

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
                      if (!mounted) return;
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

// Future<bool> saveToFile(List<int> byteArray, String imageName) async {
//   try {
//     final directory = Directory('/storage/emulated/0/Download/');
//     await directory.create(recursive: true);
//     final filePath = '${directory.path}$imageName.txt';
//     final file = File(filePath);
//     await file.writeAsBytes(byteArray);
//     // await file.writeAsString("byteArray");
//     return true;
//   } catch (e) {
//     print('Error saving bytes: $e');
//     return false; // Failed to save image
//   }
// }

// // To save the file in the device
// class FileStorage {
//   static Future<String> getExternalDocumentPath() async {
//     // To check whether permission is given for this app or not.
//     var status = await Permission.storage.status;
//     if (!status.isGranted) {
//       // If not we will ask for permission first
//       await Permission.storage.request();
//     }
//     Directory directory = Directory("");
//     if (Platform.isAndroid) {
//       // Redirects it to download folder in android
//       directory = Directory("/storage/emulated/0/Documents/Etome");
//     } else {
//       directory = await getApplicationDocumentsDirectory();
//     }

//     final exPath = directory.path;
//     print("Saved Path: $exPath");
//     await Directory(exPath).create(recursive: true);
//     return exPath;
//   }

//   static Future<String> get _localPath async {
//     // final directory = await getApplicationDocumentsDirectory();
//     // return directory.path;
//     // To get the external path from device of download folder
//     final String directory = await getExternalDocumentPath();
//     return directory;
//   }

//   static Future<bool> writeCounter(List<int> bytes, String name) async {
//     try {
//       final path = await _localPath;
//       // Create a file for the path of
//       // device and file name with extension
//       File file = File('$path/$name');
//       print("Save file");

//       // Write the data in the file you have created
//       await file.writeAsBytes(bytes);
//       return true; // File successfully written
//     } catch (e) {
//       print('Error saving file: $e');
//       return false; // Failed to save file
//     }
//   }
// }


