import '../../domain/entities/internal_transactions_page_entity.dart';
import 'internal_transaction_model.dart';

class InternalTransactionsPageModel extends InternalTransactionsPageEntity {
  const InternalTransactionsPageModel({
    required super.items,
    required super.page,
    required super.limit,
    required super.total,
    required super.totalPages,
    required super.hasNext,
    required super.hasPrev,
  });

  factory InternalTransactionsPageModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return InternalTransactionsPageModel(
      items: itemsJson
          .map(
            (item) => InternalTransactionModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      page: pagination['page'] ?? 1,
      limit: pagination['limit'] ?? 10,
      total: pagination['total'] ?? 0,
      totalPages: pagination['total_pages'] ?? 1,
      hasNext: pagination['has_next'] ?? false,
      hasPrev: pagination['has_prev'] ?? false,
    );
  }
}