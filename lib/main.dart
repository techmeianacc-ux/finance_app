import 'package:finance_app/BankStatementTracker/bank_statement_tracker_screen.dart';
import 'package:finance_app/DashboardScreen/dashboard_screen.dart';
import 'package:finance_app/ExpenseTracker/expense_tracker.dart';
import 'package:finance_app/Providers/expense_provider.dart';
import 'package:finance_app/RoutineTracker/routine_tracker.dart';
import 'package:finance_app/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const FinanceApp(),
    );
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Finance_App",
      initialRoute: AppRoutes.dashboard,
      routes: {
        AppRoutes.dashboard: (_) => const DashboardScreen(),
        AppRoutes.expenseTracker: (_) => ChangeNotifierProvider(
              create: (_) => ExpenseProvider()..loadGraph(),
              child: const ExpenseTracker(),
            ),
        AppRoutes.bankStatementTracker: (_) => const BankStatementTrackerScreen(),
        AppRoutes.routineTracker: (_) => const RoutineTracker(),
      },
    );
  }
}