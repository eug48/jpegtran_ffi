import 'dart:async';
import 'dart:typed_data';

class JpegSegment {
  final ByteData data;
  final int type;

  bool get isApp => type >= 0xE0 && type <= 0xEF;
  bool get isStartOfScan => type == 0xDA;

  String get shortName {
    switch (type) {
      case 0xD8:
        return "SOI";
      case 0xC0:
        return "SOF0";
      case 0xC2:
        return "SOF2";
      case 0xC4:
        return "DHT";
      case 0xDB:
        return "DQT";
      case 0xDD:
        return "DRI";
      case 0xDA:
        return "SOS";
      case 0xFE:
        return "COM";
      case 0xD9:
        return "EOI";
    }

    if (type >= 0xD0 && type <= 0xD7) {
      return "RST${type - 0xD0}";
    }
    if (type >= 0xE0 && type <= 0xEF) {
      return "APP${type - 0xE0}";
    }

    return "0x" + type.toRadixString(16);
  }

  @override
  String toString() {
    return "JpegSegment ($shortName) - ${data.lengthInBytes} bytes";
  }

  JpegSegment(this.data) : type = data.getUint8(1);

  /// Reads segments prior to the entropy-coded data
  /// i.e. until the SOS (Start of Scan) segment
  static List<JpegSegment> readHeaders(Uint8List jpegBytes) {
    List<JpegSegment> segments = [];

    var jpeg = ByteData.sublistView(jpegBytes);
    int offset = 0;

    while (true) {
      if (jpeg.getUint8(offset) != 0xFF) {
        throw new Exception("Missing 0xFF at offset $offset");
      }
      int type = jpeg.getUint8(offset + 1);
      int segmentLength = 2; // for 0xFF + marker type

      bool noLengthBytes =
          // https://stackoverflow.com/a/4614629
          // https://dev.exiv2.org/projects/exiv2/wiki/The_Metadata_in_JPEG_files
          (type == 0x00 || type == 0x01 || (type >= 0xD0 && type <= 0xD8));

      if (!noLengthBytes) {
        segmentLength += jpeg.getUint16(offset + 2, Endian.big);
      }

      var segment = JpegSegment(ByteData.sublistView(
        jpeg,
        offset,
        offset + segmentLength,
      ));
      // print("read $segment");
      segments.add(segment);

      if (segment.isStartOfScan) {
        break;
      }
      offset += segmentLength;
    }

    return segments;
  }

  /// Writes out a JPEG but uses the APP segments from another JPEG
  /// Useful in preserving EXIF data
  static rewriteWithAlternateAppSegments({
    required Uint8List jpegToWrite,
    required Uint8List jpegWithAppSegmentsToUse,
    required EventSink<List<int>> writer,
  }) {
    var segments = readHeaders(jpegToWrite);
    var appSegments =
        readHeaders(jpegWithAppSegmentsToUse).where((s) => s.isApp);

    void writeSegment(JpegSegment seg) {
      writer.add(seg.data.buffer
          .asUint8List(seg.data.offsetInBytes, seg.data.lengthInBytes));
    }

    for (var seg in segments) {
      if (seg.isApp) {
        // skip APP segments in source image
        continue;
      }
      if (seg.isStartOfScan) {
        // write the rest of the file
        writer.add(seg.data.buffer.asUint8List(seg.data.offsetInBytes));
        break;
      }

      writeSegment(seg);

      if (seg.shortName == "SOI") {
        // write APP segments after SOI,
        // as per the JFIF/EXIF standards
        appSegments.forEach(writeSegment);
      }
    }
  }
}
