import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/services/firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class SummaryPage extends StatefulWidget {
  final String projectID;
  final String userID;

  const SummaryPage({super.key, required this.userID, required this.projectID});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final FirestoreService firestoreService = FirestoreService();
  double total = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Summary')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getExpenses(widget.userID, widget.projectID),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List expenseCollection = snapshot.data!.docs;

            // membuat dictanory tentang list
            Map<String, double> expenseData = {};
            for (var doc in expenseCollection) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String expenseName = data['name'];
              int hargaTotal = data['hargaTotal'];
              expenseData[expenseName] =
                  (expenseData[expenseName] ?? 0) + hargaTotal;
            }

            // Calculate total
            expenseData.forEach((key, value) {
              total += value;
            });
            print(total);

            // Create Pie Chart data
            List<PieChartSectionData> pieChartData =
                expenseData.entries.map((entry) {
              return PieChartSectionData(
                title: entry.key,
                value: entry.value,
                radius: 50,
                color: Colors.primaries[
                    expenseData.keys.toList().indexOf(entry.key) %
                        Colors.primaries.length],
              );
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: pieChartData,
                        centerSpaceRadius: 40,
                        sectionsSpace: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Total Expenses: \Rp ${total.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Expanded(
                    
                    child: ListView.builder(
                      itemCount: expenseData.length,
                      itemBuilder: (context, index) {
                        String name = expenseData.keys.elementAt(index);
                        double amount = expenseData.values.elementAt(index);
                        return Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.circle,
                                  color: Colors.primaries[
                                      index % Colors.primaries.length]),
                              title: Text(name),
                              subtitle:
                                  Text('Total: \Rp ${amount.toStringAsFixed(2)}'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No Expenses Found'));
          }
        },
      ),
    );
  }
}
