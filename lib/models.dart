///A class that contains the save result, it has bitmap, dateTime and directoryPath
class SaveResult {
  final List<int> bitmap;
  final String dateTimeNow;
  final String directoryPath;

  SaveResult({
    required this.bitmap,
    required this.dateTimeNow,
    required this.directoryPath,
  });
}
