import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/network/dio_client.dart';

void main() {
  test('configures the base URL, timeouts and JSON headers', () {
    final client = DioClient(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 3),
      sendTimeout: const Duration(seconds: 4),
    ).dio;

    expect(client.options.baseUrl, 'https://api.example.com');
    expect(client.options.connectTimeout, const Duration(seconds: 2));
    expect(client.options.receiveTimeout, const Duration(seconds: 3));
    expect(client.options.sendTimeout, const Duration(seconds: 4));
    expect(client.options.headers[Headers.acceptHeader], Headers.jsonContentType);
    expect(client.options.headers[Headers.contentTypeHeader], Headers.jsonContentType);
  });
}
