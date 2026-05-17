import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
    _dio.interceptors.add(_UnwrapInterceptor());
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async =>
      _handleRequest(() => _dio.get(path, queryParameters: params));

  Future<Response> post(String path, {dynamic data}) async =>
      _handleRequest(() => _dio.post(path, data: data));

  Future<Response> put(String path, {dynamic data}) async =>
      _handleRequest(() => _dio.put(path, data: data));

  Future<Response> delete(String path) async =>
      _handleRequest(() => _dio.delete(path));

  Future<Response> upload(String path, FormData formData) async =>
      _handleRequest(() => _dio.post(path, data: formData));

  Future<Response> _handleRequest(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          throw NetworkException('Connection timed out');
        case DioExceptionType.connectionError:
          throw NetworkException();
        default:
          final code = e.response?.statusCode;
          final msg = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
          if (code == 401) throw AuthException(msg);
          if (code == 404) throw NotFoundException(msg);
          throw ServerException(msg, code);
      }
    }
  }
}

// Unwraps the { success, data } envelope from every backend response.
class _UnwrapInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final body = response.data;
    if (body is Map<String, dynamic> && body.containsKey('data')) {
      response.data = body['data'];
    }
    handler.next(response);
  }
}

class _AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read(key: AppConstants.jwtKey);
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _storage.read(key: AppConstants.refreshKey);
      if (refreshToken != null) {
        try {
          final res = await _dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
          final newToken = res.data['token'];
          await _storage.write(key: AppConstants.jwtKey, value: newToken);
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retry = await _dio.fetch(err.requestOptions);
          return handler.resolve(retry);
        } catch (_) {
          await _storage.deleteAll();
        }
      }
    }
    handler.next(err);
  }
}
