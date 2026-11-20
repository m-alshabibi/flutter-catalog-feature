import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/utils/either.dart';

void main() {
  test('Left.fold invokes the left handler', () {
    const Either<String, int> value = Left('problem');
    expect(value.fold((left) => left, (right) => '$right'), 'problem');
  });

  test('Right.fold invokes the right handler', () {
    const Either<String, int> value = Right(7);
    expect(value.fold((left) => left, (right) => 'value-$right'), 'value-7');
  });
}
