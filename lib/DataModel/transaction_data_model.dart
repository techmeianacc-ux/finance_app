class TransactionDataModel {
  final DateTime dateTime;
  final double amount;
  final TransactionType type;
  
  TransactionDataModel({required this.dateTime, required this.amount, required this.type});
}

enum TransactionType {Credit, Debit}
