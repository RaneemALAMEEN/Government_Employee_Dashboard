abstract class StatisticsEvent {
  const StatisticsEvent();
}

class LoadStatistics extends StatisticsEvent {
  const LoadStatistics();
}

class RefreshStatistics extends StatisticsEvent {
  const RefreshStatistics();
}

class LoadMoreStatisticsEmployees extends StatisticsEvent {
  const LoadMoreStatisticsEmployees();
}

class LoadMoreStatisticsProcesses extends StatisticsEvent {
  const LoadMoreStatisticsProcesses();
}

class RetryStatisticsEmployeesLoadMore extends StatisticsEvent {
  const RetryStatisticsEmployeesLoadMore();
}

class RetryStatisticsProcessesLoadMore extends StatisticsEvent {
  const RetryStatisticsProcessesLoadMore();
}

class ApplyProcessDateFilter extends StatisticsEvent {
  final String? fromDate;
  final String? toDate;

  const ApplyProcessDateFilter({
    required this.fromDate,
    required this.toDate,
  });
}
