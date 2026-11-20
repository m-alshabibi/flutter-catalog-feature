import 'package:drift/native.dart';
import 'package:flutter_catalog_feature/features/catalog/data/datasources/local/database/app_database.dart';

AppDatabase createTestDatabase() => AppDatabase(NativeDatabase.memory());
