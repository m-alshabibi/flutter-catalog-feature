import 'package:dio/dio.dart';

import '../../../../../core/network/dio_exception_handler.dart';
import '../../models/catalog_item_model.dart';

abstract interface class CatalogItemRemoteDataSource {
  Future<Map<String, List<CatalogItemModel>>> getAllCatalogItems();

  Future<List<CatalogItemModel>> getCatalogItems(String groupId);

  Future<CatalogItemModel> getCatalogItemById(String id);
}

class CatalogItemRemoteDataSourceImpl implements CatalogItemRemoteDataSource {
  final Dio _dio;

  CatalogItemRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, List<CatalogItemModel>>> getAllCatalogItems() async {
    try {
      final response = await _dio.get('/catalog-items');

      final items = _parseCatalogItems(response.data);
      final groupedItems = <String, List<CatalogItemModel>>{};

      for (final item in items) {
        groupedItems.putIfAbsent(item.groupId, () => []).add(item);
      }

      return groupedItems;
    } on DioException catch (exception) {
      throw DioExceptionHandler.handle(exception);
    }
  }

  @override
  Future<List<CatalogItemModel>> getCatalogItems(String groupId) async {
    try {
      final response = await _dio.get(
        '/catalog-items',
        queryParameters: {'groupId': groupId},
      );

      return _parseCatalogItems(response.data);
    } on DioException catch (exception) {
      throw DioExceptionHandler.handle(exception);
    }
  }

  @override
  Future<CatalogItemModel> getCatalogItemById(String id) async {
    try {
      final response = await _dio.get('/catalog-items/$id');
      final data = response.data;

      if (data is! Map) {
        throw const FormatException('Invalid catalog item response format.');
      }

      return CatalogItemModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (exception) {
      throw DioExceptionHandler.handle(exception);
    }
  }

  List<CatalogItemModel> _parseCatalogItems(dynamic data) {
    if (data is! List) {
      throw const FormatException('Invalid catalog items response format.');
    }

    return data.map((item) {
      if (item is! Map) {
        throw const FormatException('Invalid catalog item format.');
      }

      return CatalogItemModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}
