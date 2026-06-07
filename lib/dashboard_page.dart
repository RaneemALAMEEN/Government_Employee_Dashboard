import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:government_employee_dashboard/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:government_employee_dashboard/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:government_employee_dashboard/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:government_employee_dashboard/features/dashboard/presentation/widgets/app_shell.dart';


class DepartmentHeadDashboardPage extends StatelessWidget {
  const DepartmentHeadDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DashboardFailure) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadDashboardEvent());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DashboardLoaded) {
          return AppShell(dashboard: state.dashboard);
        }

        return const SizedBox.shrink();
      },
    );
  }
}