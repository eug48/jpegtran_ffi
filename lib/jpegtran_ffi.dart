import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:jpegtran_ffi/src/bindings.dart';

/// Information from a JPEG's header
class JpegInfo {
  final int width;
  final int height;
  final int subsamp;
  final int colorspace;
  JpegInfo(this.width, this.height, this.subsamp, this.colorspace);

  /// For cropping 'x' must be a multiple of this
  int get mcuWidth {
    // from turbojpeg.h:
    // static const int tjMCUWidth[TJ_NUMSAMP]  = { 8, 16, 16, 8, 8, 32 };
    const List<int> tjMCUWidth = [8, 16, 16, 8, 8, 32];
    return tjMCUWidth[subsamp];
  }

  /// For cropping 'y' must be a multiple of this
  int get mcuHeight {
    // from turbojpeg.h:
    // static const int tjMCUHeight[TJ_NUMSAMP] = { 8, 8, 16, 8, 16, 8 };
    const List<int> tjMCUHeight = [8, 8, 16, 8, 16, 8];
    return tjMCUHeight[subsamp];
  }

  String get subsampString {
    const List<String> subsampStrings = [
      "4:4:4",
      "4:2:2",
      "4:2:0",
      "grayscale",
      "4:4:0",
      "4:1:1",
    ];
    return subsampStrings[subsamp];
  }
}

abstract class JpegTransformation {
  Pointer<TJTransform> _getTransform(JpegTransformer transformer);
}

class JpegOptions {
  /// Some transformations cannot be done losslessly if they lead to partial MCU blocks having to be moved.
  /// This option discards these partial blocks.
  /// (sets TJXOPT_TRIM)
  final bool trimIfLossy;

  /// Some transformations cannot be done losslessly if they lead to partial MCU blocks having to be moved.
  /// This option throws an error in such a situation.
  /// (sets TJXOPT_PERFECT)
  final bool failIfLossy;

  /// Convert to grayscale by simply discarding colour data
  /// (sets TJXOPT_GRAY)
  final bool grayscale;

  const JpegOptions({this.trimIfLossy = true, this.failIfLossy = false, this.grayscale = false});

  void _applyToTransform(TJTransform tf) {
    if (trimIfLossy && failIfLossy) {
      throw Exception("JpegOptions: invalid to enable both trimIfLossy and failIfLossy");
    }

    if (trimIfLossy) {
      tf.options = tf.options | TJXOPT_TRIM;
    }
    if (failIfLossy) {
      tf.options = tf.options | TJXOPT_PERFECT;
    }
    if (grayscale) {
      tf.options = tf.options | TJXOPT_GRAY;
    }
  }
}

Pointer<TJTransform> _allocateTransform(TJXOP op, JpegCrop crop, JpegOptions options, JpegTransformer transformer) {
  final p = allocate<TJTransform>();
  final tf = p.ref;
  tf.init();
  tf.op = op.index;
  if (crop != null) {
    crop._applyToTransform(tf, transformer);
  }
  options._applyToTransform(tf);
  return p;
}

/// Lossless cropping of a JPEG
class JpegCrop implements JpegTransformation {
  final int x;
  final int y;
  final int w;
  final int h;

  /// Whether (x, y) is automatically aligned to the JPEG's Minimum Coded Unit (MCU)
  ///
  /// If turned off and not aligned there will be an error
  final bool alignIfRequired;

  final JpegOptions options;

  JpegCrop({@required this.x, @required this.y, @required this.w, @required this.h, this.alignIfRequired = true, this.options = const JpegOptions()});

  @override
  Pointer<TJTransform> _getTransform(JpegTransformer transformer) {
    return _allocateTransform(TJXOP.NONE, this, options, transformer);
  }

  void _applyToTransform(TJTransform tf, JpegTransformer transformer) {
    tf
      ..x = x
      ..y = y
      ..w = w
      ..h = h
      ..options = tf.options | TJXOPT_CROP;

    if (alignIfRequired) {
      var info = transformer.getInfo();
      var dx = x % info.mcuWidth;
      var dy = y % info.mcuHeight;
      tf.x -= dx;
      tf.y -= dy;
    }
  }
}

/// JPEG Rotation
///
/// Behaviour for 'imperfect' scenarios is governed by options (image trimmed by default)
///
/// 90 degrees - transform is imperfect if there are any partial MCU blocks on the bottom edge
/// 180 degrees - transform is imperfect if there are any partial MCU blocks in the image
/// 270 degrees -  transform is imperfect if there are any partial MCU blocks on the right edge
class JpegRotation implements JpegTransformation {
  final JpegCrop crop;
  final JpegOptions options;
  final int angle;
  TJXOP _op;

  JpegRotation({@required this.angle, this.crop, this.options = const JpegOptions()}) {
    switch (this.angle) {
      case 90:
        _op = TJXOP.ROT90;
        break;
      case 180:
        _op = TJXOP.ROT180;
        break;
      case 270:
        _op = TJXOP.ROT270;
        break;
      default:
        throw Exception("JpegRotation: invalid angle");
    }
  }

  @override
  Pointer<TJTransform> _getTransform(JpegTransformer transformer) {
    return _allocateTransform(_op, crop, options, transformer);
  }
}

