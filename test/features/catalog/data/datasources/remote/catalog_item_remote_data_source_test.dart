import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/core/network/dio_client.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/catalog_item_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/models/catalog_item_model.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  group('CatalogItemRemoteDataSource', () {
    late DioClient dioClient;
    late DioAdapter dioAdapter;
    late CatalogItemRemoteDataSourceImpl dataSource;

    const baseUrl = 'https://mock-api.test';

    final itemsJson = [
      {
        'id': 'item-1',
        'groupId': 'group-1',
        'name': 'Flutter Development',
        'shortDescription': 'Flutter services',
        'longDescription': 'Full Flutter development services',
        'imageUrl': 'https://example.com/flutter.jpg',
        'gallery': [
          'https://example.com/flutter-1.jpg',
          'https://example.com/flutter-2.jpg',
        ],
        'sortOrder': 1,
        'isActive': true,
        'isFeatured': true,
        'metadata': {'level': 'advanced'},
        'createdAt': '2026-01-01T10:00:00',
        'updatedAt': '2026-01-01T10:00:00',
      },
      {
        'id': 'item-2',
        'groupId': 'group-1',
        'name': 'Backend Development',
        'shortDescription': 'Backend services',
        'longDescription': 'Backend development services',
        'imageUrl': null,
        'gallery': [],
        'sortOrder': 2,
        'isActive': true,
        'isFeatured': false,
        'metadata': null,
        'createdAt': '2026-01-02T10:00:00',
        'updatedAt': '2026-01-02T10:00:00',
      },
      {
        'id': 'item-3',
        'groupId': 'group-2',
        'name': 'UI Design',
        'shortDescription': 'Design services',
        'longDescription': 'User interface design services',
        'imageUrl': 'https://example.com/design.jpg',
        'gallery': [],
        'sortOrder': 1,
        'isActive': true,
        'isFeatured': false,
        'metadata': null,
        'createdAt': '2026-01-03T10:00:00',
        'updatedAt': '2026-01-03T10:00:00',
      },
    ];

    setUp(() {
      dioClient = DioClient(baseUrl: baseUrl);

      dioAdapter = DioAdapter(dio: dioClient.dio);
      dioClient.dio.httpClientAdapter = dioAdapter;

      dataSource = CatalogItemRemoteDataSourceImpl(dioClient.dio);
    });

    tearDown(() {
      dioClient.dio.close(force: true);
    });

    group('getAllCatalogItems', () {
      test('should fetch and group catalog items by groupId', () async {
        dioAdapter.onGet(
          '/catalog-items',
          (server) => server.reply(200, itemsJson),
        );

        final result = await dataSource.getAllCatalogItems();

        expect(result, isA<Map<String, List<CatalogItemModel>>>());

        expect(result.keys, containsAll(['group-1', 'group-2']));
        expect(result['group-1'], hasLength(2));
        expect(result['group-2'], hasLength(1));

        expect(result['group-1']![0].id, 'item-1');
        expect(result['group-1']![1].id, 'item-2');
        expect(result['group-2']![0].id, 'item-3');
      });

      test('should return an empty map when no items exist', () async {
        dioAdapter.onGet('/catalog-items', (server) => server.reply(200, []));

        final result = await dataSource.getAllCatalogItems();

        expect(result, isEmpty);
      });
    });

    group('getCatalogItems', () {
      test('should fetch items for the requested group', () async {
        dioAdapter.onGet(
          '/catalog-items',
          (server) => server.reply(
            200,
            itemsJson.where((item) => item['groupId'] == 'group-1').toList(),
          ),
          queryParameters: {'groupId': 'group-1'},
        );

        final result = await dataSource.getCatalogItems('group-1');

        expect(result, hasLength(2));
        expect(result.every((item) => item.groupId == 'group-1'), isTrue);
      });

      test('should return an empty list when the group has no items', () async {
        dioAdapter.onGet(
          '/catalog-items',
          (server) => server.reply(200, []),
          queryParameters: {'groupId': 'group-3'},
        );

        final result = await dataSource.getCatalogItems('group-3');

        expect(result, isEmpty);
      });
    });

    group('getCatalogItemById', () {
      test('should fetch and convert a catalog item', () async {
        dioAdapter.onGet(
          '/catalog-items/item-1',
          (server) => server.reply(200, itemsJson.first),
        );

        final result = await dataSource.getCatalogItemById('item-1');

        expect(result, isA<CatalogItemModel>());
        expect(result.id, 'item-1');
        expect(result.groupId, 'group-1');
        expect(result.name, 'Flutter Development');
        expect(result.gallery, hasLength(2));
        expect(result.isFeatured, isTrue);
        expect(result.metadata, {'level': 'advanced'});
      });

      test('should convert HTTP 404 to NotFoundException', () async {
        dioAdapter.onGet(
          '/catalog-items/unknown',
          (server) => server.reply(404, {'detail': 'Catalog item not found.'}),
        );

        expect(
          () => dataSource.getCatalogItemById('unknown'),
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

    group('Error handling', () {
      test('should convert HTTP 500 to ServerException', () async {
        dioAdapter.onGet(
          '/catalog-items',
          (server) => server.reply(500, {'detail': 'Internal server error.'}),
        );

        expect(
          () => dataSource.getAllCatalogItems(),
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
          '/catalog-items',
          (server) => server.throws(
            0,
            DioException(
              requestOptions: RequestOptions(path: '/catalog-items'),
              type: DioExceptionType.connectionError,
            ),
          ),
        );

        expect(
          () => dataSource.getAllCatalogItems(),
          throwsA(
            isA<NetworkException>().having(
              (exception) => exception.code,
              'code',
              'connection_error',
            ),
          ),
        );
      });

      test('should throw FormatException for invalid list response', () async {
        dioAdapter.onGet(
          '/catalog-items',
          (server) => server.reply(200, {'items': itemsJson}),
        );

        expect(
          () => dataSource.getAllCatalogItems(),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw FormatException for invalid list item', () async {
        dioAdapter.onGet(
          '/catalog-items',
          (server) => server.reply(200, ['invalid-item']),
        );

        expect(
          () => dataSource.getAllCatalogItems(),
          throwsA(isA<FormatException>()),
        );
      });

      test(
        'should throw FormatException for invalid single item response',
        () async {
          dioAdapter.onGet(
            '/catalog-items/item-1',
            (server) => server.reply(200, ['invalid-item']),
          );

          expect(
            () => dataSource.getCatalogItemById('item-1'),
            throwsA(isA<FormatException>()),
          );
        },
      );
    });
  });
}
