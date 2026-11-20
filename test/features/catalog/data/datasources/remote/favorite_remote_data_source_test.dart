import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/core/network/dio_client.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/favorite_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/favorite_model.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('FavoriteRemoteDataSource', () {
    late DioClient dioClient;
    late DioAdapter dioAdapter;
    late FavoriteRemoteDataSourceImpl dataSource;

    const baseUrl = 'https://mock-api.test';

    const userId = 'user-1';
    const catalogItemId = 'item-1';

    final favoriteJson = {
      'id': 'favorite-1',
      'userId': userId,
      'catalogItemId': catalogItemId,
      'createdAt': '2026-01-01T10:00:00',
      'updatedAt': '2026-01-01T10:00:00',
    };

    final favoritesJson = [
      favoriteJson,
      {
        'id': 'favorite-2',
        'userId': userId,
        'catalogItemId': 'item-2',
        'createdAt': '2026-01-02T10:00:00',
        'updatedAt': '2026-01-02T10:00:00',
      },
    ];

    setUp(() {
      dioClient = DioClient(baseUrl: baseUrl);

      dioAdapter = DioAdapter(dio: dioClient.dio);
      dioClient.dio.httpClientAdapter = dioAdapter;

      dataSource = FavoriteRemoteDataSourceImpl(dioClient.dio);
    });

    tearDown(() {
      dioClient.dio.close(force: true);
    });

    group('getFavorites', () {
      test('should fetch and convert user favorites', () async {
        dioAdapter.onGet(
          '/favorites',
          (server) => server.reply(200, favoritesJson),
          queryParameters: {'userId': userId},
        );

        final result = await dataSource.getFavorites(userId);

        expect(result, isA<List<FavoriteModel>>());
        expect(result, hasLength(2));

        expect(result[0].id, 'favorite-1');
        expect(result[0].userId, userId);
        expect(result[0].catalogItemId, catalogItemId);

        expect(result[1].id, 'favorite-2');
        expect(result[1].catalogItemId, 'item-2');
      });

      test('should return an empty list when no favorites exist', () async {
        dioAdapter.onGet(
          '/favorites',
          (server) => server.reply(200, []),
          queryParameters: {'userId': userId},
        );

        final result = await dataSource.getFavorites(userId);

        expect(result, isEmpty);
      });

      test(
        'should throw FormatException for invalid response format',
        () async {
          dioAdapter.onGet(
            '/favorites',
            (server) => server.reply(200, {'favorites': favoritesJson}),
            queryParameters: {'userId': userId},
          );

          expect(
            () => dataSource.getFavorites(userId),
            throwsA(isA<FormatException>()),
          );
        },
      );

      test('should throw FormatException for invalid favorite item', () async {
        dioAdapter.onGet(
          '/favorites',
          (server) => server.reply(200, ['invalid-favorite']),
          queryParameters: {'userId': userId},
        );

        expect(
          () => dataSource.getFavorites(userId),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('addFavorite', () {
      test('should add a favorite successfully', () async {
        dioAdapter.onPost(
          '/favorites',
          (server) => server.reply(201, favoriteJson),
          data: {'userId': userId, 'catalogItemId': catalogItemId},
        );

        await expectLater(
          dataSource.addFavorite(userId, catalogItemId),
          completes,
        );
      });

      test('should convert HTTP 404 to NotFoundException', () async {
        dioAdapter.onPost(
          '/favorites',
          (server) => server.reply(404, {'detail': 'Catalog item not found.'}),
          data: {'userId': userId, 'catalogItemId': catalogItemId},
        );

        expect(
          () => dataSource.addFavorite(userId, catalogItemId),
          throwsA(
            isA<NotFoundException>()
                .having((exception) => exception.code, 'code', 'http_404')
                .having(
                  (exception) => exception.message,
                  'message',
                  'Catalog item not found.',
                ),
          ),
        );
      });
    });

    group('removeFavorite', () {
      test('should remove a favorite successfully', () async {
        dioAdapter.onDelete(
          '/favorites/$catalogItemId',
          (server) =>
              server.reply(200, {'message': 'Favorite removed successfully.'}),
          queryParameters: {'userId': userId},
        );

        await expectLater(
          dataSource.removeFavorite(userId, catalogItemId),
          completes,
        );
      });

      test('should convert HTTP 404 to NotFoundException', () async {
        dioAdapter.onDelete(
          '/favorites/$catalogItemId',
          (server) => server.reply(404, {'detail': 'Favorite not found.'}),
          queryParameters: {'userId': userId},
        );

        expect(
          () => dataSource.removeFavorite(userId, catalogItemId),
          throwsA(
            isA<NotFoundException>()
                .having((exception) => exception.code, 'code', 'http_404')
                .having(
                  (exception) => exception.message,
                  'message',
                  'Favorite not found.',
                ),
          ),
        );
      });
    });

    group('Error handling', () {
      test('should convert HTTP 500 to ServerException', () async {
        dioAdapter.onGet(
          '/favorites',
          (server) => server.reply(500, {'detail': 'Internal server error.'}),
          queryParameters: {'userId': userId},
        );

        expect(
          () => dataSource.getFavorites(userId),
          throwsA(
            isA<ServerException>().having(
              (exception) => exception.code,
              'code',
              'http_500',
            ),
          ),
        );
      });

      test('should convert connection errors to NetworkException', () async {
        dioAdapter.onGet(
          '/favorites',
          (server) => server.throws(
            0,
            DioException(
              requestOptions: RequestOptions(path: '/favorites'),
              type: DioExceptionType.connectionError,
            ),
          ),
          queryParameters: {'userId': userId},
        );

        expect(
          () => dataSource.getFavorites(userId),
          throwsA(
            isA<NetworkException>().having(
              (exception) => exception.code,
              'code',
              'connection_error',
            ),
          ),
        );
      });
    });
  });
}
