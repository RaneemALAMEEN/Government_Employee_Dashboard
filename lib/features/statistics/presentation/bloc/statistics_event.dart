abstract class StatisticsEvent {
  const StatisticsEvent();
}

class LoadStatistics extends StatisticsEvent {
  const LoadStatistics();
}

class RefreshStatistics extends StatisticsEvent {
  const RefreshStatistics();
}

class ApplyProcessDateFilter extends StatisticsEvent {
  final String? fromDate;
  final String? toDate;

  const ApplyProcessDateFilter({
    required this.fromDate,
    required this.toDate,
  });
}
