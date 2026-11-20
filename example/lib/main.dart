import 'package:flutter/material.dart';
import 'package:flutter_catalog_feature/features/catalog/di/injection_container.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';

const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8000',
);

const demoUserId = String.fromEnvironment(
  'DEMO_USER_ID',
  defaultValue: 'demo-user-1',
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.instance;

  initCatalogDependencies(getIt: getIt, baseUrl: apiBaseUrl);

  runApp(DemoApp(getIt: getIt, userId: demoUserId));
}
