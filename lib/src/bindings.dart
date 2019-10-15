import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart' as ffi_utils;

// Helpful docs/samples:
//
//   http://gensoft.pasteur.fr/docs/libjpeg-turbo/1.5.1/group___turbo_j_p_e_g.html
//
//   https://github.com/jbaiter/jpegtran-cffi/tree/master/jpegtran

class TJHandle extends Struct<TJHandle> {}

class TJTransform extends Struct<TJTransform> {
  @Int32()
  int x;

  @Int32()
  int y;

  @Int32()
  int w;

  @Int32()
  int h;

  @Int32()
  int op;

  @Int32()
  int options;

  Pointer<Void> data;

  Pointer<Void> pCustomFilter;

  void init() {
    x = 0;
    y = 0;
    w = 0;
    h = 0;
    op = 0;
    options = 0;
    data = nullptr;
    pCustomFilter = nullptr;
  }
}

/// Transform operations for tjTransform()
enum TJXOP {
  /// Do not transform the position of the image pixels
  NONE,

  /// Flip (mirror) image horizontally.  This transform is imperfect if there
  /// are any partial MCU blocks on the right edge (see #TJXOPT_PERFECT.)
  HFLIP,

  /// Flip (mirror) image vertically.  This transform is imperfect if there are
  /// any partial MCU blocks on the bottom edge (see #TJXOPT_PERFECT.)
  VFLIP,

  /// Transpose image (flip/mirror along upper left to lower right axis.)  This
  /// transform is always perfect.
  TRANSPOSE,

  /// Transverse transpose image (flip/mirror along upper right to lower left
  /// axis.)  This transform is imperfect if there are any partial MCU blocks in
  /// the image (see #TJXOPT_PERFECT.)
  TRANSVERSE,

  /// Rotate image clockwise by 90 degrees.  This transform is imperfect if
  /// there are any partial MCU blocks on the bottom edge (see
  /// #TJXOPT_PERFECT.)
  ROT90,

  /// Rotate image 180 degrees.  This transform is imperfect if there are any
  /// partial MCU blocks in the image (see #TJXOPT_PERFECT.)
  ROT180,

  /// Rotate image counter-clockwise by 90 degrees.  This transform is imperfect
  /// if there are any partial MCU blocks on the right edge (see
  /// #TJXOPT_PERFECT.)
  ROT270
}

const TJXOPT_PERFECT = 1;
const TJXOPT_TRIM = 2;
const TJXOPT_CROP = 4;
const TJXOPT_GRAY = 8;
const TJXOPT_PROGRESSIVE = 32;

// tjhandle tjInitTransform(void);
typedef tjInitTransform_C = Pointer<TJHandle> Function();
typedef tjInitTransform_Dart = Pointer<TJHandle> Function();

// int tjDestroy(tjhandle handle);
typedef tjDestroy_C = Uint32 Function(Pointer<TJHandle> handle);
typedef tjDestroy_Dart = int Function(Pointer<TJHandle> handle);

// void tjFree(unsigned char *buffer);
typedef tjFree_C = Void Function(Pointer<Uint8>);
typedef tjFree_Dart = void Function(Pointer<Uint8>);

// char* tjGetErrorStr(void);
typedef tjGetErrorStr_C = Pointer<ffi_utils.Utf8> Function();
typedef tjGetErrorStr_Dart = Pointer<ffi_utils.Utf8> Function();

/*
int tjTransform(
  tjhandle handle,
  unsigned char *jpegBuf,
  unsigned long jpegSize,
  int n,
  unsigned char **dstBufs,
  unsigned long *dstSizes,
  tjtransform *transforms,
  int flags);
*/
typedef tjTransform_C = Int32 Function(
    Pointer<TJHandle> handle,
    Pointer<Uint8> jpegBuf,
    IntPtr jpegSize,
    Uint32 n,
    Pointer<Pointer<Uint8>> dstBufs,
    Pointer<IntPtr> dstSizes,
    Pointer<TJTransform> transforms,
    Uint32 flags);
typedef tjTransform_Dart = int Function(
    Pointer<TJHandle> handle,
    Pointer<Uint8> jpegBuf,
    int jpegSize,
    int n,
    Pointer<Pointer<Uint8>> dstBufs,
    Pointer<IntPtr> dstSizes,
    Pointer<TJTransform> transforms,
    int flags);

/*
int tjDecompressHeader3(
  tjhandle handle,
  unsigned char *jpegBuf,
  unsigned long jpegSize,
  int *width,
  int *height,
  int *jpegSubsamp,
  int *jpegColorspace);
*/
typedef tjDecompressHeader3_C = Int32 Function(
    Pointer<TJHandle> handle,
    Pointer<Uint8> jpegBuf,
    IntPtr jpegSize,
    Pointer<Uint32> width,
    Pointer<Uint32> height,
    Pointer<Uint32> jpegSubsamp,
    Pointer<Uint32> jpegColorspace);

typedef tjDecompressHeader3_Dart = int Function(
    Pointer<TJHandle> handle,
    Pointer<Uint8> jpegBuf,
    int jpegSize,
    Pointer<Uint32> width,
    Pointer<Uint32> height,
    Pointer<Uint32> jpegSubsamp,
    Pointer<Uint32> jpegColorspace);

class JpegTranBindings {
  tjInitTransform_Dart tjInitTransform;
  tjDestroy_Dart tjDestroy;
  tjDecompressHeader3_Dart tjDecompressHeader3;
  tjTransform_Dart tjTransform;
  tjFree_Dart tjFree;
  tjGetErrorStr_Dart tjGetErrorStr;

  JpegTranBindings() {
    final DynamicLibrary lib = (Platform.isAndroid || Platform.isLinux)
        ? DynamicLibrary.open("libturbojpeg.so")
        // TODO: support iOS
        : throw Exception("jpegtran_ffi: ${Platform.operatingSystem} not yet supported");

    tjInitTransform =
        lib.lookupFunction<tjInitTransform_C, tjInitTransform_Dart>("tjInitTransform");

    tjDestroy = lib.lookupFunction<tjDestroy_C, tjDestroy_Dart>("tjDestroy");

    tjDecompressHeader3 =
        lib.lookupFunction<tjDecompressHeader3_C, tjDecompressHeader3_Dart>("tjDecompressHeader3");

    tjTransform = lib.lookupFunction<tjTransform_C, tjTransform_Dart>("tjTransform");

    tjFree = lib.lookupFunction<tjFree_C, tjFree_Dart>("tjFree");

    tjGetErrorStr = lib.lookupFunction<tjGetErrorStr_C, tjGetErrorStr_Dart>("tjGetErrorStr");
  }
}
