// features/settings/domain/entities/settings_entity.dart

class AppSettingsEntity {
  final bool demoMode;
  final String apiBaseUrl;
  final int connectTimeout;
  final int receiveTimeout;
  final String theme;
  final String language;
  final String currency;
  final NotificationSettingsEntity notifications;

  const AppSettingsEntity({
    this.demoMode = true,
    this.apiBaseUrl = 'https://snacky-api.vercel.app/api',
    this.connectTimeout = 30000,
    this.receiveTimeout = 30000,
    this.theme = 'light',
    this.language = 'fr',
    this.currency = 'F CFA',
    this.notifications = const NotificationSettingsEntity(),
  });

  AppSettingsEntity copyWith({
    bool? demoMode,
    String? apiBaseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    String? theme,
    String? language,
    String? currency,
    NotificationSettingsEntity? notifications,
  }) {
    return AppSettingsEntity(
      demoMode: demoMode ?? this.demoMode,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationSettingsEntity {
  final bool newOrder;
  final bool pendingOrder;
  final bool cancelledOrder;
  final bool lowStock;
  final bool newProduct;

  const NotificationSettingsEntity({
    this.newOrder = true,
    this.pendingOrder = true,
    this.cancelledOrder = false,
    this.lowStock = true,
    this.newProduct = false,
  });

  // ✅ toJson() défini ici dans l'entité — accessible partout sans cast
  Map<String, dynamic> toJson() => {
    'newOrder': newOrder,
    'pendingOrder': pendingOrder,
    'cancelledOrder': cancelledOrder,
    'lowStock': lowStock,
    'newProduct': newProduct,
  };

  NotificationSettingsEntity copyWith({
    bool? newOrder,
    bool? pendingOrder,
    bool? cancelledOrder,
    bool? lowStock,
    bool? newProduct,
  }) {
    return NotificationSettingsEntity(
      newOrder: newOrder ?? this.newOrder,
      pendingOrder: pendingOrder ?? this.pendingOrder,
      cancelledOrder: cancelledOrder ?? this.cancelledOrder,
      lowStock: lowStock ?? this.lowStock,
      newProduct: newProduct ?? this.newProduct,
    );
  }
}

class AdminProfileEntity {
  final String id;
  final String nom;
  final String email;
  final String role;
  final String? telephone;

  const AdminProfileEntity({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    this.telephone,
  });

  AdminProfileEntity copyWith({
    String? id,
    String? nom,
    String? email,
    String? role,
    String? telephone,
  }) {
    return AdminProfileEntity(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      email: email ?? this.email,
      role: role ?? this.role,
      telephone: telephone ?? this.telephone,
    );
  }
}

class ConnectionStatusEntity {
  final bool isOnline;
  final int? pingMs;
  final DateTime? lastChecked;

  const ConnectionStatusEntity({
    this.isOnline = false,
    this.pingMs,
    this.lastChecked,
  });
}