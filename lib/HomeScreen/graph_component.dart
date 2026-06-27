import 'package:finance_app/DataModel/graph_data_model.dart';
import 'package:finance_app/DataProcessor/data_processor.dart';
import 'package:finance_app/DatabaseManager/database_engine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GraphComponent extends StatefulWidget {
  const GraphComponent({super.key});

  @override
  State<GraphComponent> createState() => _GraphComponentState();
}

class _GraphComponentState extends State<GraphComponent> {
  GraphMode selectedMode = GraphMode.pointtransaction;
  DateTime? startDate;
  DateTime? endDate;

  GraphDataModel? graphData;

  final DataProcessor dP = DataProcessor(
    databaseEngine: DatabaseEngine.instance,
  );

  Future<void> _loadGraph(GraphMode m) async {
    final data = await dP.processedTransactions(m, startDate, endDate);

    setState(() {
      selectedMode = m;
      graphData = data;
    });
  }

  Future<void> _pickStartDate() async
  {
    final pickedDate = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100),initialDate: DateTime.now());
    if(pickedDate!=null)
    {
      setState(() {
        startDate = pickedDate;
      });

      await _loadGraph(selectedMode);
    }
  }

  Future<void> _pickEndDate() async{
    final pickedDate = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime(2100), initialDate: DateTime.now());
    if(pickedDate!=null)
    {
      setState(() {
        endDate = pickedDate;
      });

      await _loadGraph(selectedMode);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGraph(selectedMode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                lineBarsData: [LineChartBarData(spots: graphData?.spots ?? [])],
                titlesData: FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta){
                        if (graphData==null || graphData!.labels==null) return SizedBox();
                        final index = value.toInt();
                        if (index<0 || index >= graphData!.labels!.length)
                        {
                          return SizedBox();
                        }
                        return SideTitleWidget(meta: meta,child: Text(
                          graphData!.labels![index],
                          style: const TextStyle(fontSize: 10),                          
                        ));
                      }
                    )
                  )
                )
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          selectedMode!=GraphMode.pointtransaction?(Row(
            children: [
              Expanded(
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startDate==null?'No Start Date Selected':startDate.toString().split(' ')[0]),
                    ElevatedButton(onPressed: _pickStartDate, child: const Text('Start')),

                  ],
                )
              ),
              Expanded(
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(endDate==null?'No End Date Selected':endDate.toString().split(' ')[0]),
                    ElevatedButton(onPressed: _pickEndDate, child: const Text('End')),
                  ],
                )
              )
            ],
          )):SizedBox(),
          const SizedBox(height: 16),
          DropdownButton<GraphMode>(
            value: selectedMode,
            onChanged: (value) async {
              if (value == null) return;

              await _loadGraph(value);
            },
            items: GraphMode.values.map((mode) {
              return DropdownMenuItem<GraphMode>(
                value: mode,
                child: Text(mode.name),
              );
            }).toList(),
          ),

        ],
      );
  }
}

enum GraphMode { daily, monthly, yearly, pointtransaction }
