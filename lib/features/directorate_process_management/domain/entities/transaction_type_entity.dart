import 'package:equatable/equatable.dart';

class TransactionTypeEntity extends Equatable {
  final int id;
  final String name;
  final String code;
  final bool isActive;
  final int? itemCount;

  const TransactionTypeEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.itemCount,
  });

  @override
  List<Object?> get props => [id, name, code, isActive, itemCount];
}
