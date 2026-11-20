import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/core/error/exception_to_failure_mapper.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';

void main() {
  test('maps each supported application exception to its failure', () {
    final cases = <AppException, Type>{
      const ServerException('server', 's'): ServerFailure,
      const NetworkException('network', 'n'): NetworkFailure,
      const CacheException('cache', 'c'): CacheFailure,
      const AuthException('auth', 'a'): AuthFailure,
      const PermissionException('permission', 'p'): PermissionFailure,
      const NotFoundException('missing', '404'): NotFoundFailure,
      const ValidationException('invalid', '422'): ValidationFailure,
      const UnknownException('unknown', 'u'): UnknownFailure,
    };

    for (final entry in cases.entries) {
      final failure = ExceptionToFailureMapper.map(entry.key);
      expect(failure.runtimeType, entry.value);
      expect(failure.message, entry.key.message);
      expect(failure.code, entry.key.code);
    }
  });

  test('maps an unclassified AppException to UnknownFailure', () {
    final failure = ExceptionToFailureMapper.map(const CustomException('custom'));
    expect(failure, isA<UnknownFailure>());
  });
}

class CustomException extends AppException {
  const CustomException(super.message);
}
