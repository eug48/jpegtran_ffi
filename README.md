# jpegtran_ffi

Mostly lossless transformations for JPEG images, implemented using libjpeg-turbo via Dart's FFI.

## Example

```dart
void _cropToSquare() {
    var jpegtran = JpegTransformer(_imageBytes);
    try {
        var info = jpegtran.getInfo();

        JpegCrop crop;
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
```


## TODO

* Remove unneeded parts of libjpeg-turbo