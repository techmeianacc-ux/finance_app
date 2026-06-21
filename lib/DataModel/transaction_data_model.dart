class TransactionDataModel {
  final int? id;
  final DateTime dateTime;
  final double amount;
  //final TransactionType type;
  
  //TransactionDataModel({this.id, required this.dateTime, required this.amount, required this.type});
  TransactionDataModel({this.id, required this.dateTime, required this.amount});
}

enum TransactionType {Credit, Debit}
