import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/expense_repository.dart';
import 'data/repositories/income_repository.dart';
import 'data/repositories/budget_repository.dart';
import 'data/repositories/debt_repository.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/expense/expense_bloc.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'blocs/income/income_bloc.dart';
import 'blocs/budget/budget_bloc.dart';
import 'blocs/debt/debt_bloc.dart';
import 'screens/auth/login_screen.dart';
import 'utils/notification_helper.dart';
import 'screens/admin/user_management_screen.dart';
import 'blocs/role_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationHelper.init();
  await NotificationHelper.requestPermissions();

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
        BlocProvider(create: (_) => BudgetBloc(BudgetRepository())),
        BlocProvider(create: (_) => DebtBloc(DebtRepository())),
        BlocProvider(create: (_) => RoleBloc(authRepository)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expensify',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFEFF3F9),
        ),
        home: _RoleBasedHome(),
      ),
    );
  }
}

class _RoleBasedHome extends StatefulWidget {
  @override
  State<_RoleBasedHome> createState() => _RoleBasedHomeState();
}

class _RoleBasedHomeState extends State<_RoleBasedHome> {
  @override
  void initState() {
    super.initState();
    context.read<RoleBloc>().add(CheckRole());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        if (state is RoleLoading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (state is RoleAdmin) {
          return const UserManagementScreen();
        } else if (state is RoleNormal) {
          return LoginScreen();
        } else if (state is RoleError) {
          return Scaffold(
              body: Center(child: Text('Error: \\${state.message}')));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
