/// Represents application failures in the Domain layer.
///
/// Independent of Flutter and external data sources.
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => '$runtimeType($code): $message';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Network connection failed.',
    super.code,
  ]);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Failed to access cached data.',
    super.code,
  ]);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.', super.code]);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied.', super.code]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested resource was not found.',
    super.code,
  ]);
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;

  const ValidationFailure(super.message, [super.code, this.errors]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([
    super.message = 'An unexpected error occurred.',
    super.code,
  ]);
}
