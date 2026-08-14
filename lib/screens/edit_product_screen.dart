import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/products_cubit.dart';
import '../cubit/products_state.dart';
import '../models/product_model.dart';

class EditProductScreen extends StatelessWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    String title = product.title;
    String priceText = product.price.toString();

    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductsLoaded) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Edit Product',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<ProductsCubit, ProductsState>(
          builder: (context, state) {
            final isLoading = state is ProductsLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: product.title,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter title';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        title = value;
                      },
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      initialValue:
                          product.price.toStringAsFixed(2),
                      enabled: !isLoading,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter price';
                        }

                        if (double.tryParse(value.trim()) == null) {
                          return 'Please enter a valid price';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        priceText = value;
                      },
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 50,
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                final price =
                                    double.tryParse(priceText);

                                if (price == null) {
                                  return;
                                }

                                context
                                    .read<ProductsCubit>()
                                    .updateProduct(
                                      product.id,
                                      title,
                                      price,
                                    );
                              },
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}