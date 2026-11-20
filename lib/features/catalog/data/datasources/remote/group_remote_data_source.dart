import 'package:dio/dio.dart';

import '../../../../../core/network/dio_exception_handler.dart';
import '../../models/group_model.dart';

abstract interface class GroupRemoteDataSource {
  Future<List<GroupModel>> getGroups();
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final Dio _dio;

  GroupRemoteDataSourceImpl(this._dio);

  @override
  Future<List<GroupModel>> getGroups() async {
    try {
      final response = await _dio.get('/groups');

      final data = response.data;

      if (data is! List) {
        throw const FormatException('Invalid groups response format.');
      }

      return data.map((item) {
        if (item is! Map) {
          throw const FormatException('Invalid group item format.');
        }

        return GroupModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } on DioException catch (exception) {
      throw DioExceptionHandler.handle(exception);
    }
  }
}
