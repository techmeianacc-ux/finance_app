import 'package:finance_app/DashboardScreen/dashboard_card.dart';
import 'package:finance_app/app_routes.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            childAspectRatio: 2 / 1,
            mainAxisSpacing: 11,
            crossAxisSpacing: 11,
          ),
          children: [
            DashboardCard(title: 'Expense Tracker', imagePath: 'assets/icons/expense.png', routeName: AppRoutes.expenseTracker),
            DashboardCard(title: 'Bank Statement Tracker', imagePath: 'assets/icons/government-budget.png', routeName: AppRoutes.bankStatementTracker),
            DashboardCard(title: 'Routine Tracker', imagePath: 'assets/icons/task-checklist.png', routeName: AppRoutes.routineTracker)
          ],
        ),
      ),
    );
  }
}
