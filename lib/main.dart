import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'api_service.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/products_cubit.dart';
import 'screens/login_screen.dart';

void main() {
  final apiService = ApiService();

  runApp(
    MyApp(
      apiService: apiService,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({
    super.key,
    required this.apiService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AuthCubit(apiService),
        ),

        BlocProvider(
          create: (_) =>
              ProductsCubit(apiService)
                ..loadProducts(),
        ),
      ],

      child: MaterialApp(
        title: 'Products App',

        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(
            seedColor: Colors.blue,
          ),

          useMaterial3: true,
        ),

        home: LoginScreen(),
      ),
    );
  }
}