import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/department_transactions/presentation/pages/department_transactions_page.dart';
import '../../features/employees/presentation/pages/employee_detail_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/my_transactions/presentation/pages/my_transactions_page.dart';
import '../../features/my_transactions/presentation/pages/transaction_details_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/internal_transactions/presentation/pages/internal_transactions_page.dart';
import '../../features/internal_transactions/presentation/pages/create_internal_transaction_page.dart';
import '../../features/internal_transactions/presentation/pages/internal_transaction_form_page.dart';
import '../../shared/layouts/app_shell.dart';
import '../../shared/pages/coming_soon_page.dart';
import '../../features/document_quality_checker/presentation/pages/document_quality_checker_page.dart';

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
            child: AppShell(child: child),
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
            path: '/my-transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MyTransactionsPage(),
            ),
          ),
          GoRoute(
            path: '/my-transactions/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return NoTransitionPage(
                child: TransactionDetailsPage(transactionId: id),
              );
            },
          ),
          GoRoute(
            path: '/internal-transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: InternalTransactionsPage(),
            ),
          ),
          GoRoute(
            path: '/create-internal-transaction',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CreateInternalTransactionPage(),
            ),
          ),
          GoRoute(
            path: '/internal-transaction-form',
            pageBuilder: (context, state) {
              final processId = state.extra as int? ?? 0;
              return NoTransitionPage(
                child: InternalTransactionFormPage(processId: processId),
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
            path: '/drafts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ComingSoonPage(title: 'مسوداتي'),
            ),
          ),
          GoRoute(
            path: '/employees',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: EmployeesPage(),
            ),
          ),
          GoRoute(
            path: '/employees/:id',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              return NoTransitionPage(
                child: EmployeeDetailPage(employeeId: id),
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
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DocumentQualityCheckerPage(),
            ),
          ),
        ],
      ),
    ],
  );
}

