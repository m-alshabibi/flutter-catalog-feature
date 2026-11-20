import 'package:dio/dio.dart';

import '../../../../../core/network/dio_exception_handler.dart';
import '../../models/favorite_model.dart';

abstract interface class FavoriteRemoteDataSource {
  Future<List<FavoriteModel>> getFavorites(String userId);

  Future<void> addFavorite(String userId, String catalogItemId);

  Future<void> removeFavorite(String userId, String catalogItemId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final Dio _dio;

  FavoriteRemoteDataSourceImpl(this._dio);

  @override
  Future<List<FavoriteModel>> getFavorites(String userId) async {
    try {
      final response = await _dio.get(
        '/favorites',
        queryParameters: {'userId': userId},
      );

      return _parseFavorites(response.data);
    } on DioException catch (exception) {
      throw DioExceptionHandler.handle(exception);
    }
  }

  @override
  Future<void> addFavorite(String userId, String catalogItemId) async {
    try {
      await _dio.post(
        '/favorites',
        data: {'userId': userId, 'catalogItemId': catalogItemId},
      );
    } on DioException catch (exception) {
      throw DioExceptionHandler.handle(exception);
    }
  }

  @override
  Future<void> removeFavorite(String userId, String catalogItemId) async {
    try {
      await _dio.delete(
        '/favorites/$catalogItemId',
        queryParameters: {'userId': userId},
      );
    } on DioException catch (exception) {
      throw DioExceptionHandler.handle(exception);
    }
  }

  List<FavoriteModel> _parseFavorites(dynamic data) {
    if (data is! List) {
      throw const FormatException('Invalid favorites response format.');
    }

    return data.map((item) {
      if (item is! Map) {
        throw const FormatException('Invalid favorite item format.');
      }

      return FavoriteModel.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }
}
