import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';

void main() {
  test('Success carries its data', () {
    const result = Success<int>(42);
    expect(result.data, 42);
  });

  test('FailureResult carries its failure', () {
    const failure = NetworkFailure('offline');
    const result = FailureResult<int>(failure);
    expect(result.failure, same(failure));
  });
}
