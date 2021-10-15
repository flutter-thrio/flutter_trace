import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_trace/flutter_trace.dart';

void main() {
  test('adds one to input values', () {
    final tp = TraceParent.start(sampled: true);
    print(tp.toString());
    final b = tp.isValidHeader(tp.toString());
    print(b);

    // expect(b, true);
  });
}
