import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:jpegtran_ffi/jpegtran_ffi.dart';
import 'package:image_picker/image_picker.dart';

class CropSquarePage extends StatefulWidget {
  @override
  _CropSquareState createState() => _CropSquareState();
}

class _CropSquareState extends State<CropSquarePage> {
  Uint8List? _imageBytes;

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

    return Scaffold(
      appBar: AppBar(
        title: Text('Crop to square'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Expanded(child: Image.memory(_imageBytes!)),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  child: Text("Crop to square"),
                  onPressed: () => _cropToSquare(),
                ),
              ],
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  child: Text("Pick from camera"),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
                TextButton(
                  child: Text("Pick from gallery"),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) async {
    XFile? file;
    try {
      file = await ImagePicker().pickImage(source: source);
      if (file == null) {
        return;
      }

      var imageBytes = await file.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
    } catch (err) {
      _showError(err, context);
    } finally {
      var path = file?.path;
      if (path != null) {
        File(path).deleteSync();
      }
    }
  }

  void _cropToSquare() {
    var jpegtran = JpegTransformer(_imageBytes!);
    try {
      var info = jpegtran.getInfo();
      print("transform input: ${info.width}x${info.height}, "
          "subsamp: ${info.subsampString}, "
          "${_imageBytes!.lengthInBytes} bytes");

      JpegCrop? crop;
      if (info.width > info.height) {
        crop = JpegCrop(
            x: (info.width - info.height) ~/ 2,
            y: 0,
            w: info.height,
            h: info.height,
            alignIfRequired: true);
      }
      if (info.height > info.width) {
        crop = JpegCrop(
            x: 0,
            y: (info.height - info.width) ~/ 2,
            w: info.width,
            h: info.width,
            alignIfRequired: true);
      }

      if (crop != null) {
        var newImage = jpegtran.transform(crop);
        setState(() {
          _imageBytes = newImage;
        });
      }
    } catch (err) {
      _showError(err, context);
    } finally {
      jpegtran.dispose();
    }
  }

  void _showError(Object err, BuildContext context) {
    var scaffold = ScaffoldMessenger.of(context);
    scaffold.removeCurrentSnackBar();
    scaffold.showSnackBar(SnackBar(
      content: Text(err.toString()),
    ));
  }
}
