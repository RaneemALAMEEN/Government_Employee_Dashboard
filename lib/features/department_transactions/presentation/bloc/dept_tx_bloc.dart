import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:government_employee_dashboard/core/constants/app_permissions.dart';
import 'package:government_employee_dashboard/core/errors/failures.dart';
import 'package:government_employee_dashboard/features/department_transactions/domain/entities/department_transaction_entity.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/accessible_department_entity.dart';
import '../../domain/usecases/get_accessible_departments.dart';
import '../../domain/usecases/get_department_transactions.dart';
import 'dept_tx_event.dart';
import 'dept_tx_state.dart';

import '../../domain/usecases/get_department_stats.dart';

const _limit = 6;

class _CachedDeptTxPage {
  final List<DepartmentTransactionEntity> items;
  final String? nextCursor;
  final bool hasNext;
  final int totalCount;
  final DateTime timestamp;

  _CachedDeptTxPage({
    required this.items,
    this.nextCursor,
    required this.hasNext,
    required this.totalCount,
    required this.timestamp,
  });
}

class DeptTxBloc extends Bloc<DeptTxEvent, DeptTxState> {
  final GetDepartmentTransactions getDepartmentTransactions;
  final GetDepartmentStats getDepartmentStats;
  final GetAccessibleDepartments getAccessibleDepartments;

  final Map<String, _CachedDeptTxPage> _memoryCache = {};

  DeptTxBloc(
    this.getDepartmentTransactions,
    this.getDepartmentStats,
    this.getAccessibleDepartments,
  ) : super(DeptTxInitial()) {
    on<LoadDeptTx>(_onLoadDeptTx);
    on<LoadMoreDeptTx>(_onLoadMoreDeptTx);
    on<FilterDeptTxByStatus>(_onFilterDeptTxByStatus);
    on<FilterDeptTxByDate>(_onFilterDeptTxByDate);
    on<FilterDeptTxByDepartment>(_onFilterDeptTxByDepartment);
    on<SearchDeptTx>(
      _onSearchDeptTx,
      transformer: (events, mapper) =>
          events.debounce(const Duration(milliseconds: 400)).switchMap(mapper),
    );
  }

  String _cacheKey({
    required String deptId,
    required String status,
    String? fromDate,
    String? toDate,
    String? searchQuery,
  }) {
    return '$deptId:$status:${fromDate ?? ""}:${toDate ?? ""}:${searchQuery ?? ""}';
  }

  /// Pre-fetches permitted categories in the background for instant switching
  void _warmUpCategories({
    required String deptId,
    String? fromDate,
    String? toDate,
  }) {
    Future.microtask(() async {
      final session = getIt<SessionService>();
      final canViewCompleted =
          session.hasPermission(AppPermissions.getTaskCompletedByDepartment);
      final canViewRejected =
          session.hasPermission(AppPermissions.getTaskRejectedByDepartment);

      final statuses = [
        if (canViewCompleted) 'منجزة',
        if (canViewRejected) 'مرفوضة',
      ];
      for (final s in statuses) {
        final key = _cacheKey(
          deptId: deptId,
          status: s,
          fromDate: fromDate,
          toDate: toDate,
          searchQuery: null,
        );
        if (!_memoryCache.containsKey(key)) {
          try {
            final res = await getDepartmentTransactions(
              departmentIds: deptId,
              status: s,
              fromDate: fromDate,
              toDate: toDate,
              searchQuery: null,
              cursor: null,
              limit: _limit,
            );
            res.fold((_) {}, (data) {
              final items = data['items'] as List<dynamic>? ?? [];
              final pagination =
                  data['pagination'] as Map<String, dynamic>? ?? {};
              _memoryCache[key] = _CachedDeptTxPage(
                items: items.cast<DepartmentTransactionEntity>(),
                nextCursor: pagination['next_cursor'] as String?,
                hasNext: pagination['has_next'] as bool? ?? false,
                totalCount: pagination['total'] as int? ?? 0,
                timestamp: DateTime.now(),
              );
            });
          } catch (_) {}
        }
      }
    });
  }

