import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';
import 'features/catalog/di/injection_container.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const baseUrl = 'http://127.0.0.1:8000';
  // if(android){
  //   baseUrl = 'http://10.0.2.2:8000';
  // }
  const userId = 'demo-user-1';

  initCatalogDependencies(getIt: getIt, baseUrl: baseUrl);

  runApp(DemoApp(getIt: getIt, userId: userId));
}
