import 'package:json_annotation/json_annotation.dart';

class ToStringConverter implements JsonConverter<String, dynamic> {
  const ToStringConverter();

  @override
  String fromJson(dynamic value) {
    if (value is String) return value;
    if (value != null) return value.toString();
    throw ArgumentError('Expected non-null value for String field');
  }

  @override
  dynamic toJson(String value) => value;
}
