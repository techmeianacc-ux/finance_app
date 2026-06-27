import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseEngine {
  
  //Variables
  DatabaseEngine._privateConstructor();
  
  static final DatabaseEngine instance = DatabaseEngine._privateConstructor();

  Database? _database;
  


  //Getting the Database instance or creating it if it doesn't exist
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    _database = await _initDatabase();
    return _database!;
  }

  //Initializing the database
  Future<Database> _initDatabase() async {

    final dbPath = await getDatabasesPath();

    final path = join(dbPath, 'finance_app.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  //Creating the database table
  Future<void> _onCreate(
    Database db,
    int version
    ) async {
    await db.execute(
      '''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          dateTime TEXT NOT NULL,
          amount REAL NOT NULL)'''
    );
  }

  //getting transactions by date
  Future<List<TransactionDataModel>> queryTransactionsByDate(DateTime date) async{
    final db = await database;

    final List<Map<String, dynamic>> results = await db.query(
      'transactions',
      where: 'dateTime LIKE ?',
      whereArgs: ['${date.toIso8601String().split("T")[0]}%']
    );

    return List.generate(
      results.length, (i){
        return TransactionDataModel(
          id: results[i]['id'],
          dateTime: DateTime.parse(results[i]['dateTime']),
          amount: (results[i]['amount'] as num).toDouble()
          );
      }

    );
  }

  //getting all transactions
  Future<List<TransactionDataModel>> getTransactions() async {
    final db = await database;

    final List<Map<String, dynamic>> transactionrecords = 
    await db.query('transactions', orderBy:'dateTime ASC');

    return List.generate(transactionrecords.length, (i) {
      return TransactionDataModel(
      id: transactionrecords[i]['id'],
      dateTime: DateTime.parse(transactionrecords[i]['dateTime']),
      amount: (transactionrecords[i]['amount'] as num).toDouble()
      );
    });
  } 

  //Inserting a transaction into the database
  Future<int> insertTransaction(TransactionDataModel tx) async {
    final db = await database;
    return await db.insert('transactions',{
      'dateTime': tx.dateTime.toIso8601String(),
      'amount': tx.amount
    }
    );
  }

  Future<int> deleteAllTransactions() async{
    final db = await database;
    return await db.delete('transactions');
  }
  //Querying a range of transactions
  Future<List<TransactionDataModel>> getRangeTransactions(DateTime? start, DateTime? end) async{

    final db = await database;
    if (start ==null || end==null){
      final now = DateTime.now();
      start = DateTime(now.year, 1, 1);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
    }
    final List<Map<String, dynamic>> results = await db.query('transactions',
    where: 'dateTime >= ? AND dateTime <= ?',
    whereArgs: [start.toIso8601String(),end.toIso8601String()],orderBy: 'dateTime ASC');

    return List.generate(results.length,(i) {
      return TransactionDataModel(
        id:results[i]['id'],
        dateTime: DateTime.parse(results[i]['dateTime']),
        amount: (results[i]['amount'] as num).toDouble()
        );
      }
    );

  }
}