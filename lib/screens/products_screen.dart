import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../models/product_model.dart';
import 'edit_product_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      const FavoritesScreen(),
                ),
              );
            },
            tooltip: 'Favorites',
            icon: const Icon(
              Icons.favorite_border,
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
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
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(state.message),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<ProductsCubit>()
                          .loadProducts();
                    },
                    child:
                        const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductsLoaded) {
            return _buildProductsGrid(
              context,
              state,
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProductsGrid(
    BuildContext context,
    ProductsLoaded state,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),

      itemCount: state.products.length,

      itemBuilder: (context, index) {
        final product =
            state.products[index];

        final isFavorite =
            state.favoriteIds.contains(
          product.id,
        );

        return _buildProductCard(
          context,
          product,
          isFavorite,
        );
      },
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product product,
    bool isFavorite,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  EditProductScreen(
                product: product,
              ),
            ),
          );
        },

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(8),

                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons
                                .image_not_supported,
                            size: 40,
                          );
                        },
                      ),
                    ),
                  ),

                  Positioned(
                    top: 0,
                    right: 0,

                    child: IconButton(
                      onPressed: () {
                        context
                            .read<
                                ProductsCubit>()
                            .toggleFavorite(
                              product.id,
                            );
                      },

                      icon: Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons
                                .favorite_border,

                        color: isFavorite
                            ? Colors.red
                            : Colors.grey,

                        size: 22,
                      ),
                    ),
                  ),
                ],
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

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style:
                              const TextStyle(
                            color: Colors.green,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          _deleteProduct(
                            context,
                            product,
                          );
                        },

                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                        ),

                        padding:
                            EdgeInsets.zero,

                        constraints:
                            const BoxConstraints(),
                      ),

                      const SizedBox(
                        width: 6,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

Future<void> _deleteProduct(
  BuildContext context,
  Product product,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to delete "${product.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (!context.mounted) {
    return;
  }

  if (confirmed != true) {
    return;
  }

  context.read<ProductsCubit>().deleteProduct(product.id);
}

  Future<void> _logout(
    BuildContext context,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),

          content: const Text(
            'Are you sure you want to logout?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('CANCEL'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'LOGOUT',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

  if (!context.mounted) return;

    if (confirmed != true) {
      return;
    }

    context.read<AuthCubit>().logout();

    Navigator.of(context)
        .pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            LoginScreen(),
      ),
      (route) => false,
    );
  }
}