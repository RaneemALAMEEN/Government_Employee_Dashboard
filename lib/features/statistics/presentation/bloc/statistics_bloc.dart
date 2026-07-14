import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/statistics_employee_entity.dart';
import '../../domain/entities/statistics_process_entity.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/usecases/get_department_employees_stats.dart';
import '../../domain/usecases/get_process_definition_stats.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetDepartmentEmployeesStats getDepartmentEmployeesStats;
  final GetProcessDefinitionStats getProcessDefinitionStats;

  StatisticsBloc({
    required this.getDepartmentEmployeesStats,
    required this.getProcessDefinitionStats,
  }) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
    on<RefreshStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
    StatisticsEvent event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());

    final departmentId = getIt<SessionService>().activeRoleNotifier.value?.departmentId;
    final departmentIds = departmentId != null ? [departmentId] : <int>[];

    final employeesResult = await getDepartmentEmployeesStats(departmentIds: departmentIds);
    final processesResult = await getProcessDefinitionStats(departmentIds: departmentIds);

    var isFallback = false;
    String? warningMessage;

    final employees = employeesResult.fold(
      (failure) {
        isFallback = true;
        warningMessage = failure.message;
        return _fallbackEmployees;
      },
      (items) => items,
    );

    final processes = processesResult.fold(
      (failure) {
        isFallback = true;
        warningMessage ??= failure.message;
        return _fallbackProcesses;
      },
      (items) => items,
    );

    emit(
      StatisticsLoaded(
        employees: employees,
        processes: processes,
        isFallback: isFallback,
        warningMessage: warningMessage,
      ),
    );
  }
}

const _fallbackEmployees = [
  StatisticsEmployeeEntity(
    id: 'EMP-2019-001',
    employeeId: null,
    assignmentId: 101,
    fullName: 'أحمد الحسن',
    departmentName: 'شعبة الموارد البشرية',
    roleName: 'موظف معاملات',
    pendingPickup: 6,
    inProgress: 2,
    activeTotal: 8,
    completed: 34,
    workloadPercent: 45,
    status: 'active',
    statusLabel: 'نشط',
  ),
  StatisticsEmployeeEntity(
    id: 'EMP-2020-012',
    employeeId: null,
    assignmentId: 102,
    fullName: 'سارة يعقوب',
    departmentName: 'شعبة الموارد البشرية',
    roleName: 'موظف معاملات',
    pendingPickup: 0,
    inProgress: 0,
    activeTotal: 0,
    completed: 12,
    workloadPercent: 0,
    status: 'inactive',
    statusLabel: 'غير نشط',
  ),
  StatisticsEmployeeEntity(
    id: 'EMP-2020-044',
    employeeId: null,
    assignmentId: 115,
    fullName: 'عمر الدرويش',
    departmentName: 'شعبة الأرشيف',
    roleName: 'مراجع',
    pendingPickup: 3,
    inProgress: 5,
    activeTotal: 8,
    completed: 67,
    workloadPercent: 72,
    status: 'overloaded',
    statusLabel: 'مثقل',
  ),
];

const _fallbackProcesses = [
  StatisticsProcessEntity(
    processDefinitionId: 5,
    processName: 'طلب إجازة سنوية',
    processCode: 'LEAVE_ANNUAL_V1',
    transactionTypeName: 'إجازة',
    transactionTypeCode: 'LEAVE',
    isActive: true,
    approvalStatus: 'APPROVED',
    pendingPickup: 4,
    inProgress: 12,
    completed: 156,
    rejected: 3,
    departments: [
      'شعبة الموارد البشرية',
      'دائرة الشؤون الإدارية',
    ],
  ),
  StatisticsProcessEntity(
    processDefinitionId: 8,
    processName: 'طلب شهادة حسن سيرة',
    processCode: 'GOOD_CONDUCT_V2',
    transactionTypeName: 'شهادة',
    transactionTypeCode: 'CERTIFICATE',
    isActive: true,
    approvalStatus: 'APPROVED',
    pendingPickup: 0,
    inProgress: 5,
    completed: 89,
    rejected: 1,
    departments: [
      'دائرة المالية',
      'شعبة الأرشيف',
    ],
  ),
];
