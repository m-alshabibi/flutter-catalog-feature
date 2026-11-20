import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/exceptions.dart';

void main() {
  group('AppException', () {
    test('should preserve message and code', () {
      const exception = ServerException('Server unavailable', '500');

      expect(exception.message, 'Server unavailable');
      expect(exception.code, '500');
    });

    test('should provide default messages', () {
      expect(NetworkException().message, isNotEmpty);
      expect(CacheException().message, isNotEmpty);
      expect(AuthException().message, isNotEmpty);
      expect(PermissionException().message, isNotEmpty);
      expect(NotFoundException().message, isNotEmpty);
      expect(UnknownException().message, isNotEmpty);
    });

    test('should implement Exception', () {
      const exception = NetworkException();

      expect(exception, isA<Exception>());
    });

    test('should format toString correctly', () {
      const exception = ServerException('Server error', '500');

      expect(exception.toString(), 'ServerException(500): Server error');
    });
  });
}
