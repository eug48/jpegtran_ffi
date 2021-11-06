import 'dart:io';
import 'dart:ffi';
import 'package:ffi/ffi.dart' as ffi_utils;

// Helpful docs/samples:
//
//   http://gensoft.pasteur.fr/docs/libjpeg-turbo/1.5.1/group___turbo_j_p_e_g.html
//
//   https://github.com/jbaiter/jpegtran-cffi/tree/master/jpegtran

class TJHandle extends Opaque {}

class TJTransform extends Struct {
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
typedef TJInitTransformC = Pointer<TJHandle> Function();
typedef TJInitTransformDart = Pointer<TJHandle> Function();

// int tjDestroy(tjhandle handle);
typedef TJDestroyC = Uint32 Function(Pointer<TJHandle> handle);
typedef TJDestroyDart = int Function(Pointer<TJHandle> handle);

// void tjFree(unsigned char *buffer);
typedef TJFreeC = Void Function(Pointer<Uint8>);
typedef TJFreeDart = void Function(Pointer<Uint8>);

// char* tjGetErrorStr(void);
typedef TJGetErrorStrC = Pointer<ffi_utils.Utf8> Function();
typedef TJGetErrorStrDart = Pointer<ffi_utils.Utf8> Function();

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
typedef TJTransformC = Int32 Function(
    Pointer<TJHandle> handle, Pointer<Uint8> jpegBuf, IntPtr jpegSize, Uint32 n, Pointer<Pointer<Uint8>> dstBufs, Pointer<IntPtr> dstSizes, Pointer<TJTransform> transforms, Uint32 flags);
typedef TJTransformDart = int Function(
    Pointer<TJHandle> handle, Pointer<Uint8> jpegBuf, int jpegSize, int n, Pointer<Pointer<Uint8>> dstBufs, Pointer<IntPtr> dstSizes, Pointer<TJTransform> transforms, int flags);

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
typedef TJDecompressHeader3C = Int32 Function(
    Pointer<TJHandle> handle, Pointer<Uint8> jpegBuf, IntPtr jpegSize, Pointer<Uint32> width, Pointer<Uint32> height, Pointer<Uint32> jpegSubsamp, Pointer<Uint32> jpegColorspace);

typedef TJDecompressHeader3Dart = int Function(
    Pointer<TJHandle> handle, Pointer<Uint8> jpegBuf, int jpegSize, Pointer<Uint32> width, Pointer<Uint32> height, Pointer<Uint32> jpegSubsamp, Pointer<Uint32> jpegColorspace);

class JpegTranBindings {
  TJInitTransformDart tjInitTransform;
  TJDestroyDart tjDestroy;
  TJDecompressHeader3Dart tjDecompressHeader3;
  TJTransformDart tjTransform;
  TJFreeDart tjFree;
  TJGetErrorStrDart tjGetErrorStr;

  JpegTranBindings() {
    final DynamicLibrary lib = (Platform.isAndroid || Platform.isLinux)
        ? DynamicLibrary.open("libturbojpeg.so") // android or linux
        : DynamicLibrary.process(); // ios

    tjInitTransform = lib.lookupFunction<TJInitTransformC, TJInitTransformDart>("tjInitTransform");

    tjDestroy = lib.lookupFunction<TJDestroyC, TJDestroyDart>("tjDestroy");

    tjDecompressHeader3 = lib.lookupFunction<TJDecompressHeader3C, TJDecompressHeader3Dart>("tjDecompressHeader3");

    tjTransform = lib.lookupFunction<TJTransformC, TJTransformDart>("tjTransform");

    tjFree = lib.lookupFunction<TJFreeC, TJFreeDart>("tjFree");

    tjGetErrorStr = lib.lookupFunction<TJGetErrorStrC, TJGetErrorStrDart>("tjGetErrorStr");
  }
}
