import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
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
import 'shared/theme/app_theme.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    // Bypass SSL certificate validation globally
    client.badCertificateCallback = (cert, host, port) => true;
    
    // Bypass Windows IPv6 host lookup failure (WSANO_DATA 11004) by forcing IPv4 resolution
    client.connectionFactory = (Uri uri, String? proxyHost, int? proxyPort) async {
      final host = proxyHost ?? uri.host;
      final port = proxyPort ?? uri.port;
      
      Future<Socket> socketFuture;
      try {
        final addresses = await InternetAddress.lookup(host, type: InternetAddressType.IPv4);
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


Future<void> main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();


  await dotenv.load(fileName: "env/dev.env");

  await setupCoreInjection();
  await setupAuthInjection();
  await setupDashboardInjection();
  await setupMyTransactionsInjection();
  await setupDepartmentTransactionsInjection();
  await setupEmployeesInjection();

  runApp(const GovernmentEmployeeApp());
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
          create: (_) => getIt<DeptTxBloc>()..add(LoadDeptTx()),
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
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          );
        },
        routerConfig: AppRouter.router,
      ),
    );
  }
}
