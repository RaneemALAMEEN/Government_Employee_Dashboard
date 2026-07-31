import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/push_socket.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';

/// Owns the single notifications state and WebSocket listener for an
/// authenticated shell session.
class AuthenticatedNotificationsScope extends StatefulWidget {
  final Widget child;

  const AuthenticatedNotificationsScope({
    super.key,
    required this.child,
  });

  @override
  State<AuthenticatedNotificationsScope> createState() =>
      _AuthenticatedNotificationsScopeState();
}

class _AuthenticatedNotificationsScopeState
    extends State<AuthenticatedNotificationsScope> with WidgetsBindingObserver {
  late final NotificationsBloc _bloc;
  late final PushSocket _pushSocket;
  StreamSubscription<PushMessage>? _pushSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = getIt<NotificationsBloc>()
      ..add(const LoadNotifications())
      ..add(const StartNotificationsMonitoring());
    _pushSocket = getIt<PushSocket>();
    _pushSubscription = _pushSocket.messages.listen((_) {
      _bloc.add(const RefreshUnreadCount(syncLatestNotification: true));
    });
    unawaited(_pushSocket.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bloc.add(const RefreshUnreadCount());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bloc.add(const StopNotificationsMonitoring());
    unawaited(_pushSubscription?.cancel());
    unawaited(_pushSocket.dispose());
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: widget.child,
    );
  }
}
