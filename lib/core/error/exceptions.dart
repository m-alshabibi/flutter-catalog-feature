/// Base class for data-layer exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => '$runtimeType($code): $message';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred.', super.code]);
}

class NetworkException extends AppException {
  const NetworkException([
    super.message = 'Network connection failed.',
    super.code,
  ]);
}

class CacheException extends AppException {
  const CacheException([
    super.message = 'Failed to access cached data.',
    super.code,
  ]);
}

class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.', super.code]);
}

class PermissionException extends AppException {
  const PermissionException([super.message = 'Permission denied.', super.code]);
}

class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested resource was not found.',
    super.code,
  ]);
}

class UnknownException extends AppException {
  const UnknownException([
    super.message = 'An unexpected error occurred.',
    super.code,
  ]);
}

class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Request validation failed.',
    super.code,
  ]);
}
