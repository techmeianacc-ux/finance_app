import 'package:finance_app/DataModel/transaction_data_model.dart';
import 'package:finance_app/DatabaseManager/database_engine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

    List<TransactionDataModel> transactions = [];
    DateTime? selectedDate;
    TransactionType selectedType = TransactionType.Debit;
    TextEditingController amountController = TextEditingController();

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

    List<FlSpot> _buildSpots(){
      return List.generate(transactions.length, (index){
        final tx = transactions[index];

        return FlSpot(
          index.toDouble(),
          tx.amount,
        );
      });
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

      final amount = double.parse(amountController.text);

      final newTransaction = TransactionDataModel(
        dateTime: selectedDate!,
        amount: amount,
        type: selectedType,
      );

      await DatabaseEngine.instance.insertTransaction(newTransaction);
      await _loadData();

      setState(() {
        selectedDate = null;
        amountController.clear();
        selectedType = TransactionType.Debit;
      });
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: SizedBox(
              height: 250,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _buildSpots(),
                      )
                    ]
                  )
                ),
              ),
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
                    "Add Transactions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(selectedDate == null ? "No date selected" : selectedDate.toString().split(" ")[0]),
                      
                      const Spacer(),

                      ElevatedButton(
                        onPressed:_pickDate,
                        child: const Text("Pick Date")
                      )
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children:[
                      const Text("Type: "),
                      const SizedBox(width: 10),

                      DropdownButton<TransactionType>(
                        value: selectedType,
                        onChanged: (value){
                          setState((){
                            selectedType = value!;
                          });
                        },
                        items: TransactionType.values.map((type){
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
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
        ],
      ),
    );
  }
}