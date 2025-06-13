import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/income_repository.dart';
import 'logic/blocs/auth/auth_bloc.dart';
import 'logic/blocs/expense/expense_bloc.dart';
import 'logic/blocs/dashboard/dashboard_bloc.dart';
import 'logic/blocs/income/income_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final expenseRepository = ExpenseRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(authRepository)),
        BlocProvider(create: (_) => ExpenseBloc(expenseRepository)),
        BlocProvider(
            create: (_) =>
                DashboardBloc(expenseRepository, IncomeRepository())),
        BlocProvider(create: (_) => IncomeBloc(IncomeRepository())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expensify',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFEFF3F9),
        ),
        home: LoginScreen(),
      ),
    );
  }
}
