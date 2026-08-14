import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../models/product_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: BlocBuilder<
          ProductsCubit,
          ProductsState>(
        builder: (context, state) {
          if (state is ProductsLoading ||
              state is ProductsInitial) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (state is ProductsError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is ProductsLoaded) {
            final favoriteProducts =
                state.products.where(
              (product) {
                return state.favoriteIds
                    .contains(product.id);
              },
            ).toList();

            if (favoriteProducts.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 60,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'No favorite products',
                    ),

                    SizedBox(height: 4),

                    Text(
                      'Tap the heart on any product',
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding:
                  const EdgeInsets.all(12),

              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),

              itemCount:
                  favoriteProducts.length,

              itemBuilder:
                  (context, index) {
                final product =
                    favoriteProducts[index];

                return _buildFavoriteCard(
                  context,
                  product,
                );
              },
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    Product product,
  ) {
    return Card(
      clipBehavior:
          Clip.antiAlias,

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,

        children: [
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.all(8),

              child: Image.network(
                product.image,
                fit: BoxFit.contain,

                errorBuilder:
                    (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 40,
                  );
                },
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              8,
              4,
              4,
              4,
            ),

            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),

                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style:
                            const TextStyle(
                          color: Colors.green,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {
                    context
                        .read<
                            ProductsCubit>()
                        .toggleFavorite(
                          product.id,
                        );
                  },

                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}