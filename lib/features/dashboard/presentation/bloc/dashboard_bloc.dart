import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard_data.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardData getDashboardData;

  DashboardBloc(this.getDashboardData) : super(DashboardInitial()) {
    on<LoadDashboardEvent>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final dashboard = await getDashboardData();
      emit(DashboardLoaded(dashboard));
    } catch (_) {
      emit(DashboardFailure('تعذر تحميل بيانات لوحة رئيس الدائرة'));
    }
  }
}