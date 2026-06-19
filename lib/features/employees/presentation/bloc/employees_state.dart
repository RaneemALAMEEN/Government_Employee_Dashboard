import '../../domain/entities/employee_entity.dart';

abstract class EmployeesState {
  const EmployeesState();
}

class EmployeesInitial extends EmployeesState {}

class EmployeesLoading extends EmployeesState {}

class EmployeesLoaded extends EmployeesState {
  final List<EmployeeEntity> allEmployees;
  final List<EmployeeEntity> filteredEmployees;
  final String searchQuery;
  final int activeTxCount;
  final int doneTxCount;
  final int overburdenedCount;
  final int inactiveCount;

  const EmployeesLoaded({
    required this.allEmployees,
    required this.filteredEmployees,
    required this.searchQuery,
    required this.activeTxCount,
    required this.doneTxCount,
    required this.overburdenedCount,
    required this.inactiveCount,
  });

  EmployeesLoaded copyWith({
    List<EmployeeEntity>? allEmployees,
    List<EmployeeEntity>? filteredEmployees,
    String? searchQuery,
    int? activeTxCount,
    int? doneTxCount,
    int? overburdenedCount,
    int? inactiveCount,
  }) {
    return EmployeesLoaded(
      allEmployees: allEmployees ?? this.allEmployees,
      filteredEmployees: filteredEmployees ?? this.filteredEmployees,
      searchQuery: searchQuery ?? this.searchQuery,
      activeTxCount: activeTxCount ?? this.activeTxCount,
      doneTxCount: doneTxCount ?? this.doneTxCount,
      overburdenedCount: overburdenedCount ?? this.overburdenedCount,
      inactiveCount: inactiveCount ?? this.inactiveCount,
    );
  }
}

class EmployeeDetailsLoaded extends EmployeesState {
  final EmployeeEntity employee;
  final int activeTab; // 0 for basic info, 1 for system info

  const EmployeeDetailsLoaded({
    required this.employee,
    this.activeTab = 0,
  });

  EmployeeDetailsLoaded copyWith({
    EmployeeEntity? employee,
    int? activeTab,
  }) {
    return EmployeeDetailsLoaded(
      employee: employee ?? this.employee,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class EmployeesFailure extends EmployeesState {
  final String message;
  const EmployeesFailure(this.message);
}
