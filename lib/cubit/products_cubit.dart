import 'package:flutter_bloc/flutter_bloc.dart';

import '../api_service.dart';
import '../favorites_helper.dart';
import '../models/product_model.dart';
import 'products_state.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ApiService apiService;

  ProductsCubit(this.apiService) : super(ProductsInitial());

  Future<void> loadProducts() async {
    emit(ProductsLoading());

    try {
      final data = await apiService.getProducts();

      final products = data
          .map(
            (json) => Product.fromJson(
              Map<String, dynamic>.from(json as Map),
            ),
          )
          .toList();

      final favoriteIds =
          await FavoritesHelper.getFavoriteIds();

      final favorites = favoriteIds
          .map(int.parse)
          .toSet();

      emit(
        ProductsLoaded(
          products: products,
          favoriteIds: favorites,
        ),
      );
    } catch (e) {
      emit(
        ProductsError(
          'Failed to load products',
        ),
      );
    }
  }

  Future<void> toggleFavorite(int productId) async {
    if (state is! ProductsLoaded) return;

    final currentState = state as ProductsLoaded;

    final isFavorite =
        await FavoritesHelper.toggleFavorite(productId);

    final newFavoriteIds =
        Set<int>.from(currentState.favoriteIds);

    if (isFavorite) {
      newFavoriteIds.add(productId);
    } else {
      newFavoriteIds.remove(productId);
    }

    emit(
      ProductsLoaded(
        products: currentState.products,
        favoriteIds: newFavoriteIds,
      ),
    );
  }

  Future<void> updateProduct(
    int id,
    String title,
    double price,
  ) async {
    if (state is! ProductsLoaded) return;

    final currentState = state as ProductsLoaded;

    try {
      await apiService.updateProduct(
        id,
        title,
        price,
      );

      final updatedProducts =
          currentState.products.map((product) {
        if (product.id == id) {
          return product.copyWith(
            title: title,
            price: price,
          );
        }

        return product;
      }).toList();

      emit(
        ProductsLoaded(
          products: updatedProducts,
          favoriteIds: currentState.favoriteIds,
        ),
      );
    } catch (e) {
      emit(
        ProductsError(
          'Failed to update product',
        ),
      );

      emit(
        ProductsLoaded(
          products: currentState.products,
          favoriteIds: currentState.favoriteIds,
        ),
      );
    }
  }

  Future<void> deleteProduct(int productId) async {
    if (state is! ProductsLoaded) return;

    final currentState = state as ProductsLoaded;

    try {
      await apiService.deleteProduct(productId);

      await FavoritesHelper.removeFavorite(productId);

      final updatedProducts =
          currentState.products
              .where(
                (product) => product.id != productId,
              )
              .toList();

      final updatedFavorites =
          Set<int>.from(currentState.favoriteIds);

      updatedFavorites.remove(productId);

      emit(
        ProductsLoaded(
          products: updatedProducts,
          favoriteIds: updatedFavorites,
        ),
      );
    } catch (e) {
      emit(
        ProductsError(
          'Failed to delete product',
        ),
      );

      emit(
        ProductsLoaded(
          products: currentState.products,
          favoriteIds: currentState.favoriteIds,
        ),
      );
    }
  }
}