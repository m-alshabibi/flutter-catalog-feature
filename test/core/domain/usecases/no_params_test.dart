import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';

void main() {
  test('NoParams instances compare equally', () {
    expect(const NoParams(), const NoParams());
    expect(const NoParams().hashCode, const NoParams().hashCode);
  });
}
