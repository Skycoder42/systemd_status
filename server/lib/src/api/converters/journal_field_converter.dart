import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

/// Besides plain strings, journalctl encodes fields with non-printable or
/// non-UTF-8 content as byte arrays, fields with multiple values as arrays and
/// fields that exceed the size limit as `null`.
class const JournalFieldConverter() implements JsonConverter<String, Object?> {
  @override
  String fromJson(Object? json) => switch (json) {
    null => '',
    final String value => value,
    final List<dynamic> bytes when bytes.every((b) => b is int) => utf8.decode(
      bytes.cast<int>(),
      allowMalformed: true,
    ),
    final List<dynamic> values => values.map(fromJson).join('\n'),
    _ => json.toString(),
  };

  @override
  String toJson(String object) => object;
}
