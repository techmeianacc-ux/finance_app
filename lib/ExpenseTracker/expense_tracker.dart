import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:finance_app/ExpenseTracker/graph_component.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finance_app/Providers/expense_provider.dart';

class ExpenseTracker extends StatefulWidget {
  const ExpenseTracker({super.key});

  @override
  State<ExpenseTracker> createState() => _ExpenseTrackerState();
}
//Above is the ExpenseTracker Widget Class for stateful Widget.

//Below is the State Class for the ExpenseTracker Widget.
class _ExpenseTrackerState extends State<ExpenseTracker> {
  //Variables
  DateTime? selectedDate; //Date for which the Expense is added.
  TextEditingController amountController =
      TextEditingController(); //Amount which is spent collected from user.
  TextEditingController expenseDescriptionController =
      TextEditingController(); //Description of the expense collected from user.

  //Function to query transactions for a specific date
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

    if (!context.mounted) return;

    await context.read<ExpenseProvider>().queryTransactions(queriedDate);
  }

  //Function to pick Date for adding the expense.
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

  //Function to insert the expense into the datebase
  Future<void> _submitTransaction() async {
    if (selectedDate == null || amountController.text.isEmpty) {
      return;
    }

    final amount = double.parse(
      amountController.text,
    ); //add exception handling here

    if (amount <= 0) {
      //on screen message to user that amount must be greater than zero
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Amount must be greater than zero")),
      );
      return;
    }
    final newTransaction = TransactionDataModel(
      dateTime: selectedDate!,
      amount: amount,
      expenseDescription: expenseDescriptionController.text,
    );

    await context.read<ExpenseProvider>().insertTransaction(newTransaction);
    if (!mounted) return;
    setState(() {
      selectedDate = null;
      amountController.clear();
      expenseDescriptionController.clear();
    });
  }

  //Function to delete all expense records from the database
  Future<void> _deleteRecords() async {
    await context.read<ExpenseProvider>().deleteAllTransactions();
  }

  //Cleanup Function for the amountController to avoid memory leaks when the widget is disposed.
  @override
  void dispose() {
    amountController.dispose();
    expenseDescriptionController.dispose();
    super.dispose();
  }

  //Main Widget build function for the ExpenseTracker Widget which builds the UI of the ExpenseTracker.
  @override
  Widget build(BuildContext context) {


    final expenseProvider = context.watch<ExpenseProvider>(); //Whenever the ExpenseProvider notifies the listeners, this widget will rebuild.

    return Scaffold(
      appBar: AppBar(title: Text("Expense Tracker")),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GraphComponent(), //The GraphComponent Widget is used to display the graph of the expenses.
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

                  TextField(
                    controller: expenseDescriptionController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      border: OutlineInputBorder(),
                    )
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
                        expenseProvider.querySelectedDate == null
                            ? "No date selected"
                            : expenseProvider.querySelectedDate
                                  .toString()
                                  .split(" ")[0],
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
                    itemCount: expenseProvider.queriedTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = expenseProvider.queriedTransactions[index];
                      return ListTile(
                        title: Text(tx.amount.toString()),
                        subtitle: Text(tx.dateTime.toString()),
                        trailing: Text(tx.expenseDescription),
                        
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _deleteRecords,
            child: Text('Delete All Records'),
          ),
        ],
      ),
    );
  }
}
