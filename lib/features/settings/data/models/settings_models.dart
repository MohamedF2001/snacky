// features/settings/data/models/settings_model.dart

import '../../domain/entities/settings_entity.dart';

class NotificationSettingsModel extends NotificationSettingsEntity {
  const NotificationSettingsModel({
    super.newOrder = true,
    super.pendingOrder = true,
    super.cancelledOrder = false,
    super.lowStock = true,
    super.newProduct = false,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      newOrder: json['newOrder'] as bool? ?? true,
      pendingOrder: json['pendingOrder'] as bool? ?? true,
      cancelledOrder: json['cancelledOrder'] as bool? ?? false,
      lowStock: json['lowStock'] as bool? ?? true,
      newProduct: json['newProduct'] as bool? ?? false,
    );
  }

  // ✅ toJson() hérité de NotificationSettingsEntity — pas besoin de le redéfinir ici
  // On le garde en override explicite pour clarté, mais c'est optionnel
  @override
  Map<String, dynamic> toJson() => {
    'newOrder': newOrder,
    'pendingOrder': pendingOrder,
    'cancelledOrder': cancelledOrder,
    'lowStock': lowStock,
    'newProduct': newProduct,
  };
}

class AppSettingsModel extends AppSettingsEntity {
  const AppSettingsModel({
    super.demoMode = true,
    super.apiBaseUrl = 'https://snacky-api.vercel.app/api',
    super.connectTimeout = 30000,
    super.receiveTimeout = 30000,
    super.theme = 'light',
    super.language = 'fr',
    super.currency = 'F CFA',
    super.notifications = const NotificationSettingsModel(),
  });

  @override
  AppSettingsModel copyWith({
    bool? demoMode,
    String? apiBaseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    String? theme,
    String? language,
    String? currency,
    NotificationSettingsEntity? notifications,
  }) {
    return AppSettingsModel(
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

class AdminProfileModel extends AdminProfileEntity {
  const AdminProfileModel({
    required super.id,
    required super.nom,
    required super.email,
    required super.role,
    super.telephone,
  });

  factory AdminProfileModel.fromSharedPrefs({
    required String id,
    required String nom,
    required String email,
    required String role,
    String? telephone,
  }) {
    return AdminProfileModel(
      id: id,
      nom: nom,
      email: email,
      role: role,
      telephone: telephone,
    );
  }
}

class ConnectionStatusModel extends ConnectionStatusEntity {
  const ConnectionStatusModel({
    super.isOnline = false,
    super.pingMs,
    super.lastChecked,
  });
}