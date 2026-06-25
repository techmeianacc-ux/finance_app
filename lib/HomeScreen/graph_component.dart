import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:finance_app/DatabaseManager/database_engine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphComponent extends StatelessWidget {

  final List<TransactionDataModel> transactions;

  const GraphComponent({super.key, required this.transactions});

   List<FlSpot> _getSpots() {


    return List.generate(transactions.length, (index){
      return FlSpot(transactions[index].dateTime, transactions[index].amount);
    }
    );
   }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(spots: _getSpots())
              ]
            )
          )
        )
      )
    );
  }
  
 
}
enum GraphMode {
  daily,
  weekly,
  monthly,
  yearly,

}