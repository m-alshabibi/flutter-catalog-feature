import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/result/result.dart';
import '../../../domain/entities/catalog_item_entity.dart';
import '../../../domain/usecases/get_catalog_item_by_id_use_case.dart';
import 'catalog_item_details_state.dart';

class CatalogItemDetailsCubit extends Cubit<CatalogItemDetailsState> {
  final GetCatalogItemByIdUseCase _getCatalogItemByIdUseCase;
  final String itemId;

  CatalogItemDetailsCubit({
    required this._getCatalogItemByIdUseCase,
    required this.itemId,
  }) : super(const CatalogItemDetailsState()) {
    if (itemId.trim().isEmpty) {
      throw ArgumentError.value(
        itemId,
        'itemId',
        'Catalog item ID cannot be empty.',
      );
    }
  }

  /// Loads the item once; call again after a failed attempt to retry.
  Future<void> loadItem() async {
    if (isClosed || state.isLoading || state.hasLoaded) return;

    emit(state.copyWith(isLoading: true, clearFailure: true));

    try {
      final result = await _getCatalogItemByIdUseCase(itemId);
      if (isClosed) return;

      if (result is Success<CatalogItemEntity>) {
        emit(
          state.copyWith(
            item: result.data,
            hasLoaded: true,
            isLoading: false,
            clearFailure: true,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, failure: _failureOf(result)));
      }
    } finally {
      if (!isClosed && state.isLoading) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  Future<void> retryLoadItem() => loadItem();

  Failure _failureOf<T>(Result<T> result) {
    if (result is FailureResult<T>) {
      return result.failure;
    }

    return const UnknownFailure();
  }
}
