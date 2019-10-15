import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:jpegtran_ffi/jpegtran_ffi.dart';

void main() {

  setUp(() {
  });

  tearDown(() {
  });

  test('bad jpeg', () async {
    var transformer = JpegTransformer(Uint8List.fromList([1,2,3]));
    transformer.getInfo();
  });
}
