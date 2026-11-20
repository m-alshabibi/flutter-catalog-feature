import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_item_by_id_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog_item_details/catalog_item_details_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCatalogItemByIdUseCase extends Mock
    implements GetCatalogItemByIdUseCase {}

void main() {
  late MockGetCatalogItemByIdUseCase getCatalogItemByIdUseCase;
  late CatalogItemEntity item;
  late CatalogItemDetailsCubit cubit;

  const itemId = 'item-1';

  setUp(() {
    getCatalogItemByIdUseCase = MockGetCatalogItemByIdUseCase();

    item = CatalogItemEntity(id: itemId, groupId: 'group-1', name: 'Service 1');

    cubit = CatalogItemDetailsCubit(
      getCatalogItemByIdUseCase: getCatalogItemByIdUseCase,
      itemId: itemId,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('loadItem', () {
    test('should emit loaded item when use case succeeds', () async {
      when(() => getCatalogItemByIdUseCase(itemId))
          .thenAnswer((_) async => Success<CatalogItemEntity>(item));

      await cubit.loadItem();

      expect(cubit.state.item, item);
      expect(cubit.state.hasLoaded, isTrue);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.failure, isNull);

      verify(() => getCatalogItemByIdUseCase(itemId)).called(1);
    });

    test('should emit failure when use case fails', () async {
      const failure = UnknownFailure();

      when(() => getCatalogItemByIdUseCase(itemId))
          .thenAnswer((_) async => FailureResult<CatalogItemEntity>(failure));

      await cubit.loadItem();

      expect(cubit.state.item, isNull);
      expect(cubit.state.hasLoaded, isFalse);
      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.failure, failure);
    });

    test('should not load the same item more than once', () async {
      when(() => getCatalogItemByIdUseCase(itemId))
          .thenAnswer((_) async => Success<CatalogItemEntity>(item));

      await cubit.loadItem();
      await cubit.loadItem();

      verify(() => getCatalogItemByIdUseCase(itemId)).called(1);
    });

    test('should prevent duplicate concurrent requests', () async {
      final completer = Completer<Result<CatalogItemEntity>>();

      when(() => getCatalogItemByIdUseCase(itemId))
          .thenAnswer((_) => completer.future);

      final firstRequest = cubit.loadItem();

      await cubit.loadItem();

      verify(() => getCatalogItemByIdUseCase(itemId)).called(1);

      completer.complete(Success<CatalogItemEntity>(item));

      await firstRequest;

      expect(cubit.state.item, item);
      expect(cubit.state.hasLoaded, isTrue);
    });

    test('should allow retry after failure', () async {
      when(() => getCatalogItemByIdUseCase(itemId)).thenAnswer(
        (_) async => const FailureResult<CatalogItemEntity>(UnknownFailure()),
      );

      await cubit.loadItem();

      when(() => getCatalogItemByIdUseCase(itemId))
          .thenAnswer((_) async => Success<CatalogItemEntity>(item));

      await cubit.retryLoadItem();

      expect(cubit.state.item, item);
      expect(cubit.state.hasLoaded, isTrue);
      expect(cubit.state.failure, isNull);

      verify(() => getCatalogItemByIdUseCase(itemId)).called(2);
    });
  });
}
