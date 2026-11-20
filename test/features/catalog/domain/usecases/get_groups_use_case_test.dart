import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/domain/usecases/no_params.dart';
import 'package:flutter_catalog_feature/core/error/failures.dart';
import 'package:flutter_catalog_feature/core/result/result.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/entities/group_entity.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/repositories/group_repository.dart';
import 'package:flutter_catalog_feature/features/catalog/domain/usecases/get_groups_use_case.dart';
import 'package:mocktail/mocktail.dart';

class MockGroupRepository extends Mock implements GroupRepository {}

void main() {
  late MockGroupRepository repository;
  late GetGroupsUseCase useCase;

  setUp(() {
    repository = MockGroupRepository();
    useCase = GetGroupsUseCase(repository);
  });

  final group = GroupEntity(id: 'group-1', name: 'Development');

  test('should return groups from the repository', () async {
    final expectedResult = Success<List<GroupEntity>>([group]);

    when(() => repository.getGroups()).thenAnswer((_) async => expectedResult);

    final result = await useCase(const NoParams());

    expect(result, same(expectedResult));

    verify(() => repository.getGroups()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('should return failure when repository fails', () async {
    final expectedResult = FailureResult<List<GroupEntity>>(
      const NetworkFailure(),
    );

    when(() => repository.getGroups()).thenAnswer((_) async => expectedResult);

    final result = await useCase(const NoParams());

    expect(result, same(expectedResult));

    verify(() => repository.getGroups()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
