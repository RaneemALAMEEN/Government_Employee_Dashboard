import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/push_socket.dart';
import 'core/services/tray_service.dart';
import 'features/auth/di/injection.dart';
import 'features/dashboard/di/injection.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_event.dart';
import 'features/department_transactions/di/injection.dart';
import 'features/department_transactions/presentation/bloc/dept_tx_bloc.dart';
import 'features/department_transactions/presentation/bloc/dept_tx_event.dart';
import 'features/employees/di/injection.dart';
import 'features/employees/presentation/bloc/employees_bloc.dart';
import 'features/employees/presentation/bloc/employees_event.dart';
import 'features/my_transactions/di/injection.dart';
import 'features/my_transactions/presentation/bloc/my_transactions_bloc.dart';
import 'features/my_transactions/presentation/bloc/my_transactions_event.dart';
import 'features/statistics/di/injection.dart';
import 'shared/theme/app_theme.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // Bypass SSL certificate validation globally
    client.badCertificateCallback = (cert, host, port) => true;

    // Bypass Windows IPv6 host lookup failure (WSANO_DATA 11004) by forcing IPv4 resolution
    client.connectionFactory =
        (Uri uri, String? proxyHost, int? proxyPort) async {
      final host = proxyHost ?? uri.host;
      final port = proxyPort ?? uri.port;

      Future<Socket> socketFuture;
      try {
        final addresses =
            await InternetAddress.lookup(host, type: InternetAddressType.IPv4);
        if (addresses.isNotEmpty) {
          socketFuture = Socket.connect(addresses.first, port);
        } else {
          socketFuture = Socket.connect(host, port);
        }
      } catch (_) {
        socketFuture = Socket.connect(host, port);
      }

      if (uri.scheme == 'https') {
        final secureSocketFuture = socketFuture.then((socket) {
          return SecureSocket.secure(
            socket,
            host: host,
            onBadCertificate: (cert) => true,
          );
        });
        return ConnectionTask.fromSocket(secureSocketFuture, () {});
      }

      return ConnectionTask.fromSocket(socketFuture, () {});
    };
    return client;
  }
}

/// `true` على منصّات سطح المكتب التي ندعم عليها الإشعارات والـ tray.
bool get _isDesktop =>
    !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة نافذة سطح المكتب يجب أن تسبق runApp وبعد ensureInitialized مباشرةً.
  // النافذة تُنشأ مخفية ثم تُظهَر داخل waitUntilReadyToShow.
  if (_isDesktop) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(1100, 680),
      center: true,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  await dotenv.load(fileName: "env/dev.env");

  await setupCoreInjection();
  await setupAuthInjection();
  await setupDashboardInjection();
  await setupMyTransactionsInjection();
  await setupDepartmentTransactionsInjection();
  await setupEmployeesInjection();
  await setupStatisticsInjection();

  // ترتيب طبقات الإشعارات: (1) تهيئة العرض → (2) شريط النظام واعتراض الإغلاق
  // → (3) فتح اتصال الـ socket. الاتصال يبقى حيًّا في الـ tray عند "إغلاق"
  // النافذة، فتصل الإشعارات حتى وقتها.
  await NotificationService.instance.init(
    onSelect: (payload) {
      // TODO(routing): اربط الـ payload بمنطق التنقّل (go_router) عند الضغط
      // على الإشعار. مثال: فكّ JSON واستخرج المسار ثم AppRouter.router.go(...).
      debugPrint('[Notification] tapped, payload: $payload');
    },
  );
  if (_isDesktop) {
    await TrayService.instance.init();
  }
  // يبدأ الاتصال؛ يعيد المحاولة تلقائيًّا. قبل تسجيل الدخول لا يوجد توكن فيرفضه
  // الخادم، ثم يتعافى ذاتيًّا (إعادة محاولة كل 60ث) ويلتقط التوكن بعد الدخول.
  await getIt<PushSocket>().start();

  runApp(const GovernmentEmployeeApp());

  if (_isDesktop) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 250), () async {
        await windowManager.setMinimumSize(const Size(1100, 680));
        final isMaximized = await windowManager.isMaximized();
        if (!isMaximized) {
          await windowManager.maximize();
        }
        await windowManager.focus();
      });
    });
  }
}

class GovernmentEmployeeApp extends StatelessWidget {
  const GovernmentEmployeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (_) => getIt<DashboardBloc>()..add(LoadDashboardEvent()),
        ),
        BlocProvider<MyTransactionsBloc>(
          create: (_) => getIt<MyTransactionsBloc>()..add(LoadMyTransactions()),
        ),
        BlocProvider<DeptTxBloc>(
          create: (_) => getIt<DeptTxBloc>()..add(const LoadDeptTx()),
        ),
        BlocProvider<EmployeesBloc>(
          create: (_) => getIt<EmployeesBloc>()..add(const LoadEmployees()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: dotenv.env['APP_NAME'] ?? 'Employee Dashboard',
        theme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          final app = Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
          // على سطح المكتب نغلّف التطبيق بـ TrayBootstrap: يعترض زر الإغلاق
          // (إخفاء إلى الـ tray) ويدير قائمة شريط النظام، ويُغلق الـ socket عند
          // الخروج النهائي. يبقى حيًّا طوال الجلسة (لا يُعاد بناؤه عند التنقّل).
          if (!_isDesktop) return app;
          return TrayBootstrap(
            onBeforeExit: () => getIt<PushSocket>().dispose(),
            child: app,
          );
        },
        routerConfig: AppRouter.router,
      ),
    );
  }
}
