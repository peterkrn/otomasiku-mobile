import 'package:json_annotation/json_annotation.dart';

class BigIntStringConverter implements JsonConverter<int, dynamic> {
  const BigIntStringConverter();

  @override
  int fromJson(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw FormatException('Cannot parse $value as int');
  }

  @override
  String toJson(int value) => value.toString();
}

class NullableBigIntStringConverter implements JsonConverter<int?, dynamic> {
  const NullableBigIntStringConverter();

  @override
  int? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.parse(value);
    throw FormatException('Cannot parse $value as int');
  }

  @override
  dynamic toJson(int? value) => value?.toString();
}
