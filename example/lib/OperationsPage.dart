import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:jpegtran_ffi/jpegtran_ffi.dart';
import 'package:jpegtran_ffi/JpegSegment.dart';

class OperationsPage extends StatefulWidget {
  @override
  _OperationsState createState() => _OperationsState();
}

class _OperationsState extends State<OperationsPage> {
  Uint8List _imageBytes;

  @override
  void initState() {
    super.initState();
    var asset = 'assets/New_born_Frisian_red_white_calf-320px.jpg';
    var initialImage = rootBundle.load(asset);

    initialImage.then((value) {
      setState(() {
        _imageBytes = value.buffer.asUint8List();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_imageBytes == null) {
      return CircularProgressIndicator();
    }

    var segments = JpegSegment.readHeaders(_imageBytes);
    segments.forEach((segment) => print("have segment $segment"));

    return Scaffold(
      appBar: AppBar(
        title: Text('Operations'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(child: Image.memory(_imageBytes)),
            Text("${_imageBytes.lengthInBytes} bytes"),
            Expanded(
                flex: 1,
                child: ListView(
                  shrinkWrap: true,
                  children: buildButtonBars(),
                )),
          ],
        ),
      ),
    );
  }

  List<Widget> buildButtonBars() {
    return [
      ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(
            child: Text("Crop to center"),
            onPressed: () => _cropToCenter(),
          ),
        ],
      ),
      ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(
            child: Text("Rotate 90"),
            onPressed: () => _rotate(90),
          ),
          TextButton(
            child: Text("Rotate 180"),
            onPressed: () => _rotate(180),
          ),
          TextButton(
            child: Text("Rotate 270"),
            onPressed: () => _rotate(270),
          ),
        ],
      ),
      ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(
            child: Text("H-flip"),
            onPressed: () => _hflip(),
          ),
          TextButton(
            child: Text("V-flip"),
            onPressed: () => _vflip(),
          ),
        ],
      ),
      ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(
            child: Text("Transpose"),
            onPressed: () => _transpose(),
          ),
          TextButton(
            child: Text("Transverse"),
            onPressed: () => _transverse(),
          ),
        ],
      ),
      ButtonBar(
        alignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton(
            child: Text("Recompress (q=75)"),
            onPressed: () => _recompress(quality: 75),
          ),
        ],
      ),
    ];
  }

  void _rotate(int angle) {
    transform(JpegRotation(angle: angle));
  }

  void _hflip() {
    transform(JpegHFlip());
  }

  void _vflip() {
    transform(JpegVFlip());
  }

  void _transpose() {
    transform(JpegTranspose());
  }

  void _transverse() {
    transform(JpegTransverse());
  }

  void _cropToCenter() {
    var jpegtran = JpegTransformer(_imageBytes);
    try {
      var info = jpegtran.getInfo();
      print("transform input: ${info.width}x${info.height}");
      print("transform input: subsamp: ${info.subsampString}");
      print("transform input: ${_imageBytes.lengthInBytes} bytes");

      var crop = JpegCrop(
          alignIfRequired: true,
          x: info.width ~/ 4,
          y: info.height ~/ 4,
          w: info.width ~/ 2,
          h: info.height ~/ 2);
      var newImage = jpegtran.transform(crop);
      setState(() {
        _imageBytes = newImage;
      });
    } catch (err) {
      var scaffold = ScaffoldMessenger.of(context);
      scaffold.removeCurrentSnackBar();
      scaffold.showSnackBar(SnackBar(
        content: Text(err.toString()),
      ));
    } finally {
      jpegtran.dispose();
    }
  }

  void transform(JpegTransformation t) {
    var jpegtran = JpegTransformer(_imageBytes);
    try {
      var info = jpegtran.getInfo();
      print("transform input: ${info.width}x${info.height}, "
          "${_imageBytes.lengthInBytes} bytes");
      var newImage = jpegtran.transform(t);
      setState(() {
        _imageBytes = newImage;
      });
    } finally {
      jpegtran.dispose();
    }
  }

  void _recompress({int quality, bool keepEXIF = true}) {
    var jpegtran = JpegTransformer(_imageBytes);
    try {
      var info = jpegtran.getInfo();
      print("recompress input: ${info.width}x${info.height}, "
          "${_imageBytes.lengthInBytes} bytes");
      var newImage = jpegtran.recompress(quality: quality);

      if (keepEXIF) {
        // can also use an IOSink (File("abc").openWrite())
        var sink = BytesIOSink();

        JpegSegment.rewriteWithAlternateAppSegments(
            jpegToWrite: newImage,
            jpegWithAppSegmentsToUse: _imageBytes,
            writer: sink);

        newImage = sink.bytes.takeBytes();
        sink.close();
      }

      setState(() {
        _imageBytes = newImage;
      });
    } finally {
      jpegtran.dispose();
    }
  }
}

class BytesIOSink implements EventSink<List<int>> {
  final BytesBuilder bytes = BytesBuilder();

  @override
  void add(List<int> data) {
    bytes.add(data);
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    throw error;
  }

  @override
  void close() {}
}
