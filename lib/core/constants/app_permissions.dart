/// All backend permission codes mapped literally (preserving exact casing and names).
///
/// Use these constants throughout the app for:
/// - Sidebar item visibility
/// - Route guards
/// - [PermissionGate] widgets and action controls
abstract class AppPermissions {
  // === الإدارة العامة (Admin) ===
  static const String organizationalStructureCreate =
      'ORGANIZATIONAL_STRUCTURE_CREATE';
  static const String processPublishManage = 'PROCESS_PUBLISH_MANAGE';
  static const String processReview = 'PROCESS_REVIEW';
  static const String appVersionManage = 'APP_VERSION_MANAGE';
  static const String permissionManage = 'PERMISSION_MANAGE';
  static const String viewAuditLogs = 'VIEW_AUDIT_LOGS';

  // === الموظف (Employee) ===
  static const String employeesStats = 'EMPLOYEES_STATS';
  static const String viewHistoryTransaction = 'VIEW_HISTORY_TRANSACTION';
  static const String viewCreateFinalDocument = 'VIEW_CREATE_FINAL_DOCUMENT';
  static const String deleteFinalDocument = 'DELETE_FINAL_DOCUMENT';
  static const String getOrganizationalStructure =
      'GET_ORGANIZATIONAL_STRUCTURE';
  static const String processViewStats = 'PROCESS_VIEW_STATS';
  static const String tasksStatsActive = 'TASKS_STATS_ACTIVE';
  static const String tasksStatsRejectedLastMonth =
      'TASKS_STATS_REJECTED_LAST_MONTH';

  /// NOTE: Exact backend code has lowercase `tasks_`
  static const String tasksStatsCompletedLastMonth =
      'tasks_STATS_COMPLETED_LAST_MONTH';

  static const String getTaskRejectedByDepartment =
      'GET_TASK_REJECTED_BY_DEPARTMENT';
  static const String getTaskCompletedByDepartment =
      'GET_TASK_COMPLETED_BY_DEPARTMENT';
  static const String getAllTaskForEmployee = 'GET_ALL_TASK_FOR_EMPLOYEE';
  static const String taskSigning = 'TASK_SIGNING';
  static const String documentVerifyByCode = 'DOCUMENT_VERIFY_BY_CODE';
  static const String appointmentManage = 'APPOINTMENT_MANAGE';
  static const String appointmentBookEmployee = 'APPOINTMENT_BOOK_EMPLOYEE';

  // === عام / مشترك (Employee, Citizen, Admin) ===
  static const String appointmentViewAvailable = 'APPOINTMENT_VIEW_AVAILABLE';
  static const String pinSitting = 'PIN_SITTING';
}
