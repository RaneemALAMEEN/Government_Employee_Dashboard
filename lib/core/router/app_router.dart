import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/internal_transaction_form/internal_transaction_form_bloc.dart';
import 'package:government_employee_dashboard/features/internal_transactions/presentation/bloc/internal_transaction_form/internal_transaction_form_event.dart';
import '../../features/internal_transactions/presentation/bloc/create_internal_transaction/create_internal_transaction_bloc.dart';
import '../../features/internal_transactions/presentation/bloc/create_internal_transaction/create_internal_transaction_event.dart';
import '../../features/internal_transactions/presentation/bloc/internal_transaction_first_stage/internal_transaction_first_stage_bloc.dart';
import '../../features/internal_transactions/presentation/bloc/internal_transaction_first_stage/internal_transaction_first_stage_event.dart';
import '../di/injection.dart';
import '../../features/internal_transactions/presentation/bloc/internal_transactions_bloc.dart';
import '../../features/internal_transactions/presentation/bloc/internal_transactions_event.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/internal_transactions/presentation/pages/internal_transaction_first_stage_page.dart';
import '../../features/department_transactions/presentation/pages/department_transactions_page.dart';
import '../../features/department_transactions/presentation/pages/department_transaction_details_page.dart';
import '../../features/directorate_process_management/presentation/bloc/directorate_process_bloc.dart';
import '../../features/directorate_process_management/presentation/bloc/directorate_process_event.dart';
import '../../features/directorate_process_management/presentation/bloc/directorate_complaints_bloc.dart';
import '../../features/directorate_process_management/presentation/pages/directorate_process_management_page.dart';
import '../../features/directorate_process_management/presentation/bloc/process_details_bloc.dart';
import '../../features/directorate_process_management/presentation/bloc/process_details_event.dart';
import '../../features/directorate_process_management/presentation/pages/process_details_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/statistics/presentation/pages/statistics_employee_details_page.dart';
import '../../features/statistics/presentation/bloc/statistics_employee_details_bloc.dart';
import '../../features/statistics/presentation/bloc/statistics_employee_details_event.dart';
import '../../features/my_transactions/presentation/pages/my_transactions_page.dart';
import '../../features/my_transactions/presentation/pages/transaction_details_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/internal_transactions/presentation/pages/internal_transactions_page.dart';
import '../../features/internal_transactions/presentation/pages/create_internal_transaction_page.dart';
import '../../features/internal_transactions/presentation/pages/internal_transaction_form_page.dart';
import '../../shared/layouts/app_shell.dart';
import '../../shared/pages/coming_soon_page.dart';

import '../../features/organization_hierarchy/presentation/pages/organization_hierarchy_page.dart';
import '../../features/document_verification/presentation/bloc/document_verification_bloc.dart';
import '../../features/document_verification/presentation/pages/document_verification_page.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_event.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routerNeglect: true,
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: SplashPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: LoginPage(),
        ),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final sessionId = state.extra as String?;

          if (sessionId == null || sessionId.isEmpty) {
            return const NoTransitionPage(child: LoginPage());
          }

          return NoTransitionPage(
            child: OtpPage(sessionId: sessionId),
          );
        },
      ),
      ShellRoute(
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: BlocProvider(
              create: (_) =>
                  getIt<NotificationsBloc>()..add(const LoadNotifications()),
              child: AppShell(child: child),
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationsPage(),
            ),
          ),
          GoRoute(
            path: '/my-transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyTransactionsPage(),
            ),
          ),
          GoRoute(
            path: '/my-transactions/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final status = state.extra as String?;
              return NoTransitionPage(
                child:
                    TransactionDetailsPage(transactionId: id, status: status),
              );
            },
          ),
          GoRoute(
            path: '/internal-transactions',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<InternalTransactionsBloc>()
                  ..add(const LoadInternalTransactionsOverview()),
                child: const InternalTransactionsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/internal-transactions/:id/first-stage',
            pageBuilder: (context, state) {
              final transactionId =
                  int.tryParse(state.pathParameters['id'] ?? '') ?? 0;

              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => getIt<InternalTransactionFirstStageBloc>()
                    ..add(LoadInternalTransactionFirstStage(transactionId)),
                  child: InternalTransactionFirstStagePage(
                    transactionId: transactionId,
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/create-internal-transaction',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<CreateInternalTransactionBloc>()
                  ..add(const LoadCreateInternalTransactionData()),
                child: const CreateInternalTransactionPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/internal-transaction-form',
            pageBuilder: (context, state) {
              final processId = state.extra as int? ?? 0;

              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => getIt<InternalTransactionFormBloc>()
                    ..add(LoadInternalTransactionForm(processId)),
                  child: InternalTransactionFormPage(processId: processId),
                ),
              );
            },
          ),
          GoRoute(
            path: '/department-transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DepartmentTransactionsPage(),
            ),
          ),
          GoRoute(
            path: '/department-transaction-details/:id',
            pageBuilder: (context, state) {
              final transactionId = state.pathParameters['id'] ?? '';
              return NoTransitionPage(
                child: DepartmentTransactionDetailsPage(
                  transactionId: transactionId,
                ),
              );
            },
          ),
          GoRoute(
            path: '/directorate-process-management',
            pageBuilder: (context, state) => CustomTransitionPage(
              transitionDuration: const Duration(milliseconds: 260),
              child: MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (_) => getIt<DirectorateProcessBloc>()
                      ..add(const LoadTransactionTypes()),
                  ),
                  BlocProvider(
                    create: (_) => getIt<DirectorateComplaintsBloc>(),
                  ),
                ],
                child: const DirectorateProcessManagementPage(),
              ),
              transitionsBuilder: (context, animation, secondary, child) =>
                  FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
                child: child,
              ),
            ),
          ),
          GoRoute(
            path: '/directorate-process-management/process/:processId',
            pageBuilder: (context, state) {
              final processId =
                  int.tryParse(state.pathParameters['processId'] ?? '') ?? 0;
              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => getIt<ProcessDetailsBloc>()
                    ..add(LoadProcessDetails(processId: processId)),
                  child: ProcessDetailsPage(processId: processId),
                ),
              );
            },
          ),
          GoRoute(
            path: '/drafts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(title: 'مسوداتي'),
            ),
          ),
          GoRoute(
            path: '/statistics',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: StatisticsPage(),
            ),
          ),
          GoRoute(
            path: '/statistics/employees/:employeeId',
            pageBuilder: (context, state) {
              final employeeId =
                  int.tryParse(state.pathParameters['employeeId'] ?? '') ?? 0;
              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => getIt<StatisticsEmployeeDetailsBloc>()
                    ..add(LoadEmployeeDetails(employeeId: employeeId)),
                  child: StatisticsEmployeeDetailsPage(
                    employeeId: employeeId,
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/complaints',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(title: 'الشكاوى'),
            ),
          ),
          GoRoute(
            path: '/document-quality-checker',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<DocumentVerificationBloc>(),
                child: const DocumentVerificationPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/organization-hierarchy',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OrganizationHierarchyPage(),
            ),
          ),
        ],
      ),
    ],
  );
}
