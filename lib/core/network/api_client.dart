import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snacky/core/config/app_config.dart';
import 'package:snacky/core/utils/app_logger.dart';

// core/network/api_client.dart

class ApiClient {
  final Dio _dio = Dio();

  ApiClient() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(
      milliseconds: AppConfig.connectTimeout,
    );
    _dio.options.receiveTimeout = const Duration(
      milliseconds: AppConfig.receiveTimeout,
    );

    // Ajouter des headers pour CORS
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    // _dio.options.headers['Access-Control-Allow-Origin'] = '*';
    // _dio.options.headers['Access-Control-Allow-Methods'] =
    //     'GET, POST, PUT, DELETE, OPTIONS';
    // _dio.options.headers['Access-Control-Allow-Headers'] =
    //     'Origin, Content-Type, Accept, Authorization, X-Requested-With';

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          logger.i('🌐 Making request to: ${options.uri}');
          logger.i('📝 Headers: ${options.headers}');
          logger.i('📦 Data: ${options.data}');

          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            logger.d('🔑 Adding auth token: $token');
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          logger.e(
            "❌ Dio error",
            error: {
              "message": error.message.toString(),
              "type": error.type.toString(),
              "statusCode": error.response?.statusCode,
              "data": error.response?.data,
            },
          );

          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            logger.d('🔒 Token removed due to 401 error');
          }
          return handler.next(error);
        },
        onResponse: (response, handler) {
          logger.d('✅ Response received: ${response.statusCode}');
          logger.d('✅ Response data: ${response.data}');
          return handler.next(response);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
