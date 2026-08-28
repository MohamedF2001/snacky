// core/config/app_config.dart

class AppConfig {
  // Version directe
  static const String baseUrl = 'https://snacky-api.vercel.app/api';
  
  // Note: Si vous développez sur Web, utilisez la commande --disable-web-security 
  // plutôt que des proxies qui cassent le Login (POST).

  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
