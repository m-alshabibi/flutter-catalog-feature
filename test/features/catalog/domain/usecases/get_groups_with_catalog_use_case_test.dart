import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/catalog_item_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/models/group_with_catalog.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/catalog_item_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/group_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_groups_with_catalog_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

class MockCatalogItemRepository extends Mock implements CatalogItemRepository {}

void main() {
  late MockGroupRepository groupRepository;
  late MockCatalogItemRepository catalogItemRepository;
  late GetGroupsWithCatalogUseCase useCase;

  late GroupEntity group1;
  late GroupEntity group2;

  late CatalogItemEntity item1;
  late CatalogItemEntity item2;

  setUp(() {
    groupRepository = MockGroupRepository();
    catalogItemRepository = MockCatalogItemRepository();

    useCase = GetGroupsWithCatalogUseCase(
      groupRepository: groupRepository,
      catalogItemRepository: catalogItemRepository,
    );

    group1 = GroupEntity(id: 'group-1', name: 'Development');

    group2 = GroupEntity(id: 'group-2', name: 'Design');

    item1 = CatalogItemEntity(
      id: 'item-1',
      groupId: 'group-1',
      name: 'Flutter Development',
    );

    item2 = CatalogItemEntity(
      id: 'item-2',
      groupId: 'group-1',
      name: 'Backend Development',
    );
  });

  group('GetGroupsWithCatalogUseCase', () {
    test('should return groups with their catalog items', () async {
      // Arrange
      when(
        () => groupRepository.getGroups(),
      ).thenAnswer((_) async => Success<List<GroupEntity>>([group1, group2]));

      when(() => catalogItemRepository.getAllCatalogItems()).thenAnswer(
        (_) async => Success<Map<String, List<CatalogItemEntity>>>({
          'group-1': [item1, item2],
        }),
      );

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result, isA<Success<List<GroupWithCatalog>>>());

      final data = (result as Success<List<GroupWithCatalog>>).data;

      expect(data, hasLength(2));

      expect(data[0].group, group1);
      expect(data[0].catalogItems, [item1, item2]);

      expect(data[1].group, group2);
      expect(data[1].catalogItems, isEmpty);

      verify(() => groupRepository.getGroups()).called(1);
      verify(() => catalogItemRepository.getAllCatalogItems()).called(1);

      verifyNoMoreInteractions(groupRepository);
      verifyNoMoreInteractions(catalogItemRepository);
    });

    test('should return failure when getting groups fails', () async {
      // Arrange
      const failure = NetworkFailure();

      when(() => groupRepository.getGroups()).thenAnswer(
        (_) async => const FailureResult<List<GroupEntity>>(failure),
      );

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result, isA<FailureResult<List<GroupWithCatalog>>>());

      final resultFailure =
          (result as FailureResult<List<GroupWithCatalog>>).failure;

      expect(resultFailure, isA<NetworkFailure>());

      verify(() => groupRepository.getGroups()).called(1);
      verifyNever(() => catalogItemRepository.getAllCatalogItems());

      verifyNoMoreInteractions(groupRepository);
      verifyNoMoreInteractions(catalogItemRepository);
    });

    test('should return failure when getting catalog items fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to load catalog.');

      when(() => groupRepository.getGroups())
          .thenAnswer((_) async => Success<List<GroupEntity>>([group1]));

      when(() => catalogItemRepository.getAllCatalogItems()).thenAnswer(
        (_) async =>
            const FailureResult<Map<String, List<CatalogItemEntity>>>(failure),
      );

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result, isA<FailureResult<List<GroupWithCatalog>>>());

      final resultFailure =
          (result as FailureResult<List<GroupWithCatalog>>).failure;

      expect(resultFailure, isA<ServerFailure>());

      verify(() => groupRepository.getGroups()).called(1);
      verify(() => catalogItemRepository.getAllCatalogItems()).called(1);

      verifyNoMoreInteractions(groupRepository);
      verifyNoMoreInteractions(catalogItemRepository);
    });

    test('should return empty list when there are no groups', () async {
      // Arrange
      when(() => groupRepository.getGroups())
          .thenAnswer((_) async => const Success<List<GroupEntity>>([]));

      when(() => catalogItemRepository.getAllCatalogItems()).thenAnswer(
        (_) async => const Success<Map<String, List<CatalogItemEntity>>>({}),
      );

      // Act
      final result = await useCase.call(const NoParams());

      // Assert
      expect(result, isA<Success<List<GroupWithCatalog>>>());

      final data = (result as Success<List<GroupWithCatalog>>).data;

      expect(data, isEmpty);

      verify(() => groupRepository.getGroups()).called(1);
      verify(() => catalogItemRepository.getAllCatalogItems()).called(1);
    });
  });
}
