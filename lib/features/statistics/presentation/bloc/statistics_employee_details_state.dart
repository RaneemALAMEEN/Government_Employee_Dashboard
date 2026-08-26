import '../../../self_cards/domain/entities/self_card_entity.dart';
import '../../domain/entities/statistics_employee_details_entity.dart';

abstract class StatisticsEmployeeDetailsState {
  const StatisticsEmployeeDetailsState();
}

class EmployeeDetailsInitial extends StatisticsEmployeeDetailsState {
  const EmployeeDetailsInitial();
}

class EmployeeDetailsLoading extends StatisticsEmployeeDetailsState {
  const EmployeeDetailsLoading();
}

class EmployeeDetailsLoaded extends StatisticsEmployeeDetailsState {
  final StatisticsEmployeeDetailsEntity employee;
  final SelfCardEntity? selfCard;
  final bool isSelfCardLoading;
  final String? selfCardError;

  const EmployeeDetailsLoaded({
    required this.employee,
    this.selfCard,
    this.isSelfCardLoading = false,
    this.selfCardError,
  });

  bool get hasSelfCard => selfCard != null;

  EmployeeDetailsLoaded copyWith({
    StatisticsEmployeeDetailsEntity? employee,
    SelfCardEntity? selfCard,
    bool? isSelfCardLoading,
    String? selfCardError,
    bool clearSelfCardError = false,
  }) {
    return EmployeeDetailsLoaded(
      employee: employee ?? this.employee,
      selfCard: selfCard ?? this.selfCard,
      isSelfCardLoading: isSelfCardLoading ?? this.isSelfCardLoading,
      selfCardError:
          clearSelfCardError ? null : (selfCardError ?? this.selfCardError),
    );
  }
}

class EmployeeDetailsError extends StatisticsEmployeeDetailsState {
  final String message;

  const EmployeeDetailsError({required this.message});
}
