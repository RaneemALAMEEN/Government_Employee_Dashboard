import 'package:equatable/equatable.dart';

import 'process_definition_entity.dart';
import 'process_definitions_pagination_entity.dart';

class ProcessDefinitionsResponseEntity extends Equatable {
  final List<ProcessDefinitionEntity> items;
  final ProcessDefinitionsPaginationEntity pagination;

  const ProcessDefinitionsResponseEntity({
    required this.items,
    required this.pagination,
  });

  @override
  List<Object?> get props => [items, pagination];
}
