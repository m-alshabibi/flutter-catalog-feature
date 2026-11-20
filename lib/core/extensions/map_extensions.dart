extension SafeJsonExtension on Map<String, dynamic> {
  String asString(String key, [String defaultValue = '']) =>
      this[key] as String? ?? defaultValue;

  String? asStringNullable(String key) => this[key] as String?;

  int asInt(String key, [int defaultValue = 0]) =>
      (this[key] as num?)?.toInt() ?? defaultValue;

  int? asIntNullable(String key) => (this[key] as num?)?.toInt();

  double asDouble(String key, [double defaultValue = 0.0]) =>
      (this[key] as num?)?.toDouble() ?? defaultValue;

  double? asDoubleNullable(String key) => (this[key] as num?)?.toDouble();

  bool asBool(String key, [bool defaultValue = false]) =>
      this[key] as bool? ?? defaultValue;

  bool? asBoolNullable(String key) => this[key] as bool?;

  DateTime asDateTime(String key) =>
      this[key] == null ? DateTime.now() : DateTime.parse(this[key] as String);

  DateTime? asDateTimeNullable(String key) =>
      this[key] == null ? null : DateTime.tryParse(this[key] as String);

  List<T> asList<T>(String key, T Function(dynamic e) parser) {
    final list = this[key] as List<dynamic>?;
    if (list == null) return [];
    return list.map(parser).toList();
  }

  List<String> asStringList(String key) =>
      asList<String>(key, (value) => value as String);

  Map<K, V>? asMap<K, V>(String key) {
    final value = this[key];
    if (value == null) return {};
    if (value is Map) {
      return Map<K, V>.from(value);
    }
    return {};
  }

  Map<K, V>? asMapNullable<K, V>(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is Map) {
      return Map<K, V>.from(value);
    }
    return null;
  }
}
