import 'package:connectivity_plus/connectivity_plus.dart';

/// Provides a unified interface for monitoring network connectivity.
abstract interface class NetworkInfo {
  Future<bool> get isConnected;

  Stream<bool> get onStatusChange;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(this._connectivity);

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _hasConnection(results);
  }

  @override
  Stream<bool> get onStatusChange {
    return _connectivity.onConnectivityChanged.map(_hasConnection);
  }

  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }
}
