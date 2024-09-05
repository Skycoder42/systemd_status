import 'package:json_annotation/json_annotation.dart';

class EpochDateTimeConverter implements JsonConverter<DateTime, String> {
  const EpochDateTimeConverter();

  @override
  DateTime fromJson(String json) =>
      DateTime.fromMicrosecondsSinceEpoch(int.parse(json, radix: 10));

  @override
  String toJson(DateTime object) => object.microsecondsSinceEpoch.toString();
}
