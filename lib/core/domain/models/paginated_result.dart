class PaginatedResult<T> {
  final List<T> items;
  final bool hasMore;

  PaginatedResult({required List<T> items, required this.hasMore})
    : items = List.unmodifiable(items);
}
