import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/use_case.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';

class TestUseCase extends UseCase<String, NoParams> {
  @override
  Future<Result<String>> call(NoParams params) async {
    return const Success('Success');
  }
}

void main() {
  group('UseCase', () {
    test('should return Result when executed', () async {
      final useCase = TestUseCase();

      final result = await useCase(const NoParams());

      expect(result, isA<Success<String>>());
      expect((result as Success<String>).data, 'Success');
    });
  });

  group('NoParams', () {
    test('should be instantiable as a constant', () {
      const params = NoParams();

      expect(params, isA<NoParams>());
    });
  });
}
