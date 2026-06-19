// import 'dart:io';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:government_employee_dashboard/core/di/injection.dart';
// import 'package:government_employee_dashboard/features/auth/di/injection.dart';
// import 'package:government_employee_dashboard/features/auth/presentation/bloc/login/login_bloc.dart';
// import 'package:government_employee_dashboard/features/auth/presentation/bloc/login/login_event.dart';
// import 'package:government_employee_dashboard/features/auth/presentation/bloc/login/login_state.dart';

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();

  // setUpAll(() async {
  //   print("Bypassing mock HTTP overrides for real network testing...");
  //   HttpOverrides.global = null;

  //   print("Loading env...");
  //   await dotenv.load(fileName: "env/dev.env");
  //   print("Setting up injection...");
  //   await setupCoreInjection();
  //   await setupAuthInjection();
  // });

  // test('Test LoginBloc submitting credentials with real network', () async {
  //   print("Getting LoginBloc...");
  //   final loginBloc = getIt<LoginBloc>();

  //   print("Emitting event and listening for states...");
  //   final states = <LoginState>[];
  //   final subscription = loginBloc.stream.listen((state) {
  //     print("New state emitted: $state");
  //     states.add(state);
  //   });

  //   print("Adding LoginSubmitted event...");
  //   loginBloc.add(const LoginSubmitted(
  //     userName: 'rawan_doe',
  //     password: 'Test123',
  //   ));

  //   // Wait up to 10 seconds for states
  //   print("Waiting for response...");
  //   await Future.delayed(const Duration(seconds: 10));

  //   print("States recorded: $states");
  //   await subscription.cancel();

  //   expect(states, contains(isA<LoginSuccess>()));
  // }, timeout: const Timeout(Duration(seconds: 15)));
}
