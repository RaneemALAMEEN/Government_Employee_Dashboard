abstract class StatisticsEvent {
  const StatisticsEvent();
}

class LoadStatistics extends StatisticsEvent {
  const LoadStatistics();
}

class RefreshStatistics extends StatisticsEvent {
  const RefreshStatistics();
}
