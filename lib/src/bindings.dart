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
typedef TJInitC = Pointer<TJHandle> Function();
typedef TJInitDart = Pointer<TJHandle> Function();

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
unsigned long tjBufSizeYUV2(
  int  	width,
  int  	pad,
  int  	height,
  int  	subsamp 
) 		
*/
typedef TJBufSizeYUV2C = Int32 Function(
  Uint32 width,
  Uint32 pad,
  Uint32 height,
  Uint32 subsamp,
);
typedef TJBufSizeYUV2Dart = int Function(
  int width,
  int pad,
  int height,
  int subsamp,
);

/*
int tjDecompressToYUV2(
  tjhandle  	handle,
  const unsigned char *  	jpegBuf,
  unsigned long  	jpegSize,
  unsigned char *  	dstBuf,
  int  	width,
  int  	pad,
  int  	height,
  int  	flags 
  )
*/
typedef TJDecompressToYUV2C = Int32 Function(
  Pointer<TJHandle> handle,
  Pointer<Uint8> jpegBuf,
  IntPtr jpegSize,
  Pointer<Uint8> dstBuf,
  Uint32 width,
  Uint32 pad,
  Uint32 height,
  Uint32 flags,
);

typedef TJDecompressToYUV2Dart = int Function(
  Pointer<TJHandle> handle,
  Pointer<Uint8> jpegBuf,
  int jpegSize,
  Pointer<Uint8> dstBuf,
  int width,
  int pad,
  int height,
  int flags,
);

/*
int tjCompressFromYUV(
  tjhandle  	handle,
  const unsigned char *  	srcBuf,
  int  	width,
  int  	pad,
  int  	height,
  int  	subsamp,
  unsigned char **  	jpegBuf,
  unsigned long *  	jpegSize,
  int  	jpegQual,
  int  	flags 
) 	
*/
typedef TJCompressFromYUVC = Int32 Function(
  Pointer<TJHandle> handle,
  Pointer<Uint8> srcBuf,
  Uint32 width,
  Uint32 pad,
  Uint32 height,
  Uint32 subsamp,
  Pointer<Pointer<Uint8>> jpegBuf,
  Pointer<IntPtr> jpegSize,
  Uint32 jpegQual,
  Uint32 flags,
);
typedef TJCompressFromYUVDart = int Function(
  Pointer<TJHandle> handle,
  Pointer<Uint8> srcBuf,
  int width,
  int pad,
  int height,
  int subsamp,
  Pointer<Pointer<Uint8>> jpegBuf,
  Pointer<IntPtr> jpegSize,
  int jpegQual,
  int flags,
);

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
  TJInitDart tjInitCompress;
  TJInitDart tjInitDecompress;
  TJInitDart tjInitTransform;
  TJDestroyDart tjDestroy;
  TJDecompressHeader3Dart tjDecompressHeader3;
  TJBufSizeYUV2Dart tjBufSizeYUV2;
  TJDecompressToYUV2Dart tjDecompressToYUV2;
  TJCompressFromYUVDart tjCompressFromYUV; 
  TJTransformDart tjTransform;
  TJFreeDart tjFree;
  TJGetErrorStrDart tjGetErrorStr;

  JpegTranBindings() {
    final DynamicLibrary lib = (Platform.isAndroid || Platform.isLinux)
        ? DynamicLibrary.open("libturbojpeg.so") // android or linux
        : DynamicLibrary.process(); // ios

    tjInitCompress = lib.lookupFunction<TJInitC, TJInitDart>("tjInitCompress");
    tjInitDecompress = lib.lookupFunction<TJInitC, TJInitDart>("tjInitDecompress");
    tjInitTransform = lib.lookupFunction<TJInitC, TJInitDart>("tjInitTransform");

    tjDestroy = lib.lookupFunction<TJDestroyC, TJDestroyDart>("tjDestroy");

    tjDecompressHeader3 = lib.lookupFunction<TJDecompressHeader3C, TJDecompressHeader3Dart>("tjDecompressHeader3");
    tjBufSizeYUV2 = lib.lookupFunction<TJBufSizeYUV2C, TJBufSizeYUV2Dart>("tjBufSizeYUV2");
    tjDecompressToYUV2 = lib.lookupFunction<TJDecompressToYUV2C, TJDecompressToYUV2Dart>("tjDecompressToYUV2");
    tjCompressFromYUV = lib.lookupFunction<TJCompressFromYUVC, TJCompressFromYUVDart>("tjCompressFromYUV");

    tjTransform = lib.lookupFunction<TJTransformC, TJTransformDart>("tjTransform");

    tjFree = lib.lookupFunction<TJFreeC, TJFreeDart>("tjFree");

    tjGetErrorStr = lib.lookupFunction<TJGetErrorStrC, TJGetErrorStrDart>("tjGetErrorStr");
  }
}
