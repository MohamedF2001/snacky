// features/settings/data/datasources/settings_local_data_source.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_models.dart';


class SettingsLocalDataSource {
  static const _keyDemoMode = 'settings_demo_mode';
  static const _keyApiBaseUrl = 'settings_api_base_url';
  static const _keyConnectTimeout = 'settings_connect_timeout';
  static const _keyReceiveTimeout = 'settings_receive_timeout';
  static const _keyTheme = 'settings_theme';
  static const _keyLanguage = 'settings_language';
  static const _keyCurrency = 'settings_currency';
  static const _keyNotifications = 'settings_notifications';
  static const _keyLoginHistory = 'settings_login_history';

  Future<AppSettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    NotificationSettingsModel notifications = const NotificationSettingsModel();
    final notifJson = prefs.getString(_keyNotifications);
    if (notifJson != null) {
      try {
        notifications = NotificationSettingsModel.fromJson(
          jsonDecode(notifJson) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    return AppSettingsModel(
      demoMode: prefs.getBool(_keyDemoMode) ?? true,
      apiBaseUrl: prefs.getString(_keyApiBaseUrl) ??
          'https://snacky-api.vercel.app/api',
      connectTimeout: prefs.getInt(_keyConnectTimeout) ?? 30000,
      receiveTimeout: prefs.getInt(_keyReceiveTimeout) ?? 30000,
      theme: prefs.getString(_keyTheme) ?? 'light',
      language: prefs.getString(_keyLanguage) ?? 'fr',
      currency: prefs.getString(_keyCurrency) ?? 'F CFA',
      notifications: notifications,
    );
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDemoMode, settings.demoMode);
    await prefs.setString(_keyApiBaseUrl, settings.apiBaseUrl);
    await prefs.setInt(_keyConnectTimeout, settings.connectTimeout);
    await prefs.setInt(_keyReceiveTimeout, settings.receiveTimeout);
    await prefs.setString(_keyTheme, settings.theme);
    await prefs.setString(_keyLanguage, settings.language);
    await prefs.setString(_keyCurrency, settings.currency);
    await prefs.setString(
      _keyNotifications,
      jsonEncode(settings.notifications.toJson()),
    );
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    // On garde le token et les infos user, on vide le reste
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    final userEmail = prefs.getString('userEmail');
    final userName = prefs.getString('userName');
    final userRole = prefs.getString('userRole');

    await prefs.clear();

    // Restore auth data
    if (token != null) await prefs.setString('token', token);
    if (userId != null) await prefs.setString('userId', userId);
    if (userEmail != null) await prefs.setString('userEmail', userEmail);
    if (userName != null) await prefs.setString('userName', userName);
    if (userRole != null) await prefs.setString('userRole', userRole);
  }

  Future<void> recordLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_keyLoginHistory);
    List<Map<String, dynamic>> history = [];

    if (historyJson != null) {
      try {
        final decoded = jsonDecode(historyJson) as List;
        history = decoded.cast<Map<String, dynamic>>();
      } catch (_) {}
    }

    history.insert(0, {
      'date': DateTime.now().toIso8601String(),
      'device': 'Flutter Web/Mobile',
    });

    // Garder les 10 dernières connexions
    if (history.length > 10) history = history.sublist(0, 10);

    await prefs.setString(_keyLoginHistory, jsonEncode(history));
  }

  Future<List<Map<String, dynamic>>> getLoginHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_keyLoginHistory);
    if (historyJson == null) return [];
    try {
      final decoded = jsonDecode(historyJson) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}