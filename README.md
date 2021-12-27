# jpegtran_ffi

Lossless transformations of JPEG images, similar to those than can be made using `jpegtran` tool, e.g. cropping and rotations. Since JPEG data doesn't need to be decoded or encoded it should hopefully be fast as well.

A lossy recompress method to reduce quality & size is also included.

This package uses [libjpeg-turbo](https://libjpeg-turbo.org/) via Dart's FFI. Unlike platform plugins it should be usable from within isolates.

## Example

```dart
void _cropToSquareAndRotate() {
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
* Lossy resizing