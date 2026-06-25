import 'package:finance_app/DataModel/graph_data_model.dart';
import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:finance_app/DatabaseManager/database_engine.dart';
import 'package:finance_app/HomeScreen/graph_component.dart';
import 'package:fl_chart/fl_chart.dart';

class DataProcessor {
  DatabaseEngine databaseEngine;

  DataProcessor({required this.databaseEngine});

  List<TransactionDataModel> transactionAggregator(
    GraphMode g,
    List<TransactionDataModel> t,
  ) {
    if (g == GraphMode.pointtransaction) {
      return t;
    }
    final List<TransactionDataModel> processedTransactionRecords = [];

    for (var record in t) {
      if (processedTransactionRecords.isEmpty) {
        processedTransactionRecords.add(record);
      } else if (checkDateEquality(
        processedTransactionRecords.last.dateTime,
        record.dateTime,
        g,
      )) {
        final double newAmount =
            record.amount + processedTransactionRecords.last.amount;
        final TransactionDataModel prcRecord = TransactionDataModel(
          dateTime: record.dateTime,
          amount: newAmount,
        );

        processedTransactionRecords.removeLast();
        processedTransactionRecords.add(prcRecord);
      } else {
        processedTransactionRecords.add(record);
      }
    }
    return processedTransactionRecords;
  }

  bool checkDateEquality(DateTime a, DateTime b, GraphMode g) {
    switch (g) {
      case GraphMode.daily:
        return (a.day == b.day && a.month == b.month && a.year == b.year);
      case GraphMode.monthly:
        return (a.month == b.month && a.year == b.year);
      case GraphMode.yearly:
        return (a.year == b.year);
      default:
        return false;
    }
  }

  Future<GraphDataModel> processedTransactions(
    GraphMode mode,
    DateTime? start,
    DateTime? end,
  ) async {
    final transactions = await databaseEngine.getRangeTransactions(start, end);
    final transactionRecords = transactionAggregator(mode, transactions);

    final spots = List.generate(transactionRecords.length, (i) {
      return FlSpot(i.toDouble(), transactionRecords[i].amount);
    });

    final labels = List.generate(transactionRecords.length, (i) {
      final date = transactionRecords[i].dateTime;
      return mode == GraphMode.daily
          ? "${date.day}/${date.month}"
          : (mode == GraphMode.monthly
                ? "${date.month}/${date.year}"
                :"${date.year}");
    });

    return mode!=GraphMode.pointtransaction?GraphDataModel(spots: spots, labels: labels):GraphDataModel(spots: spots);
  }
}