  /// الحصول على departmentId — إما المختار أو الافتراضي من SessionService
  String _getDepartmentId({int? selectedDepartmentId}) {
    if (selectedDepartmentId != null) {
      return selectedDepartmentId.toString();
    }
    final activeRole = getIt<SessionService>().activeRoleNotifier.value;
    return activeRole?.departmentId.toString() ?? '1';
  }

  Future<void> _onLoadDeptTx(
      LoadDeptTx event, Emitter<DeptTxState> emit) async {
    final currentState = state;
    final session = getIt<SessionService>();
    final canViewCompleted =
        session.hasPermission(AppPermissions.getTaskCompletedByDepartment);
    final canViewRejected =
        session.hasPermission(AppPermissions.getTaskRejectedByDepartment);

    String currentStatus = canViewCompleted
        ? 'منجزة'
        : (canViewRejected ? 'مرفوضة' : 'منجزة'); // default status based on permission
    String? currentFromDate;
    String? currentToDate;
    String currentSearchQuery = '';
    int? currentSelectedDeptId;
    String? currentSelectedDeptName;
    List<AccessibleDepartmentEntity> currentDepartments = [];

    // We want to keep old stats if we have them, so they don't flash to 0 on refresh.
    int completedCount = 0;
    int rejectedCount = 0;
    int activeCount = 0;
    int inProgressCount = 0;
    int pendingPickupCount = 0;

    if (currentState is DeptTxLoaded && !event.isRefresh) {
      currentStatus = currentState.statusFilter;
      if (currentStatus == 'منجزة' && !canViewCompleted && canViewRejected) {
        currentStatus = 'مرفوضة';
      } else if (currentStatus == 'مرفوضة' && !canViewRejected && canViewCompleted) {
        currentStatus = 'منجزة';
      }
      currentFromDate = currentState.fromDate;
      currentToDate = currentState.toDate;
      currentSearchQuery = currentState.searchQuery;
      currentSelectedDeptId = currentState.selectedDepartmentId;
      currentSelectedDeptName = currentState.selectedDepartmentName;
      currentDepartments = currentState.accessibleDepartments;

      completedCount = currentState.completedCount;
      rejectedCount = currentState.rejectedCount;
      activeCount = currentState.activeCount;
      inProgressCount = currentState.inProgressCount;
      pendingPickupCount = currentState.pendingPickupCount;
    }

    if (currentState is! DeptTxLoaded) {
      emit(DeptTxLoading());
    }

    final departmentId =
        _getDepartmentId(selectedDepartmentId: currentSelectedDeptId);

    // Fetch transactions, stats, and accessible departments in parallel
    final futures = <Future>[
      getDepartmentTransactions(
        departmentIds: departmentId,
        status: currentStatus,
        fromDate: currentFromDate,
        toDate: currentToDate,
        searchQuery: currentSearchQuery.isNotEmpty ? currentSearchQuery : null,
        cursor: null,
        limit: _limit,
      ),
      getDepartmentStats(departmentIds: departmentId),
      // Only fetch departments if we don't have them cached
      if (currentDepartments.isEmpty) getAccessibleDepartments(),
    ];

    final results = await Future.wait(futures);

    final txResult = results[0] as Either<Failure, Map<String, dynamic>>;
    final statsResult = results[1] as Either<Failure, Map<String, dynamic>>;

    // Parse accessible departments
    List<AccessibleDepartmentEntity> departments = currentDepartments;
    if (currentDepartments.isEmpty && results.length > 2) {
      final deptResult =
          results[2] as Either<Failure, List<AccessibleDepartmentEntity>>;
      deptResult.fold(
        (_) {}, // Keep empty on failure
        (depts) => departments = depts,
      );
    }

    // إذا لم يتم اختيار دائرة بعد، نحدد الدائرة الحالية كافتراضية
    if (currentSelectedDeptId == null && departments.isNotEmpty) {
      final activeRole = getIt<SessionService>().activeRoleNotifier.value;
      final defaultDeptId = activeRole?.departmentId;
      if (defaultDeptId != null) {
        final match = departments.where((d) => d.id == defaultDeptId);
        if (match.isNotEmpty) {
          currentSelectedDeptId = match.first.id;
          currentSelectedDeptName = match.first.name;
        } else {
          currentSelectedDeptId = departments.first.id;
          currentSelectedDeptName = departments.first.name;
        }
      } else {
        currentSelectedDeptId = departments.first.id;
        currentSelectedDeptName = departments.first.name;
      }
    }

    txResult.fold(
      (failure) => emit(DeptTxFailure(failure.message)),
      (data) {
        final items = data['items'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;

        final totalCount = pagination['total'] as int? ?? 0;
        final hasNext = pagination['has_next'] as bool? ?? false;
        final nextCursor = pagination['next_cursor'] as String?;

        // Cache in memory for instant switching
        final key = _cacheKey(
          deptId: departmentId,
          status: currentStatus,
          fromDate: currentFromDate,
          toDate: currentToDate,
          searchQuery: currentSearchQuery.isNotEmpty ? currentSearchQuery : null,
        );
        _memoryCache[key] = _CachedDeptTxPage(
          items: items.cast<DepartmentTransactionEntity>(),
          nextCursor: nextCursor,
          hasNext: hasNext,
          totalCount: totalCount,
          timestamp: DateTime.now(),
        );

        // Warm up other categories in background
        _warmUpCategories(
          deptId: departmentId,
          fromDate: currentFromDate,
          toDate: currentToDate,
        );

        // If stats succeeded, update them
        statsResult.fold(
          (failure) {}, // Keep old/0 stats on failure
          (statsData) {
            completedCount = statsData['completed_count'] ?? completedCount;
            rejectedCount = statsData['rejected_count'] ?? rejectedCount;
            activeCount = statsData['active_count'] ?? activeCount;
            inProgressCount = statsData['in_progress_count'] ?? inProgressCount;
            pendingPickupCount =
                statsData['pending_pickup_count'] ?? pendingPickupCount;
          },
        );

        emit(DeptTxLoaded(
          transactions: items.cast(),
          statusFilter: currentStatus,
          fromDate: currentFromDate,
          toDate: currentToDate,
          searchQuery: currentSearchQuery,
          nextCursor: nextCursor,
          hasReachedMax: !hasNext,
          totalCount: totalCount,
          completedCount: completedCount,
          rejectedCount: rejectedCount,
          activeCount: activeCount,
          inProgressCount: inProgressCount,
          pendingPickupCount: pendingPickupCount,
          accessibleDepartments: departments,
          selectedDepartmentId: currentSelectedDeptId,
          selectedDepartmentName: currentSelectedDeptName,
        ));
      },
    );
  }

  Future<void> _onLoadMoreDeptTx(
      LoadMoreDeptTx event, Emitter<DeptTxState> emit) async {
    final currentState = state;
    if (currentState is! DeptTxLoaded ||
        currentState.hasReachedMax ||
        currentState.isFetchingMore) return;

    emit(currentState.copyWith(isFetchingMore: true));

    final departmentId = _getDepartmentId(
        selectedDepartmentId: currentState.selectedDepartmentId);

    final result = await getDepartmentTransactions(
      departmentIds: departmentId,
      status: currentState.statusFilter,
      fromDate: currentState.fromDate,
      toDate: currentState.toDate,
      searchQuery: currentState.searchQuery.isNotEmpty
          ? currentState.searchQuery
          : null,
      cursor: currentState.nextCursor,
      limit: _limit,
    );

    result.fold(
      (failure) => emit(currentState.copyWith(isFetchingMore: false)),
      (data) {
        final items = data['items'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;
        final hasNext = pagination['has_next'] as bool? ?? false;
        final nextCursor = pagination['next_cursor'] as String?;
        final totalCount =
            pagination['total'] as int? ?? currentState.totalCount;

        emit(currentState.copyWith(
          transactions: List.of(currentState.transactions)
            ..addAll(items.cast()),
          nextCursor: nextCursor,
          hasReachedMax: !hasNext,
          isFetchingMore: false,
          totalCount: totalCount,
        ));
      },
    );
  }

  Future<void> _onFilterDeptTxByStatus(
      FilterDeptTxByStatus event, Emitter<DeptTxState> emit) async {
    final session = getIt<SessionService>();
    if (event.statusFilter == 'منجزة' &&
        !session.hasPermission(AppPermissions.getTaskCompletedByDepartment)) {
      return;
    }
    if (event.statusFilter == 'مرفوضة' &&
        !session.hasPermission(AppPermissions.getTaskRejectedByDepartment)) {
      return;
    }

    if (state is DeptTxLoaded) {
      final currentState = state as DeptTxLoaded;
      if (currentState.statusFilter == event.statusFilter) return;

      final deptId = _getDepartmentId(
          selectedDepartmentId: currentState.selectedDepartmentId);
      final key = _cacheKey(
        deptId: deptId,
        status: event.statusFilter,
        fromDate: currentState.fromDate,
        toDate: currentState.toDate,
        searchQuery: currentState.searchQuery.isNotEmpty
            ? currentState.searchQuery
            : null,
      );

      final cached = _memoryCache[key];
      if (cached != null) {
        // Instant 0ms cache response!
        emit(currentState.copyWith(
          transactions: cached.items,
          statusFilter: event.statusFilter,
          nextCursor: cached.nextCursor,
          hasReachedMax: !cached.hasNext,
          totalCount: cached.totalCount,
          isSearching: false,
        ));

        // Warm up and refresh in background
        _warmUpCategories(
          deptId: deptId,
          fromDate: currentState.fromDate,
          toDate: currentState.toDate,
        );
        return;
      }

      // If not cached yet, emit loading for immediate skeleton feedback
      emit(DeptTxLoading());
      add(const LoadDeptTx());
    } else {
      add(const LoadDeptTx());
    }
  }

  void _onFilterDeptTxByDate(
      FilterDeptTxByDate event, Emitter<DeptTxState> emit) {
    if (state is DeptTxLoaded) {
      final currentState = state as DeptTxLoaded;
      final isClearing = event.fromDate == null && event.toDate == null;
      emit(currentState.copyWith(
        fromDate: event.fromDate,
        toDate: event.toDate,
        clearDates: isClearing,
      ));
      add(const LoadDeptTx());
    }
  }

  void _onFilterDeptTxByDepartment(
      FilterDeptTxByDepartment event, Emitter<DeptTxState> emit) {
    if (state is DeptTxLoaded) {
      final currentState = state as DeptTxLoaded;
      if (currentState.selectedDepartmentId == event.departmentId) return;

      emit(currentState.copyWith(
        selectedDepartmentId: event.departmentId,
        selectedDepartmentName: event.departmentName,
      ));
      add(const LoadDeptTx());
    }
  }

  Future<void> _onSearchDeptTx(
      SearchDeptTx event, Emitter<DeptTxState> emit) async {
    if (state is! DeptTxLoaded) return;
    final currentState = state as DeptTxLoaded;
    final query = event.query.trim();

    // Mark isSearching = true while preserving text query & existing state
    emit(currentState.copyWith(
      isSearching: true,
      searchQuery: event.query,
    ));

    final departmentId =
        _getDepartmentId(selectedDepartmentId: currentState.selectedDepartmentId);

    // Call transactions search API ONLY — no stats API call!
    final result = await getDepartmentTransactions(
      departmentIds: departmentId,
      status: currentState.statusFilter,
      fromDate: currentState.fromDate,
      toDate: currentState.toDate,
      searchQuery: query.isNotEmpty ? query : null,
      cursor: null,
      limit: _limit,
    );

    result.fold(
      (failure) {
        if (state is DeptTxLoaded) {
          emit((state as DeptTxLoaded).copyWith(isSearching: false));
        }
      },
      (data) {
        if (state is! DeptTxLoaded) return;
        final latestState = state as DeptTxLoaded;

        final items = data['items'] as List<dynamic>;
        final pagination = data['pagination'] as Map<String, dynamic>;

        final totalCount = pagination['total'] as int? ?? 0;
        final hasNext = pagination['has_next'] as bool? ?? false;
        final nextCursor = pagination['next_cursor'] as String?;

        emit(latestState.copyWith(
          transactions: items.cast(),
          nextCursor: nextCursor,
          hasReachedMax: !hasNext,
          isSearching: false,
          totalCount: totalCount,
        ));
      },
    );
  }
}
