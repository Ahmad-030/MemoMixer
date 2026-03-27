// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDarkMode = 'mm_dark_mode';
const _kLastBackup = 'mm_last_backup';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  DateTime? _lastBackup;

  bool get isDarkMode => _isDarkMode;
  DateTime? get lastBackup => _lastBackup;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_kDarkMode) ?? false;
    final ts = prefs.getString(_kLastBackup);
    _lastBackup = ts != null ? DateTime.tryParse(ts) : null;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, _isDarkMode);
  }

  Future<void> markBackupTime() async {
    _lastBackup = DateTime.now();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastBackup, _lastBackup!.toIso8601String());
  }
}