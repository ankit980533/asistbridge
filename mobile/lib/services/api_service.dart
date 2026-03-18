import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final _storage = const FlutterSecureStorage();
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        return handler.next(error);
      },
    ));
  }
  
  // Retry wrapper for important requests
  Future<Response> _retryRequest(Future<Response> Function() request, {int retries = 2}) async {
    for (int i = 0; i <= retries; i++) {
      try {
        return await request();
      } on DioException catch (e) {
        if (i == retries) rethrow;
        // Wait before retry (exponential backoff)
        await Future.delayed(Duration(seconds: (i + 1) * 2));
      }
    }
    throw Exception('Request failed after retries');
  }
  
  Future<void> setToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }
  
  Future<void> clearToken() async {
    await _storage.delete(key: 'token');
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }
  
  Future<Response> post(String path, {dynamic data, bool retry = true}) async {
    if (retry) {
      return await _retryRequest(() => _dio.post(path, data: data));
    }
    return await _dio.post(path, data: data);
  }
  
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }
  
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
