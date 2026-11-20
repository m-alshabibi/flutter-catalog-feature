import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_catalog_items_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_groups_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_catalog_items_by_group_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/refresh_groups_use_case.dart';
import 'package:flutter_catalog_feature/features/catalog/presentation/controllers/catalog/catalog_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockGetGroupsUseCase extends Mock implements GetGroupsUseCase {}

class MockRefreshGroupsUseCase extends Mock implements RefreshGroupsUseCase {}

class MockGetCatalogItemsUseCase extends Mock
    implements GetCatalogItemsUseCase {}

class MockRefreshCatalogItemsByGroupUseCase extends Mock
    implements RefreshCatalogItemsByGroupUseCase {}

// class FakeGroupEntity extends Fake implements GroupEntity {}

void main() {
  late MockGetGroupsUseCase getGroups;
  late MockRefreshGroupsUseCase refreshGroups;
  late MockGetCatalogItemsUseCase getCatalogItems;
  late MockRefreshCatalogItemsByGroupUseCase refreshGroupItems;

  late CatalogCubit cubit;
  late GroupEntity fakeGroup;

  setUp(() {
    getGroups = MockGetGroupsUseCase();
    refreshGroups = MockRefreshGroupsUseCase();
    getCatalogItems = MockGetCatalogItemsUseCase();
    refreshGroupItems = MockRefreshCatalogItemsByGroupUseCase();

    // fakeGroup = FakeGroupEntity();

    fakeGroup = GroupEntity(id: 'group-1', name: 'Test Group');

    // when(() => fakeGroup.id).thenReturn('group-1');

    cubit = CatalogCubit(
      getGroupsUseCase: getGroups,
      refreshGroupsUseCase: refreshGroups,
      getCatalogItemsUseCase: getCatalogItems,
      refreshCatalogItemsByGroupUseCase: refreshGroupItems,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('loadCatalog', () {
    test('should load groups and refresh them remotely', () async {
      when(() => getGroups(const NoParams()))
          .thenAnswer((_) async => Success<List<GroupEntity>>([fakeGroup]));

      when(() => refreshGroups(const NoParams()))
          .thenAnswer((_) async => const Success<void>(null));

      await cubit.loadCatalog();

      expect(cubit.state.groups, [fakeGroup]);
      expect(cubit.state.hasLoaded, true);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.isRefreshing, false);
      expect(cubit.state.failure, isNull);

      verify(() => getGroups(const NoParams())).called(2);
      verify(() => refreshGroups(const NoParams())).called(1);
    });

    test('should not load groups again when already loaded', () async {
      when(() => getGroups(const NoParams()))
          .thenAnswer((_) async => Success<List<GroupEntity>>([fakeGroup]));

      when(() => refreshGroups(const NoParams()))
          .thenAnswer((_) async => const Success<void>(null));

      await cubit.loadCatalog();
      await cubit.loadCatalog();

      verify(() => getGroups(const NoParams())).called(2);
      verify(() => refreshGroups(const NoParams())).called(1);
    });

    test('should preserve local groups when remote refresh fails', () async {
      when(() => getGroups(const NoParams()))
          .thenAnswer((_) async => Success<List<GroupEntity>>([fakeGroup]));

      when(() => refreshGroups(const NoParams()))
          .thenAnswer((_) async => FailureResult<void>(const NetworkFailure()));

      await cubit.loadCatalog();

      expect(cubit.state.groups, [fakeGroup]);
      expect(cubit.state.hasLoaded, true);
      expect(cubit.state.failure, isNull);
    });

    test('should expose failure when local and remote loading fail', () async {
      when(() => getGroups(const NoParams())).thenAnswer(
        (_) async => FailureResult<List<GroupEntity>>(const CacheFailure()),
      );

      when(() => refreshGroups(const NoParams()))
          .thenAnswer((_) async => FailureResult<void>(const NetworkFailure()));

      await cubit.loadCatalog();

      expect(cubit.state.groups, isEmpty);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.failure, isA<Failure>());
    });
  });

  group('loadGroupItems', () {
    setUp(() {
      when(() => getGroups(const NoParams()))
          .thenAnswer((_) async => Success<List<GroupEntity>>([fakeGroup]));

      when(() => refreshGroups(const NoParams()))
          .thenAnswer((_) async => const Success<void>(null));

      when(() => getCatalogItems('group-1'))
          .thenAnswer((_) async => Success<List<CatalogItemEntity>>([]));

      when(() => refreshGroupItems('group-1'))
          .thenAnswer((_) async => const Success<void>(null));
    });

    test('should load and refresh one group independently', () async {
      await cubit.loadCatalog();
      await cubit.loadGroupItems('group-1');

      final groupState = cubit.state.groupState('group-1');

      expect(groupState.hasLoaded, true);
      expect(groupState.items, isEmpty);
      expect(groupState.isLoading, false);
      expect(groupState.isRefreshing, false);
      expect(groupState.failure, isNull);

      verify(() => getCatalogItems('group-1')).called(2);
      verify(() => refreshGroupItems('group-1')).called(1);
    });

    test('should not reload an already loaded group', () async {
      await cubit.loadCatalog();

      await cubit.loadGroupItems('group-1');
      await cubit.loadGroupItems('group-1');

      verify(() => getCatalogItems('group-1')).called(2);
      verify(() => refreshGroupItems('group-1')).called(1);
    });

    test('should ignore unknown group IDs', () async {
      await cubit.loadCatalog();

      await cubit.loadGroupItems('unknown-group');

      verifyNever(() => getCatalogItems('unknown-group'));
      verifyNever(() => refreshGroupItems('unknown-group'));
    });
  });
}
