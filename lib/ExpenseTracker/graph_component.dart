import 'package:finance_app/DataModel/Enums/graph_mode.dart';
import 'package:finance_app/Providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GraphComponent extends StatelessWidget {
  const GraphComponent({super.key});

  Future<void> _pickStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    if (!context.mounted) return;
    await context.read<ExpenseProvider>().setStartDate(pickedDate);
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;
    if (!context.mounted) return;
    await context.read<ExpenseProvider>().setEndDate(pickedDate);
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(spots: expenseProvider.graphData?.spots ?? []),
              ],
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final labels = expenseProvider.graphData?.labels;

                      if (labels == null) {
                        return const SizedBox();
                      }

                      final index = value.toInt();
                      if (index < 0 || index >= labels.length) {
                        return const SizedBox();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          labels[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        expenseProvider.selectedMode != GraphMode.pointtransaction
            ? (Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expenseProvider.startDate == null
                              ? 'No Start Date Selected'
                              : expenseProvider.startDate.toString().split(
                                  ' ',
                                )[0],
                        ),
                        ElevatedButton(
                          onPressed: () => _pickStartDate(context),
                          child: const Text('Start'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          expenseProvider.endDate == null
                              ? 'No End Date Selected'
                              : expenseProvider.endDate.toString().split(
                                  ' ',
                                )[0],
                        ),
                        ElevatedButton(
                          onPressed: () => _pickEndDate(context),
                          child: const Text('End'),
                        ),
                      ],
                    ),
                  ),
                ],
              ))
            : SizedBox(),
        const SizedBox(height: 16),
        DropdownButton<GraphMode>(
          value: expenseProvider.selectedMode,
          onChanged: (value) async {
            if (value == null) return;

            await context.read<ExpenseProvider>().setGraphMode(value);
          },
          items: GraphMode.values.map((mode) {
            return DropdownMenuItem<GraphMode>(
              value: mode,
              child: Text(mode.name),
            );
          }).toList(),
        ),
      ],
    );
  }
}
