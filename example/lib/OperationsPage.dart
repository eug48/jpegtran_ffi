import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:jpegtran_ffi/jpegtran_ffi.dart';

class OperationsPage extends StatefulWidget {
  @override
  _OperationsState createState() => _OperationsState();
}

class _OperationsState extends State<OperationsPage> {
  Uint8List _imageBytes;

  @override
  void initState() {
    super.initState();

    var initialImage = rootBundle.load('assets/New_born_Frisian_red_white_calf-320px.jpg');
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Operations'),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 10),
            Expanded(child: Image.memory(_imageBytes)),
            Expanded(
                flex: 2,
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
      print("transform input: ${info.width}x${info.height}   ${_imageBytes.lengthInBytes} bytes");
      var newImage = jpegtran.transform(t);
      setState(() {
        _imageBytes = newImage;
      });
    } finally {
      jpegtran.dispose();
    }
  }
}
