import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/core/network/dio_exception_handler.dart';

void main() {
  test('maps timeout and connection errors to NetworkException', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
      DioExceptionType.badCertificate,
    ]) {
      final exception = DioException(requestOptions: RequestOptions(path: '/'), type: type);
      expect(DioExceptionHandler.handle(exception), isA<NetworkException>());
    }
  });

  test('maps HTTP validation, authentication, permission and not found errors', () {
    final entries = <int, Type>{
      400: ValidationException,
      422: ValidationException,
      401: AuthException,
      403: PermissionException,
      404: NotFoundException,
      500: ServerException,
    };
    for (final entry in entries.entries) {
      final response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        statusCode: entry.key,
        data: {'detail': 'response detail'},
      );
      final exception = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
      );
      final mapped = DioExceptionHandler.handle(exception);
      expect(mapped.runtimeType, entry.value);
      expect(mapped.message, 'response detail');
    }
  });

  test('maps missing response and cancellation to UnknownException', () {
    final missing = DioExceptionHandler.handle(
      DioException(requestOptions: RequestOptions(path: '/'), type: DioExceptionType.badResponse),
    );
    final canceled = DioExceptionHandler.handle(
      DioException(requestOptions: RequestOptions(path: '/'), type: DioExceptionType.cancel),
    );
    expect(missing, isA<UnknownException>());
    expect(canceled, isA<UnknownException>());
  });
}
