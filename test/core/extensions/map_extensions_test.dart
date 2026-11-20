import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/extensions/map_extensions.dart';

void main() {
  group('SafeJsonExtension', () {
    final json = <String, dynamic>{
      'string': 'value', 'integer': 4.8, 'double': 3, 'boolean': true,
      'date': '2025-01-01T00:00:00.000Z', 'list': ['a', 'b'],
      'map': {'key': 'value'}, 'null': null,
    };

    test('reads scalar values and defaults', () {
      expect(json.asString('string'), 'value');
      expect(json.asString('missing', 'fallback'), 'fallback');
      expect(json.asStringNullable('missing'), isNull);
      expect(json.asInt('integer'), 4);
      expect(json.asInt('missing', 7), 7);
      expect(json.asDouble('double'), 3.0);
      expect(json.asBool('boolean'), isTrue);
      expect(json.asBool('missing'), isFalse);
    });

    test('reads nullable numbers and dates', () {
      expect(json.asIntNullable('integer'), 4);
      expect(json.asDoubleNullable('double'), 3.0);
      expect(json.asDateTimeNullable('date'), DateTime.parse(json['date'] as String));
      expect(json.asDateTimeNullable('null'), isNull);
      expect(json.asDateTimeNullable('missing'), isNull);
    });

    test('parses lists and maps', () {
      expect(json.asStringList('list'), ['a', 'b']);
      expect(json.asList<int>('missing', (value) => value as int), isEmpty);
      expect(json.asMap<String, String>('map'), {'key': 'value'});
      expect(json.asMap<String, String>('missing'), isEmpty);
      expect(json.asMapNullable<String, String>('missing'), isNull);
    });
  });
}
