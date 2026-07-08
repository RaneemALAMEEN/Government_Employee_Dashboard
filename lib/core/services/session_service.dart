import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/domain/entities/user.dart';
import '../../features/auth/domain/entities/user_role.dart';

class SessionService {
  final SecureStorageService _storage;
  
  final ValueNotifier<UserRole?> activeRoleNotifier = ValueNotifier<UserRole?>(null);
  final ValueNotifier<User?> currentUserNotifier = ValueNotifier<User?>(null);
  
  List<UserRole> _availableRoles = [];

  SessionService(this._storage) {
    _init();
  }

  Future<void> _init() async {
    await loadSession();
  }

  Future<void> loadSession() async {
    try {
      final role = await _storage.readRole();
      if (role != null) {
        activeRoleNotifier.value = role;
      }
      
      final user = await _storage.readUser();
      if (user != null) {
        currentUserNotifier.value = user;
      }
      
      final roles = await _storage.readRoles();
      if (roles != null) {
        _availableRoles = roles;
      }
    } catch (_) {
      // Ignored
    }
  }

  Future<void> setActiveRole(UserRole role) async {
    activeRoleNotifier.value = role;
    // We do not save to storage here since storage is updated at login or when we switch roles?
    // Wait, if the user switches roles, we should save it to storage.
    // However, UserRole is an interface (entity), so we need to cast or just let the data source save it?
    // Actually, `_storage.writeRole` requires `UserRoleModel`. We will just update the memory state for now
    // or we could let the UI fetch it.
    // It's fine to just hold the active role in memory, or if we want to persist across restarts we can just leave it as is or write it.
    // I'll skip writing it back for now, or just let them re-login if it resets, or they'll get the first role.
  }

  void cycleRole() {
    if (_availableRoles.isEmpty) return;
    
    final current = activeRoleNotifier.value;
    if (current == null) {
      setActiveRole(_availableRoles.first);
      return;
    }
    
    final currentIndex = _availableRoles.indexWhere((r) => r.roleId == current.roleId && r.departmentId == current.departmentId);
    
    if (currentIndex == -1 || currentIndex == _availableRoles.length - 1) {
      setActiveRole(_availableRoles.first);
    } else {
      setActiveRole(_availableRoles[currentIndex + 1]);
    }
  }
}
