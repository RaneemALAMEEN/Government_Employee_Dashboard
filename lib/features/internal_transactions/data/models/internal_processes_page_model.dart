import '../../domain/entities/internal_processes_page_entity.dart';
import 'internal_process_model.dart';

class InternalProcessesPageModel extends InternalProcessesPageEntity {
  const InternalProcessesPageModel({
    required super.items,
    required super.page,
    required super.limit,
    required super.total,
    required super.totalPages,
    required super.hasNext,
    required super.hasPrev,
  });

  factory InternalProcessesPageModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return InternalProcessesPageModel(
      items: itemsJson.map((item) => InternalProcessModel.fromJson(item)).toList(),
      page: pagination['page'] ?? 1,
      limit: pagination['limit'] ?? 6,
      total: pagination['total'] ?? 0,
      totalPages: pagination['total_pages'] ?? 1,
      hasNext: pagination['has_next'] ?? false,
      hasPrev: pagination['has_prev'] ?? false,
    );
  }
}