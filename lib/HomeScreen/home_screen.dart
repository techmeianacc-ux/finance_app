import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:finance_app/DatabaseManager/database_engine.dart';
import 'package:finance_app/HomeScreen/graph_component.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<TransactionDataModel> transactions = [];

  DateTime? selectedDate;

  TextEditingController amountController = TextEditingController();

  DateTime? querySelectedDate;

  List<TransactionDataModel> queriedTransactions = [];

  Future<void> _queryTransactions() async {
    
    final queriedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (queriedDate == null) {
      return;
    }

    final results = await DatabaseEngine.instance.queryTransactionsByDate(
      queriedDate,
    );

    if (results.isNotEmpty) {
      setState(() {
        querySelectedDate = queriedDate;
        queriedTransactions = results;
      });
    }
    else{
      setState(() {
        querySelectedDate = queriedDate;
        queriedTransactions = [];
      });
      //ScaffoldMessenger.of(context).showSnackBar(
        //const SnackBar(content: Text("No transactions found for the selected date")),
      //);
    }
  }

  Future<void> _loadData() async {
    final data = await DatabaseEngine.instance.getTransactions();
    setState(() {
      transactions = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _submitTransaction() async {
    if (selectedDate == null || amountController.text.isEmpty) {
      return;
    }

    final amount = double.parse(amountController.text); //add exception handling here

    if(amount<=0){
      //on screen message to user that amount must be greater than zero
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Amount must be greater than zero")),
      );
      return;
    }
    final newTransaction = TransactionDataModel(
      dateTime: selectedDate!,
      amount: amount,
    );

    await DatabaseEngine.instance.insertTransaction(newTransaction);
    await _loadData();

    setState(() {
      selectedDate = null;
      amountController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:GraphComponent(),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Expense",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        selectedDate == null
                            ? "No date selected"
                            : selectedDate.toString().split(" ")[0],
                      ),

                      const Spacer(),

                      ElevatedButton(
                        onPressed: _pickDate,
                        child: const Text("Pick Date"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Amount",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitTransaction,
                      child: const Text("Submit"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        querySelectedDate == null
                            ? "No date selected"
                            : querySelectedDate.toString().split(" ")[0],
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _queryTransactions,
                        child: const Text("Get Expenses"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queriedTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = queriedTransactions[index];
                      return ListTile(
                        title: Text(tx.amount.toString()),
                        subtitle: Text(tx.dateTime.toString()),
                        
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
