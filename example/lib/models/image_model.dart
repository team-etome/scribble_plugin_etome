import 'dart:typed_data';

import 'package:hive_flutter/adapters.dart';
part 'image_model.g.dart';

@HiveType(typeId: 0)
class ImageModel {
  @HiveField(0)
  final int index;
  @HiveField(1)
  final String dateTime;
  @HiveField(2)
  final List<int> byteList;

  ImageModel({
    required this.index,
    required this.dateTime,
    required this.byteList,
  });
}

class ImageBox {
  static late Box<ImageModel> _box;

  static Future<void> openBox() async {
    _box = await Hive.openBox<ImageModel>('imageBox');
  }

  static Box<ImageModel> get box => _box;

  Future<void> closeBox() async {
    await _box.close();
  }
}
