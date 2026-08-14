import '../models/product_model.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final Set<int> favoriteIds;

  ProductsLoaded({
    required this.products,
    required this.favoriteIds,
  });
}

class ProductsError extends ProductsState {
  final String message;

  ProductsError(this.message);
}