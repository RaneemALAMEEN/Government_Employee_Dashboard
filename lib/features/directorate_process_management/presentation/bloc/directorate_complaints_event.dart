import 'package:equatable/equatable.dart';

sealed class DirectorateComplaintsEvent extends Equatable {
  const DirectorateComplaintsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDirectorateComplaints extends DirectorateComplaintsEvent {
  const LoadDirectorateComplaints();
}

class LoadMoreDirectorateComplaints extends DirectorateComplaintsEvent {
  const LoadMoreDirectorateComplaints();
}

class RetryDirectorateComplaints extends DirectorateComplaintsEvent {
  const RetryDirectorateComplaints();
}

class RetryMoreDirectorateComplaints extends DirectorateComplaintsEvent {
  const RetryMoreDirectorateComplaints();
}

class SearchDirectorateComplaints extends DirectorateComplaintsEvent {
  final String query;

  const SearchDirectorateComplaints(this.query);

  @override
  List<Object?> get props => [query];
}
