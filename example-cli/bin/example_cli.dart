import 'dart:io';

import 'package:jpegtran_ffi/jpegtran_ffi.dart';

void main(List<String> args) async {
  for (var inputFilename in args) {
    var jpegBytes = await File(inputFilename).readAsBytes();
    var transformer = JpegTransformer(jpegBytes);

    for (var scale in [0.5, 0.25, 0.125]) {
      File recompressedFile = File(inputFilename
          .replaceFirst(".jpg", "." + scale.toString() + ".jpg")
          .replaceFirst(".jpeg", "." + scale.toString() + ".jpeg"));
      IOSink writer = recompressedFile.openWrite();
      transformer.recompressTo(
        writer,
        scale: scale,
        quality: 75,
        preserveEXIF: true,
      );
      writer.flush();
      print('Written ' + recompressedFile.path);
    }
  }
}
