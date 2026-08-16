import '../../services/session_service.dart';

/// Handles user isolation for client-side caching.
///
/// Ensures every user's cached data is stored with a user-scoped prefix and
/// prevents data leaks between multiple users logged into the same desktop app.
class UserScopeService {
  final SessionService _sessionService;

  UserScopeService(this._sessionService);

  /// Resolves the current logged-in user's ID as a String prefix.
  String getCurrentUserId() {
    final user = _sessionService.currentUserNotifier.value;
    if (user != null && user.id > 0) {
      return user.id.toString();
    }
    return 'guest';
  }

  /// Builds a user-isolated cache key (e.g. `user_42:my_transactions_page_1`).
  String buildScopedKey(String baseKey) {
    final userId = getCurrentUserId();
    return 'user_$userId:$baseKey';
  }

  /// Checks if a scoped key belongs to the currently logged-in user.
  bool belongsToCurrentUser(String scopedKey) {
    final currentUserId = getCurrentUserId();
    return scopedKey.startsWith('user_$currentUserId:');
  }
}
