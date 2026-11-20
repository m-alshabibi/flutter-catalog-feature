import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/models/paginated_result.dart';
import 'package:flutter_catalog_feature/core/domain/models/pagination_params.dart';

void main() {
  test('PaginationParams creates the next offset without changing page size', () {
    const first = PaginationParams(limit: 10, offset: 20);
    final next = first.nextPage();
    expect(next.limit, 10);
    expect(next.offset, 30);
  });

  test('PaginatedResult exposes an immutable item list', () {
    final source = [1, 2];
    final result = PaginatedResult<int>(items: source, hasMore: true);
    source.add(3);
    expect(result.items, [1, 2]);
    expect(result.hasMore, isTrue);
    expect(() => result.items.add(4), throwsUnsupportedError);
  });
}
