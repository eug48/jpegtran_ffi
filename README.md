# jpegtran_ffi

Mostly lossless transformations of JPEG images, similar to those than can be made using `jpegtran` tool, e.g. cropping and rotations. Since JPEG data doesn't need to be decoded or encoded it should hopefully be fast as well.

A lossy recompress method to reduce quality & optionally resize has also been added. Resizing is done by libjpeg-turbo during decompression so it should be fast, but a limited set of scaling factors are supported (including 1/2, 1/4, 1/8). EXIF data can be copied from the original image.

This package uses [libjpeg-turbo](https://libjpeg-turbo.org/) via Dart's FFI. Unlike platform plugins it should be usable from within isolates.

## Example

```dart
void cropToSquareAndRotate() {
    var jpegtran = JpegTransformer(_imageBytes);
    try {
        var info = jpegtran.getInfo();

        var cropSize = min(info.width, info.height);
        var crop = JpegCrop(
            w: cropSize,
            h: cropSize,
            x: (info.width - cropSize) ~/ 2,
            y: (info.height - cropSize) ~/ 2,
            alignIfRequired: true,
        );

        var rotate = JpegRotation(
            angle: 90,
            crop: crop,
            options: JpegOptions(grayscale: false),
        );

        var newImage = jpegtran.transform(rotate);
        setState(() {
            _imageBytes = newImage;
        });
    } catch (err) {
        _showError(err, context);
    } finally {
        jpegtran.dispose();
    }
}
```

```dart
Uint8List recompress(Uint8List jpegBytes) {
  var jpegtran = JpegTransformer(jpegBytes);
  try {
    return jpegtran.recompress(
      scale: 0.25,
      quality: 70,
      preserveEXIF: true,
    );
  } finally {
    jpegtran.dispose();
  }
}
```

## TODO

* Remove unneeded parts of libjpeg-turbo