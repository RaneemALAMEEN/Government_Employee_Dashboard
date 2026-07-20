import 'package:equatable/equatable.dart';

class ProcessDefinitionEntity extends Equatable {
  final int processId;
  final String name;
  final String code;
  final int priority;
  final String deploymentStatus;
  final String approvalStatus;
  final bool isActive;

  const ProcessDefinitionEntity({
    required this.processId,
    required this.name,
    required this.code,
    required this.priority,
    required this.deploymentStatus,
    required this.approvalStatus,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        processId,
        name,
        code,
        priority,
        deploymentStatus,
        approvalStatus,
        isActive,
      ];
}
