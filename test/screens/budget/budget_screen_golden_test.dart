import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:appdev_project/blocs/budget/budget_bloc.dart';
import 'package:appdev_project/blocs/budget/budget_state.dart';
import 'package:appdev_project/blocs/budget/budget_event.dart';
import 'package:appdev_project/screens/budget/budget_screen.dart';
import 'package:appdev_project/data/models/budget_model.dart';

class MockBudgetBloc extends MockBloc<BudgetEvent, BudgetState>
    implements BudgetBloc {}

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('BudgetScreen golden test', (WidgetTester tester) async {
    final mockBudgetBloc = MockBudgetBloc();
    when(() => mockBudgetBloc.state).thenReturn(
      BudgetLoaded([
        BudgetModel(
          id: '1',
          category: 'Food',
          limit: 200.0,
          createdAt: DateTime(2023, 1, 1),
        ),
        BudgetModel(
          id: '2',
          category: 'Transport',
          limit: 100.0,
          createdAt: DateTime(2023, 1, 2),
        ),
      ]),
    );

    final builder = MaterialApp(
      home: BlocProvider<BudgetBloc>.value(
        value: mockBudgetBloc,
        child: BudgetScreen(onTabSelected: (_) {}),
      ),
    );

    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(tester, 'budget/goldens/budget_screen_golden');
  });
}
