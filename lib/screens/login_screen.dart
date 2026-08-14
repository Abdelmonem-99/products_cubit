import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'products_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  final _usernameController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  const ProductsScreen(),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AuthLoading;

        String? errorMessage;

        if (state is AuthError) {
          errorMessage = state.message;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Login',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    const Text(
                      'LOGIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 40),

                    TextFormField(
                      controller: _usernameController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Username',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter username';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration:
                          const InputDecoration(
                        labelText: 'Password',
                        border:
                            OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter password';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    if (errorMessage != null)
                      Text(
                        errorMessage,
                        textAlign:
                            TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 50,
                      child: isLoading
                          ? const Center(
                              child:
                                  CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                if (!_formKey
                                    .currentState!
                                    .validate()) {
                                  return;
                                }

                                context
                                    .read<AuthCubit>()
                                    .login(
                                      _usernameController
                                          .text
                                          .trim(),
                                      _passwordController
                                          .text,
                                    );
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}