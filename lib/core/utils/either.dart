sealed class Either<L, R> {
  const Either();
  T fold<T>(T Function(L l) left, T Function(R r) right) {
    if (this is Left<L, R>) {
      return left((this as Left<L, R>).value);
    } else if (this is Right<L, R>) {
      return right((this as Right<L, R>).value);
    } else {
      throw Exception('Invalid Either type');
    }
  }
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);
}
