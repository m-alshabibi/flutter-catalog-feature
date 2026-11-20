import 'exceptions.dart';
import 'failures.dart';

class ExceptionToFailureMapper {
  ExceptionToFailureMapper._();

  static Failure map(AppException exception) {
    return switch (exception) {
      ServerException() => ServerFailure(exception.message, exception.code),
      NetworkException() => NetworkFailure(exception.message, exception.code),
      CacheException() => CacheFailure(exception.message, exception.code),
      AuthException() => AuthFailure(exception.message, exception.code),
      PermissionException() => PermissionFailure(
        exception.message,
        exception.code,
      ),
      NotFoundException() => NotFoundFailure(exception.message, exception.code),
      ValidationException() => ValidationFailure(
        exception.message,
        exception.code,
      ),
      UnknownException() => UnknownFailure(exception.message, exception.code),
      AppException() => UnknownFailure(exception.message, exception.code),
    };
  }
}
