import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:finance_app/DatabaseManager/database_engine.dart';
import 'package:finance_app/HomeScreen/graph_component.dart';
import 'package:fl_chart/fl_chart.dart';

class DataProcessor {

    DatabaseEngine databaseEngine;

    DataProcessor({required this.databaseEngine});

    Future<List<FlSpot>> processedTransactions( GraphMode mode, DateTime start, DateTime end) async{

      switch(mode){
        case GraphMode.daily:
          final transactions = await databaseEngine.getTransactions();
          return List.generate(transactions.length,(i){
            return FlSpot(x, y)
          });

        case GraphMode.weekly:
          return databaseEngine.getRangeTransactions(start, end);
        case GraphMode.monthly:
          return databaseEngine.getRangeTransactions(start, end);
      }
    }
}