import 'package:flutter/material.dart';

class RoutineTracker extends StatelessWidget {
  const RoutineTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Routine Tracker")),
      body: Center(
        child: Text("Routine Tracker Screen"),
      ),
    );
  }
}