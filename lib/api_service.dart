import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://fakestoreapi.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  String? _authToken;

  ApiService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          return handler.next(options);
        },
      ),
    );
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      _authToken = response.data['token'];

      return _authToken != null;
    } on DioException {
      return false;
    }
  }

  Future<List<dynamic>> getProducts() async {
    final response = await _dio.get('/products');

    return response.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> updateProduct(
    int id,
    String title,
    double price,
  ) async {
    final response = await _dio.put(
      '/products/$id',
      data: {
        'title': title,
        'price': price,
      },
    );

    return Map<String, dynamic>.from(response.data);
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete('/products/$id');
  }

  void logout() {
    _authToken = null;
  }
}