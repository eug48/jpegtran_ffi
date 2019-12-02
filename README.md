# jpegtran_ffi

Mostly lossless transformations for JPEG images, implemented using libjpeg-turbo via Dart's FFI.

## Example

```dart
void _cropToSquareRotate() {
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


## TODO

* Remove unneeded parts of libjpeg-turbo