class PaginationParams {
  static const int defaultPageSize = 20;

  final int limit;
  final int offset;

  const PaginationParams({this.limit = defaultPageSize, this.offset = 0})
    : assert(limit > 0, 'Limit must be greater than zero.'),
      assert(offset >= 0, 'Offset cannot be negative.');

  PaginationParams nextPage({int? limit}) {
    return PaginationParams(
      limit: limit ?? this.limit,
      offset: offset + this.limit,
    );
  }
}