/// Horizontal Flip
///
/// Transform is imperfect if there are any partial MCU blocks on the right edge
/// Behaviour in this case is governed by options (image trimmed by default)
class JpegHFlip implements JpegTransformation {
  final JpegCrop crop;
  final JpegOptions options;

  JpegHFlip({this.crop, this.options = const JpegOptions()});

  @override
  Pointer<TJTransform> _getTransform(JpegTransformer transformer) {
    return _allocateTransform(TJXOP.HFLIP, crop, options, transformer);
  }
}

/// Vertical Flip
///
/// Transform is imperfect if there are any partial MCU blocks on the bottom edge
/// Behaviour in this case is governed by options (image trimmed by default)
class JpegVFlip implements JpegTransformation {
  final JpegCrop crop;
  final JpegOptions options;

  JpegVFlip({this.crop, this.options = const JpegOptions()});

  @override
  Pointer<TJTransform> _getTransform(JpegTransformer transformer) {
    return _allocateTransform(TJXOP.VFLIP, crop, options, transformer);
  }
}

/// Transpose image (flip/mirror along upper left to lower right axis.)
///
/// This transform is always perfect.
class JpegTranspose implements JpegTransformation {
  final JpegCrop crop;
  final JpegOptions options;

  JpegTranspose({this.crop, this.options = const JpegOptions()});

  @override
  Pointer<TJTransform> _getTransform(JpegTransformer transformer) {
    return _allocateTransform(TJXOP.TRANSPOSE, crop, options, transformer);
  }
}

/// Transverse transpose image (flip/mirror along upper right to lower left axis.)
///
/// This transform is imperfect if there are any partial MCU blocks in the image
/// Behaviour in this case is governed by options (image trimmed by default)
class JpegTransverse implements JpegTransformation {
  final JpegCrop crop;
  final JpegOptions options;

  JpegTransverse({this.crop, this.options = const JpegOptions()});

  @override
  Pointer<TJTransform> _getTransform(JpegTransformer transformer) {
    return _allocateTransform(TJXOP.TRANSVERSE, crop, options, transformer);
  }
}

/// Mostly lossless transformations for JPEG images
///
/// Implemented via FFI to libjpeg-turbo's jpegtran API
/// Users need to call dispose to free memory
class JpegTransformer {
  static final JpegTranBindings _bindings = JpegTranBindings();
  Pointer<TJHandle> _handle;
  Pointer<Uint8> _jpegBuf;
  int _jpegSize;

  JpegTransformer(Uint8List jpegBytes) {
    _handle = _bindings.tjInitTransform();

    _jpegBuf = allocate<Uint8>(count: jpegBytes.length);
    _jpegSize = jpegBytes.length;

    // TODO: can this copying be avoided?
    Uint8List jpegBufDart = _jpegBuf.asTypedList(_jpegSize);
    for (var i = 0; i < jpegBytes.length; i++) {
      jpegBufDart[i] = jpegBytes[i];
    }
  }

  void dispose() {
    free(_jpegBuf);

    int res = _bindings.tjDestroy(_handle);
    if (res != 0) {
      throw Exception("tjDestroy failed");
    }
  }

  String _getLastError() {
    var buf = _bindings.tjGetErrorStr();
    return Utf8.fromUtf8(buf);
  }

  /// Basic information from the JPEG header
  JpegInfo getInfo() {
    // TODO: put into a single allocation
    final pWidth = allocate<Uint32>();
    final pHeight = allocate<Uint32>();
    final pSubsamp = allocate<Uint32>();
    final pColorspace = allocate<Uint32>();

    // TODO: can try to do this in Dart for possibly better peformance
    int res = _bindings.tjDecompressHeader3(_handle, _jpegBuf, _jpegSize, pWidth, pHeight, pSubsamp, pColorspace);

    if (res != 0) {
      throw Exception("tjDecompressHeader3 failed: " + _getLastError());
    }

    var info = JpegInfo(pWidth.value, pHeight.value, pSubsamp.value, pColorspace.value);

    free(pWidth);
    free(pHeight);
    free(pSubsamp);
    free(pColorspace);

    return info;
  }

  Uint8List transform(JpegTransformation transformation) {
    var tf = transformation._getTransform(this);

    final pDstBufs = allocate<Pointer<Uint8>>(count: 1);
    final pDstSizes = allocate<IntPtr>(count: 1);

    pDstBufs.value = Pointer<Uint8>.fromAddress(0);

    int res = _bindings.tjTransform(_handle, _jpegBuf, _jpegSize, 1, pDstBufs, pDstSizes, tf, 0);

    Pointer<Uint8> dstBuf = pDstBufs.value;
    int resultSize = pDstSizes.value;

    free(tf);
    free(pDstBufs);
    free(pDstSizes);

    if (res != 0) {
      throw Exception("JpegTransformer failed: " + _getLastError());
    }

    Uint8List dstBufDart = dstBuf.asTypedList(resultSize);
    Uint8List outBytes = Uint8List.fromList(dstBufDart);
    _bindings.tjFree(dstBuf);

    return outBytes;
  }
}
