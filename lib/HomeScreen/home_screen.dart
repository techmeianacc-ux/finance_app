import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: ListView(
        children: [
          Card(
            margin: EdgeInsets.all(12),
            child: SizedBox(
              height: 250,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          FlSpot(1, 0),
                          FlSpot(2, 1),
                          FlSpot(3, 4)
                        ]
                      )
                    ]
                  )
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}