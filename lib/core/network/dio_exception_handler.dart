import 'package:dio/dio.dart';

import '../error/exceptions.dart';

class DioExceptionHandler {
  DioExceptionHandler._();

  static AppException handle(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          'Connection timed out.',
          'connection_timeout',
        );

      case DioExceptionType.sendTimeout:
        return const NetworkException(
          'Request sending timed out.',
          'send_timeout',
        );

      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          'Response receiving timed out.',
          'receive_timeout',
        );

      case DioExceptionType.connectionError:
        return const NetworkException(
          'Unable to connect to the server.',
          'connection_error',
        );

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Server certificate validation failed.',
          'bad_certificate',
        );
      case DioExceptionType.transformTimeout:
        return const UnknownException(
          'Response transformation timed out.',
          'transform_timeout',
        );
      case DioExceptionType.cancel:
        return const UnknownException(
          'Request was cancelled.',
          'request_cancelled',
        );

      case DioExceptionType.badResponse:
        return _handleResponse(exception.response);

      case DioExceptionType.unknown:
        return const UnknownException(
          'An unexpected network error occurred.',
          'unknown_network_error',
        );
    }
  }

  static AppException _handleResponse(Response<dynamic>? response) {
    if (response == null) {
      return const UnknownException(
        'An unexpected response error occurred.',
        'missing_response',
      );
    }

    final statusCode = response.statusCode;
    final code = 'http_$statusCode';
    final message = _extractMessage(response.data);

    switch (statusCode) {
      case 400:
      case 422:
        return ValidationException(
          message ?? 'Request validation failed.',
          code,
        );

      case 401:
        return AuthException(message ?? 'Authentication failed.', code);

      case 403:
        return PermissionException(message ?? 'Permission denied.', code);

      case 404:
        return NotFoundException(
          message ?? 'The requested resource was not found.',
          code,
        );

      default:
        if (statusCode != null && statusCode >= 500) {
          return ServerException(message ?? 'Server error occurred.', code);
        }

        return ServerException(message ?? 'Request failed.', code);
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map) {
      final detail = data['detail'];

      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }

      final message = data['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    return null;
  }
}
