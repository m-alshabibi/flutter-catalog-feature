import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_catalog_feature/core/network/network_info.dart';

class FakeConnectivity implements Connectivity {
  FakeConnectivity(this.checkResults, this.changes);
  final Future<List<ConnectivityResult>> Function() checkResults;
  final Stream<List<ConnectivityResult>> changes;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() => checkResults();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('reports disconnected only when all results are none', () async {
    final offline = NetworkInfoImpl(FakeConnectivity(
      () async => [ConnectivityResult.none],
      const Stream.empty(),
    ));
    final online = NetworkInfoImpl(FakeConnectivity(
      () async => [ConnectivityResult.wifi, ConnectivityResult.none],
      const Stream.empty(),
    ));
    expect(await offline.isConnected, isFalse);
    expect(await online.isConnected, isTrue);
  });

  test('maps connectivity stream values to connection booleans', () async {
    final info = NetworkInfoImpl(FakeConnectivity(
      () async => [ConnectivityResult.none],
      Stream.fromIterable([
        [ConnectivityResult.none],
        [ConnectivityResult.mobile],
      ]),
    ));
    expect(await info.onStatusChange.toList(), [false, true]);
  });
}
