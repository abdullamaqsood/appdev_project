import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:appdev_project/blocs/auth/auth_bloc.dart';
import 'package:appdev_project/blocs/auth/auth_state.dart';
import 'package:appdev_project/screens/auth/login_screen.dart';
import 'package:appdev_project/blocs/auth/auth_event.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('LoginScreen golden test', (WidgetTester tester) async {
    final mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    final builder = MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: LoginScreen(),
      ),
    );

    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'login_screen_golden');
  });
}
