import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 15),
    Duration receiveTimeout = const Duration(seconds: 15),
    Duration sendTimeout = const Duration(seconds: 15),
  }) : dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
           sendTimeout: sendTimeout,
           responseType: ResponseType.json,
           headers: {
             Headers.acceptHeader: Headers.jsonContentType,
             Headers.contentTypeHeader: Headers.jsonContentType,
           },
         ),
       );
}
