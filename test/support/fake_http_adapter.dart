import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class CallbackHttpAdapter implements HttpClientAdapter {
  CallbackHttpAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}

  static ResponseBody jsonResponse(Object? data, {int statusCode = 200}) {
    return ResponseBody.fromString(
      jsonEncode(data),
      statusCode,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }
}
