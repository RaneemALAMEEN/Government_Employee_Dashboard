import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';

class SessionService {
  final SecureStorageService _storage;
  final ValueNotifier<String> activeRoleNotifier = ValueNotifier<String>('رئيس الدائرة');

  SessionService(this._storage) {
    _init();
  }

  Future<void> _init() async {
    try {
      final role = await _storage.readRole() ?? 'رئيس الدائرة';
      activeRoleNotifier.value = role;
    } catch (_) {
      activeRoleNotifier.value = 'رئيس الدائرة';
    }
  }

  Future<void> setActiveRole(String role) async {
    activeRoleNotifier.value = role;
    try {
      await _storage.writeRole(role);
    } catch (_) {}
  }

  void cycleRole() {
    final current = activeRoleNotifier.value;
    String next;
    if (current == 'رئيس الدائرة') {
      next = 'مدير التربية';
    } else if (current == 'مدير التربية') {
      next = 'معاون مدير التربية';
    } else {
      next = 'رئيس الدائرة';
    }
    setActiveRole(next);
  }
}
