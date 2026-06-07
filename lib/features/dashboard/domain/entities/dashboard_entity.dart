class DashboardEntity {
  final List<StatEntity> stats;
  final List<BottleneckEntity> bottlenecks;
  final CompletionTimeEntity completionTime;
  final List<WeeklyIndicatorEntity> weeklyIndicators;
  final List<TransactionEntity> latestTransactions;
  final List<String> alerts;

  DashboardEntity({
    required this.stats,
    required this.bottlenecks,
    required this.completionTime,
    required this.weeklyIndicators,
    required this.latestTransactions,
    required this.alerts,
  });
}

class StatEntity {
  final String title;
  final String value;
  final String subtitle;
  final String type;

  StatEntity({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.type,
  });
}

class BottleneckEntity {
  final String title;
  final String count;
  final String delay;

  BottleneckEntity({
    required this.title,
    required this.count,
    required this.delay,
  });
}

class CompletionTimeEntity {
  final String averageDays;
  final String comparison;
  final List<StageTimeEntity> stages;

  CompletionTimeEntity({
    required this.averageDays,
    required this.comparison,
    required this.stages,
  });
}

class StageTimeEntity {
  final String title;
  final double days;
  final double progress;

  StageTimeEntity({
    required this.title,
    required this.days,
    required this.progress,
  });
}

class WeeklyIndicatorEntity {
  final String title;
  final String value;
  final String subtitle;
  final bool isPositive;

  WeeklyIndicatorEntity({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isPositive,
  });
}

class TransactionEntity {
  final String number;
  final String type;
  final String applicant;
  final String date;
  final String status;
  final bool canSign;

  TransactionEntity({
    required this.number,
    required this.type,
    required this.applicant,
    required this.date,
    required this.status,
    required this.canSign,
  });
}