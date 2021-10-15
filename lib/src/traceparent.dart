//
// Created on Thu Oct 14 2021.
//
// Copyright (c) 2021 foxsofter.
//

import 'dart:math';
import 'dart:typed_data';

class TraceParent {
  factory TraceParent.start({bool sampled = false}) {
    final buffer = Uint8List(Size.all);
    _randomFill(buffer, offset: Offset.traceId, size: Size.ids);
    if (sampled) {
      buffer[Offset.flags] |= Flags.recorded;
    }
    return TraceParent._(buffer);
  }

  factory TraceParent.fromString(String header) {
    return TraceParent._(_headerToBuffer(header));
  }

  TraceParent._(this._buffer);

  bool isValidHeader(String header) =>
      RegExp('^[\da-f]{2}-[\da-f]{32}-[\da-f]{16}-[\da-f]{2}\$').hasMatch(header);

  @override
  String toString() {
    return '$version-$traceId-$id-$flags';
  }

  bool get recorded => (_buffer[Offset.flags] & Flags.recorded) != 0;

  String get version => _slice(Offset.version, Offset.traceId);

  String get traceId => _slice(Offset.traceId, Offset.id);

  String get id => _slice(Offset.id, Offset.flags);

  String get flags => _slice(Offset.flags, Offset.parentId);

  String get parentId => _slice(Offset.parentId, Offset.parentId + Size.parentId);

  String _slice(int start, int end) => _buffer.sublist(start, end).toBase16();

  final Uint8List _buffer;
}

abstract class Size {
  static const version = 1;
  static const traceId = 16;
  static const id = 8;
  static const flags = 1;
  static const parentId = 8;
  static const ids = 24;
  static const all = 35;
}

abstract class Flags {
  static const recorded = 1;
}

abstract class Offset {
  static const version = 0;
  static const traceId = Size.version;
  static const id = Size.version + Size.traceId;
  static const flags = Size.version + Size.traceId + Size.id;
  static const parentId = Size.version + Size.traceId + Size.id + Size.flags;
}

Uint8List _headerToBuffer(String header) {
  final buffer = Uint8List(Size.all);
  buffer.setAll(0, header.replaceAll('-', '').codeUnits);
  return buffer;
}

void _randomFill(Uint8List buffer, {int offset = 0, int size = 0}) {
  if (size == 0) {
    size = buffer.length - offset;
  }
  if (size + offset > buffer.length) {
    throw RangeError('The value of "size + offset" is out of range. '
        'It must be <= ${buffer.length}. Received ${size + offset}');
  }
  final randomBuffer = _randomBytes(size);
  buffer.setRange(offset, offset + size, randomBuffer);
}

Uint8List _randomBytes(int length, {bool secure = false}) {
  assert(length > 0);
  final random = secure ? Random.secure() : Random();
  final buffer = Uint8List(length);
  for (var i = 0; i < length; i++) {
    buffer[i] = random.nextInt(256);
  }
  return buffer;
}

extension on Uint8List {
  String toBase16() {
    final buffer = StringBuffer();
    for (final int byte in this) buffer.write(byte.toRadixString(16).padLeft(2, "0"));
    return buffer.toString();
  }
}
