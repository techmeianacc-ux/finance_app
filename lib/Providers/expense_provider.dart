import 'package:finance_app/DataModel/Enums/graph_mode.dart';
import 'package:finance_app/DataModel/graph_data_model.dart';
import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:finance_app/DataProcessor/data_processor.dart';
import 'package:finance_app/DatabaseManager/database_engine.dart';
import 'package:flutter/material.dart';

class ExpenseProvider extends ChangeNotifier {
  final DatabaseEngine dbEngine = DatabaseEngine.instance;

  final DataProcessor dataProcessor = DataProcessor(
    databaseEngine: DatabaseEngine.instance,
  );

  GraphDataModel? graphData;

  GraphMode selectedMode = GraphMode.pointtransaction;

  DateTime? startDate;
  DateTime? endDate;

  List<TransactionDataModel> queriedTransactions = [];

  DateTime? querySelectedDate;

  Future<void> loadGraph() async {
    graphData = await dataProcessor.processedTransactions(
      selectedMode,
      startDate,
      endDate,
    );
    notifyListeners();
  }

  Future<void> insertTransaction(TransactionDataModel tx) async {
    await dbEngine.insertTransaction(tx);
    await loadGraph();
  }

  Future<void> queryTransactions(DateTime date) async {
    querySelectedDate = date;
    queriedTransactions = await dbEngine.queryTransactionsByDate(date);
    notifyListeners();
  }

  Future<void> setStartDate(DateTime date) async {
    startDate = date;
    await loadGraph();
  }

  Future<void> setEndDate(DateTime date) async {
    endDate = date;
    await loadGraph();
  }

  Future<void> setGraphMode(GraphMode mode) async {
    selectedMode = mode;
    await loadGraph();
  }

  Future<void> deleteAllTransactions() async{
    await dbEngine.deleteAllTransactions();
    queriedTransactions.clear();
    querySelectedDate = null;
    await loadGraph();
  }
}
