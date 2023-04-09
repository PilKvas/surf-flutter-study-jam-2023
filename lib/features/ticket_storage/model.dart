// import 'package:hive_flutter/hive_flutter.dart';

// class PdfFile {
//   String fileName = '';
//   bool isDownload = false;
//   final String newUrl;
//   PdfFile(
//       {required this.newUrl, required this.fileName, required this.isDownload});
// }

// class HiveNewFile extends TypeAdapter<PdfFile> {
//   @override
//   final typeId = 1;

//   @override
//   PdfFile read(BinaryReader reader) {
//     String fileName = reader.readString();
//     bool isdownload = reader.readBool();
//     final String newUrl = reader.readString();
//     return PdfFile(newUrl: newUrl, fileName: fileName, isDownload: isdownload);
//   }

//   @override
//   void write(BinaryWriter writer, PdfFile obj) {
//     writer.writeString(obj.fileName);
//     writer.writeBool(obj.isDownload);
//     writer.writeString(obj.newUrl);
//   }
// }


class PdfFile {
  String url;
  String filename;
  double progress = 0.0;
  bool downloading = false;

  PdfFile(this.url, this.filename);
}
