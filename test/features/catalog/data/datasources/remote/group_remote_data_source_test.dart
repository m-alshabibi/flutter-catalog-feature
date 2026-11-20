import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/core/network/dio_client.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/group_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/group_model.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('GroupRemoteDataSource', () {
    late DioClient dioClient;
    late DioAdapter dioAdapter;
    late GroupRemoteDataSourceImpl dataSource;

    const baseUrl = 'https://mock-api.test';

    final groupsJson = [
      {
        'id': 'group-1',
        'name': 'Technology',
        'description': 'Technology services',
        'imageUrl': 'https://example.com/technology.jpg',
        'sortOrder': 1,
        'isActive': true,
        'createdAt': '2026-01-01T10:00:00',
        'updatedAt': '2026-01-01T10:00:00',
      },
      {
        'id': 'group-2',
        'name': 'Design',
        'description': 'Design services',
        'imageUrl': 'https://example.com/design.jpg',
        'sortOrder': 2,
        'isActive': true,
        'createdAt': '2026-01-02T10:00:00',
        'updatedAt': '2026-01-02T10:00:00',
      },
    ];

    setUp(() {
      dioClient = DioClient(baseUrl: baseUrl);

      dioAdapter = DioAdapter(dio: dioClient.dio);

      dioClient.dio.httpClientAdapter = dioAdapter;

      dataSource = GroupRemoteDataSourceImpl(dioClient.dio);
    });

    tearDown(() {
      dioClient.dio.close(force: true);
    });

    group('getGroups', () {
      test('should fetch groups and convert them to GroupModels', () async {
        dioAdapter.onGet('/groups', (server) => server.reply(200, groupsJson));

        final result = await dataSource.getGroups();

        expect(result, isA<List<GroupModel>>());
        expect(result, hasLength(2));

        expect(result[0].id, 'group-1');
        expect(result[0].name, 'Technology');
        expect(result[0].description, 'Technology services');

        expect(result[1].id, 'group-2');
        expect(result[1].name, 'Design');
      });

      test('should return an empty list when no groups exist', () async {
        dioAdapter.onGet('/groups', (server) => server.reply(200, []));

        final result = await dataSource.getGroups();

        expect(result, isEmpty);
      });

      test('should convert HTTP 404 to NotFoundException', () async {
        dioAdapter.onGet(
          '/groups',
          (server) => server.reply(404, {'detail': 'Groups not found.'}),
        );

        expect(
          () => dataSource.getGroups(),
          throwsA(
            isA<NotFoundException>()
                .having((exception) => exception.code, 'code', 'http_404')
                .having(
                  (exception) => exception.message,
                  'message',
                  'Groups not found.',
                ),
          ),
        );
      });

      test('should convert HTTP 500 to ServerException', () async {
        dioAdapter.onGet(
          '/groups',
          (server) => server.reply(500, {'detail': 'Internal server error.'}),
        );

        expect(
          () => dataSource.getGroups(),
          throwsA(
            isA<ServerException>()
                .having((exception) => exception.code, 'code', 'http_500')
                .having(
                  (exception) => exception.message,
                  'message',
                  'Internal server error.',
                ),
          ),
        );
      });

      test('should convert connection errors to NetworkException', () async {
        dioAdapter.onGet(
          '/groups',
          (server) => server.throws(
            0,
            DioException(
              requestOptions: RequestOptions(path: '/groups'),
              type: DioExceptionType.connectionError,
            ),
          ),
        );

        expect(
          () => dataSource.getGroups(),
          throwsA(
            isA<NetworkException>().having(
              (exception) => exception.code,
              'code',
              'connection_error',
            ),
          ),
        );
      });

      test(
        'should throw FormatException for invalid response format',
        () async {
          dioAdapter.onGet(
            '/groups',
            (server) => server.reply(200, {'groups': groupsJson}),
          );

          expect(() => dataSource.getGroups(), throwsA(isA<FormatException>()));
        },
      );

      test('should throw FormatException for invalid group item', () async {
        dioAdapter.onGet(
          '/groups',
          (server) => server.reply(200, ['invalid-group']),
        );

        expect(() => dataSource.getGroups(), throwsA(isA<FormatException>()));
      });
    });
  });
}
