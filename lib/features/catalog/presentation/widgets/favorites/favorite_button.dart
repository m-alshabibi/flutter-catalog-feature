import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../controllers/favorites/favorites_cubit.dart';
import '../../controllers/favorites/favorites_state.dart';

typedef FavoriteButtonBuilder = Widget Function(
  BuildContext context,
  bool isFavorite,
  bool isUpdating,
  VoidCallback onPressed,
);

class FavoriteButton extends StatelessWidget {
  final String itemId;
  final FavoriteButtonBuilder? builder;
  final double iconSize;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.itemId,
    this.builder,
    this.iconSize = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      FavoritesCubit,
      FavoritesState,
      ({bool isFavorite, bool isUpdating})
    >(
      selector: (state) => (
        isFavorite: state.isFavorite(itemId),
        isUpdating: state.isUpdating(itemId),
      ),
      builder: (context, value) {
        void onPressed() {
          context.read<FavoritesCubit>().toggleFavorite(itemId);
        }

        if (builder != null) {
          return builder!(
            context,
            value.isFavorite,
            value.isUpdating,
            onPressed,
          );
        }

        return IconButton(
          onPressed: value.isUpdating ? null : onPressed,
          tooltip: value.isFavorite
              ? 'Remove from favorites'
              : 'Add to favorites',
          iconSize: iconSize,
          color: value.isFavorite
              ? activeColor ?? Theme.of(context).colorScheme.error
              : inactiveColor ?? Theme.of(context).colorScheme.onSurface,
          icon: value.isUpdating
              ? SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(value.isFavorite ? Icons.favorite : Icons.favorite_border),
        );
      },
    );
  }
}
