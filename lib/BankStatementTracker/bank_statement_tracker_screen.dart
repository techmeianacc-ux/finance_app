import 'package:flutter/material.dart';

class BankStatementTrackerScreen extends StatelessWidget {
  const BankStatementTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bank Statement Tracker")),
      body: Center(
        child: Text("Bank Statement Tracker Screen"),
      ),
    );
  }
}