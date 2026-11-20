import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'controllers/catalog/catalog_cubit.dart';
import 'controllers/favorites/favorites_cubit.dart';

class CatalogFeature extends StatelessWidget {
  final GetIt getIt;
  final String userId;
  final Widget child;

  const CatalogFeature({
    super.key,
    required this.getIt,
    required this.userId,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CatalogCubit>(
          create: (_) => getIt<CatalogCubit>()..loadCatalog(),
        ),
        BlocProvider<FavoritesCubit>(
          create: (_) => getIt<FavoritesCubit>(param1: userId)..loadFavorites(),
        ),
      ],
      child: child,
    );
  }
}
