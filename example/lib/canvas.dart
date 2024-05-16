import 'dart:async';

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
  void initState() {
    startPrintingTimer(
        duration: const Duration(seconds: 5),
        interval: const Duration(milliseconds: 50));
    super.initState();
  }

  void startPrintingTimer(
      {required Duration duration, required Duration interval}) {
    int count = 0;

    Timer.periodic(interval, (Timer timer) async {
      // Print something every interval
      print(await CanvasController.isInEditMode());

      // Increment count
      count++;

      // Check if the specified duration has passed
      if (count * interval.inMilliseconds >= duration.inMilliseconds) {
        // Cancel the timer after the specified duration
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              penWidthValue: 10, leftPadding: 50, rightPadding: 50,
            ),
          ),
          if (!isOverlay)
            Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  width: size.width * 0.5,
                  height: size.height * 0.5,
                )),
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
                      // if (currentBitmap != null) {
                      //   CanvasController.loadBitmapFromByteArray(
                      //       Uint8List.fromList(currentBitmap!));
                      // } else {
                      //   print('currentBitmap is empty');
                      // }

                      CanvasController.load('1');
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
                      // CanvasController.clear();
                      CanvasController.refreshDrawableState();
                      print('isOverlay before setState $isOverlay');
                      setState(() {
                        isOverlay = !isOverlay;
                      });
                      print('isOverlay after setState $isOverlay');
                      CanvasController.isOverlay(isOverlay);
                    },
                    child: const Text(
                      'Hover',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // final bitmap = await CanvasController.getBitmap();
                      // setState(() {
                      //   currentBitmap = bitmap;
                      // });
                      CanvasController.refreshBitmap();
                      // CanvasController.load('5');
                    },
                    child: const Text(
                      'Refresh',
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


