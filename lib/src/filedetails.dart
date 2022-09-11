import 'dart:io';

class FileDetails {
  final String fieldName;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String tmpName;

  FileDetails(
      {required this.fieldName,
      required this.fileName,
      required this.fileSize,
      required this.fileType,
      required this.tmpName});

  Future<bool> moveFile({String? newroute, String? newname}) async {
    String movepath;
    if (newroute == null) {
      movepath = "./";
    } else {
      movepath = "$newroute";
    }
    if (newname == null) {
      movepath += "/$fileName";
    } else {
      movepath += "/$newname";
    }
    await File('./tmp/files/$tmpName').rename('./$movepath');
    return true;
  }

  void string() {
    print(fileName);
  }
}
