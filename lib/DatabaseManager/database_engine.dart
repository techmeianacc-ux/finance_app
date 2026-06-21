import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseEngine {
  DatabaseEngine._privateConstructor();
  static final DatabaseEngine instance = DatabaseEngine._privateConstructor();

  Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, 'finance_app.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(
    Database db,
    int version
    ) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL
      )
  ''');
  }

  Future<List<TransactionDataModel>> getTransactions() async {
    final db = await database;

    final List<Map<String, dynamic>> transactionrecords = 
    await db.query('transactions');

    return List.generate(transactionrecords.length, (i) {
      return TransactionDataModel(
      id: transactionrecords[i]['id'],
      dateTime: DateTime.parse(transactionrecords[i]['dateTime']),
      amount: transactionrecords[i]['amount'],
      type: transactionrecords[i]['type']=='Credit' ? TransactionType.Credit : TransactionType.Debit,);
    });
  } 

  Future<int> insertTransaction(TransactionDataModel tx) async {
    final db = await database;
    return await db.insert('transactions',{
      'dateTime': tx.dateTime.toIso8601String(),
      'amount': tx.amount,
      'type': tx.type.name,
    });
  }
}