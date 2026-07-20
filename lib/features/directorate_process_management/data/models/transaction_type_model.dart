import '../../domain/entities/transaction_type_entity.dart';

class TransactionTypeModel extends TransactionTypeEntity {
  const TransactionTypeModel({
    required super.id,
    required super.name,
    required super.code,
    required super.isActive,
    super.itemCount,
  });

  factory TransactionTypeModel.fromJson(Map<String, dynamic> json) {
    final rawCount = json['item_count'] ?? json['count'];
    return TransactionTypeModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active'] == 1,
      itemCount: rawCount == null ? null : int.tryParse(rawCount.toString()),
    );
  }
}
