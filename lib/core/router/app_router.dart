import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:government_employee_dashboard/features/auth/presentation/pages/app_pin_unlock_page.dart';
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
import '../../features/internal_transactions/domain/entities/internal_transaction_entity.dart';
import '../../features/department_transactions/presentation/pages/department_transactions_page.dart';
import '../../features/department_transactions/presentation/pages/department_transaction_details_page.dart';
import '../../features/department_transactions/presentation/pages/generate_final_document_page.dart';

import '../../features/directorate_process_management/presentation/bloc/directorate_process_bloc.dart';
import '../../features/directorate_process_management/presentation/bloc/directorate_process_event.dart';
import '../../features/directorate_process_management/presentation/bloc/directorate_complaints_bloc.dart';
import '../../features/directorate_process_management/presentation/pages/directorate_process_management_page.dart';
import '../../features/directorate_process_management/presentation/bloc/process_details_bloc.dart';
import '../../features/directorate_process_management/presentation/bloc/process_details_event.dart';
import '../../features/directorate_process_management/presentation/pages/process_details_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/statistics/presentation/pages/statistics_employee_details_page.dart';
import '../../features/statistics/presentation/bloc/statistics_employee_details_bloc.dart';
import '../../features/statistics/presentation/bloc/statistics_employee_details_event.dart';
import '../../features/my_transactions/presentation/pages/my_transactions_page.dart';
import '../../features/my_transactions/presentation/pages/transaction_details_page.dart';
import '../../features/my_transactions/presentation/pages/pdf_viewer_page.dart';
import '../../features/my_transactions/presentation/pages/image_viewer_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/internal_transactions/presentation/pages/internal_transactions_page.dart';
import '../../features/internal_transactions/presentation/pages/create_internal_transaction_page.dart';
import '../../features/internal_transactions/presentation/pages/internal_transaction_form_page.dart';
import '../../shared/layouts/app_shell.dart';
import '../../shared/pages/coming_soon_page.dart';

import '../../features/organization_hierarchy/presentation/pages/organization_hierarchy_page.dart';
import '../../features/document_verification/presentation/bloc/document_verification_bloc.dart';
import '../../features/document_verification/presentation/pages/document_verification_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/notifications/presentation/widgets/authenticated_notifications_scope.dart';
import '../../features/appointments/presentation/bloc/appointments_bloc.dart';
import '../../features/appointments/presentation/pages/appointments_page.dart';
import '../../features/self_cards/presentation/bloc/self_cards_bloc.dart';
import '../../features/self_cards/presentation/bloc/self_cards_event.dart';
import '../../features/self_cards/presentation/pages/self_cards_page.dart';

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
        path: '/pin-unlock',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: AppPinUnlockPage(),
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
            child: AuthenticatedNotificationsScope(
              child: AppShell(child: child),
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            redirect: (_, __) => '/my-transactions',
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotificationsPage(),
            ),
          ),
          GoRoute(
            path: '/appointments',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<AppointmentsBloc>()
                  ..add(const LoadAvailableAppointmentSlots()),
                child: const AppointmentsPage(),
              ),
            ),
          ),
          GoRoute(
            path: '/self-cards',
            pageBuilder: (context, state) => NoTransitionPage(
              child: BlocProvider(
                create: (_) => getIt<SelfCardsBloc>()
                  ..add(const SearchSelfCardsEvent(query: '')),
                child: const SelfCardsPage(),
              ),
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
              String? status;
              String? numericTxId;
              if (state.extra is String) {
                status = state.extra as String;
              } else if (state.extra is Map) {
                final extraMap = state.extra as Map;
                status = extraMap['status'] as String?;
                numericTxId = extraMap['transaction_id']?.toString() ??
                    extraMap['numeric_transaction_id']?.toString();
              }
              return NoTransitionPage(
                child: TransactionDetailsPage(
                  transactionId: id,
                  status: status,
                  numericTransactionId: numericTxId,
                ),
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
              final transaction = state.extra is InternalTransactionEntity
                  ? state.extra as InternalTransactionEntity
                  : null;

              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => getIt<InternalTransactionFirstStageBloc>()
                    ..add(LoadInternalTransactionFirstStage(transactionId)),
                  child: InternalTransactionFirstStagePage(
                    transactionId: transactionId,
                    transaction: transaction,
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
            path: '/internal-transaction-form/:processId',
            pageBuilder: (context, state) {
              final processId =
                  int.tryParse(state.pathParameters['processId'] ?? '') ?? 0;
              final extra = state.extra is Map
                  ? Map<String, dynamic>.from(state.extra as Map)
                  : const <String, dynamic>{};
              final parsedStageCount =
                  int.tryParse(extra['stageCount']?.toString() ?? '');

              return NoTransitionPage(
                child: BlocProvider(
                  create: (_) => getIt<InternalTransactionFormBloc>()
                    ..add(LoadInternalTransactionForm(processId)),
                  child: InternalTransactionFormPage(
                    processId: processId,
                    initialProcessName: extra['processName']?.toString(),
                    stageCount: parsedStageCount != null && parsedStageCount > 0
                        ? parsedStageCount
                        : null,
                  ),
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
            path: '/department-transaction-details/:id/generate-final-document',
            pageBuilder: (context, state) {
              final transactionId =
                  int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return NoTransitionPage(
                child: GenerateFinalDocumentPage(
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
          GoRoute(
            path: '/pdf-viewer',
            pageBuilder: (context, state) {
              String fileUrl = '';
              String title = 'عرض الوثيقة';
              bool readOnly = true;
              if (state.extra is String) {
                fileUrl = state.extra as String;
              } else if (state.extra is Map<String, dynamic>) {
                final map = state.extra as Map<String, dynamic>;
                fileUrl =
                    map['fileUrl']?.toString() ?? map['url']?.toString() ?? '';
                title = map['title']?.toString() ?? 'عرض الوثيقة';
                readOnly = map['readOnly'] ?? true;
              }
              return NoTransitionPage(
                child: PdfViewerPage(
                  fileUrl: fileUrl,
                  title: title,
                  readOnly: readOnly,
                ),
              );
            },
          ),
          GoRoute(
            path: '/image-viewer',
            pageBuilder: (context, state) {
              String fileUrl = '';
              String title = 'عرض الصورة';
              if (state.extra is String) {
                fileUrl = state.extra as String;
              } else if (state.extra is Map<String, dynamic>) {
                final map = state.extra as Map<String, dynamic>;
                fileUrl =
                    map['fileUrl']?.toString() ?? map['url']?.toString() ?? '';
                title = map['title']?.toString() ?? 'عرض الصورة';
              }
              return NoTransitionPage(
                child: ImageViewerPage(
                  fileUrl: fileUrl,
                  title: title,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
