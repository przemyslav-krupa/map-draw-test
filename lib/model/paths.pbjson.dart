//
//  Generated code. Do not modify.
//  source: paths.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use vector2Descriptor instead')
const Vector2$json = {
  '1': 'Vector2',
  '2': [
    {'1': 'x', '3': 1, '4': 1, '5': 1, '10': 'x'},
    {'1': 'y', '3': 2, '4': 1, '5': 1, '10': 'y'},
  ],
};

/// Descriptor for `Vector2`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vector2Descriptor = $convert.base64Decode(
    'CgdWZWN0b3IyEgwKAXgYASABKAFSAXgSDAoBeRgCIAEoAVIBeQ==');

@$core.Deprecated('Use pathDescriptor instead')
const Path$json = {
  '1': 'Path',
  '2': [
    {'1': 'points', '3': 1, '4': 3, '5': 11, '6': '.Vector2', '10': 'points'},
  ],
};

/// Descriptor for `Path`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pathDescriptor = $convert.base64Decode(
    'CgRQYXRoEiAKBnBvaW50cxgBIAMoCzIILlZlY3RvcjJSBnBvaW50cw==');

@$core.Deprecated('Use pathCollectionDescriptor instead')
const PathCollection$json = {
  '1': 'PathCollection',
  '2': [
    {'1': 'paths', '3': 1, '4': 3, '5': 11, '6': '.Path', '10': 'paths'},
  ],
};

/// Descriptor for `PathCollection`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pathCollectionDescriptor = $convert.base64Decode(
    'Cg5QYXRoQ29sbGVjdGlvbhIbCgVwYXRocxgBIAMoCzIFLlBhdGhSBXBhdGhz');

