import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/error/exceptions.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/catalog_item_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/favorite_remote_data_source.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/remote/group_remote_data_source.dart';
import '../../../../../support/fake_http_adapter.dart';

Map<String, dynamic> groupJson(String id) => {
  'id': id, 'name': 'Group $id', 'createdAt': '2025-01-01T00:00:00.000Z',
  'updatedAt': '2025-01-02T00:00:00.000Z',
};
Map<String, dynamic> itemJson(String id, String groupId) => {
  'id': id, 'groupId': groupId, 'name': 'Item $id',
  'createdAt': '2025-01-01T00:00:00.000Z',
  'updatedAt': '2025-01-02T00:00:00.000Z',
};
Map<String, dynamic> favoriteJson(String id, String userId, String itemId) => {
  'id': id, 'userId': userId, 'catalogItemId': itemId,
  'createdAt': '2025-01-01T00:00:00.000Z',
  'updatedAt': '2025-01-02T00:00:00.000Z',
};

Dio createDio(Future<ResponseBody> Function(RequestOptions) handler) {
  final dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
  dio.httpClientAdapter = CallbackHttpAdapter(handler);
  return dio;
}

void main() {
  test('GroupRemoteDataSource parses groups', () async {
    final dio = createDio((_) async => CallbackHttpAdapter.jsonResponse([groupJson('g1')]));
    final result = await GroupRemoteDataSourceImpl(dio).getGroups();
    expect(result.single.id, 'g1');
    expect(result.single.name, 'Group g1');
  });

  test('GroupRemoteDataSource rejects a non-list response', () async {
    final dio = createDio((_) async => CallbackHttpAdapter.jsonResponse({'data': []}));
    expect(GroupRemoteDataSourceImpl(dio).getGroups(), throwsFormatException);
  });

  test('CatalogItemRemoteDataSource groups full catalog response by group ID', () async {
    final dio = createDio((_) async => CallbackHttpAdapter.jsonResponse([
      itemJson('i1', 'g1'), itemJson('i2', 'g1'), itemJson('i3', 'g2'),
    ]));
    final result = await CatalogItemRemoteDataSourceImpl(dio).getAllCatalogItems();
    expect(result['g1']!.map((item) => item.id), ['i1', 'i2']);
    expect(result['g2']!.single.id, 'i3');
  });

  test('CatalogItemRemoteDataSource sends group filter and parses item details', () async {
    RequestOptions? captured;
    final dio = createDio((options) async {
      captured = options;
      if (options.path.endsWith('/i1')) {
        return CallbackHttpAdapter.jsonResponse(itemJson('i1', 'g1'));
      }
      return CallbackHttpAdapter.jsonResponse([itemJson('i1', 'g1')]);
    });
    final source = CatalogItemRemoteDataSourceImpl(dio);
    final list = await source.getCatalogItems('g1');
    expect(list.single.id, 'i1');
    expect(captured!.queryParameters['groupId'], 'g1');
    final item = await source.getCatalogItemById('i1');
    expect(item.id, 'i1');
  });

  test('FavoriteRemoteDataSource sends expected query, body and delete path', () async {
    final paths = <String>[];
    final methods = <String>[];
    final bodies = <dynamic>[];
    final dio = createDio((options) async {
      paths.add(options.path);
      methods.add(options.method);
      bodies.add(options.data);
      return options.method == 'GET'
          ? CallbackHttpAdapter.jsonResponse([favoriteJson('f1', 'u1', 'i1')])
          : CallbackHttpAdapter.jsonResponse({});
    });
    final source = FavoriteRemoteDataSourceImpl(dio);
    expect((await source.getFavorites('u1')).single.catalogItemId, 'i1');
    await source.addFavorite('u1', 'i1');
    await source.removeFavorite('u1', 'i1');
    expect(paths, ['/favorites', '/favorites', '/favorites/i1']);
    expect(methods, ['GET', 'POST', 'DELETE']);
    final body = bodies[1] is String
        ? jsonDecode(bodies[1] as String) as Map
        : bodies[1] as Map;
    expect(body['userId'], 'u1');
    expect(body['catalogItemId'], 'i1');
  });

  test('remote sources translate Dio failures into application exceptions', () async {
    final dio = createDio((options) async {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );
    });
    await expectLater(GroupRemoteDataSourceImpl(dio).getGroups(), throwsA(isA<NetworkException>()));
  });
}
