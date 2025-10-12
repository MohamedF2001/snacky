// core/config/app_config.dart

class AppConfig {
  //static const String baseUrl = 'https://snacky-api.vercel.app/api';
  static String baseUrl =
      'https://corsproxy.io/?${Uri.encodeFull('https://snacky-api.vercel.app/api')}';

  static const int connectTimeout = 30000; // Augmentez le timeout
  static const int receiveTimeout = 30000;
}
