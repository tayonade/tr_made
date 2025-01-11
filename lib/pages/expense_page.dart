import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/services/firestore.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/pages/summary.dart';

class ExpensePage extends StatefulWidget {
  //DocID dari Project dan user
  final String projectID;
  final String userID;
  const ExpensePage({super.key, required this.userID, required this.projectID});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController totalContoller = TextEditingController();
  final int itemTotal = 0;

  //dialog box buat bikin expense
  void openExBox({String? docID, Map<String, dynamic>? currentData}) {
    //kalo update textfield = data di expense itu
    if (docID != null && currentData != null) {
      nameController.text = currentData['name'];
      priceController.text = currentData['price'].toString();
      totalContoller.text = currentData['total'].toString();
    } else {
      nameController.clear();
      priceController.clear();
      totalContoller.clear();
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Item Name'),
                  ),
                  TextField(
                    controller: nameController,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Item Price'),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: priceController,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text('Number of Item'),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: totalContoller,
                  )
                ],
              ),
              actions: [
                //button to save
                ElevatedButton(
                    onPressed: () {
                      //add new expense
                      if (docID == null) {
                        firestoreService.addExpense(
                            widget.userID,
                            widget.projectID,
                            nameController.text,
                            int.parse(priceController.text),
                            int.parse(totalContoller.text),
                            (int.parse(priceController.text) *
                                int.parse(totalContoller.text)));
                      }

                      //update
                      else {
                        String strHarga = priceController.text;
                        String jumlahbarang = totalContoller.text;
                        int hargaInput = int.parse(strHarga);
                        int jumlahbarangint = int.parse(jumlahbarang);
                        firestoreService.updateExpense(
                            widget.userID,
                            widget.projectID,
                            docID,
                            nameController.text,
                            hargaInput,
                            jumlahbarangint,
                            (int.parse(priceController.text) *
                                int.parse(totalContoller.text)));
                      }

                      //clear textcontroller
                      nameController.clear();
                      priceController.clear();
                      totalContoller.clear();

                      //close box
                      Navigator.pop(context);
                    },
                    child: const Text('add'))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracker'),
          actions: [
            IconButton(
              icon: const Icon(Icons.pie_chart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SummaryPage(
                        userID: widget.userID, projectID: widget.projectID),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          //add expense
          onPressed: openExBox,
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream:
                firestoreService.getExpenses(widget.userID, widget.projectID),
            builder: (context, snapshot) {
              //if we have data get all docs
              if (snapshot.hasData) {
                List expenseCollection = snapshot.data!.docs;

                //display as list
                return ListView.builder(
                  itemCount: expenseCollection.length,
                  itemBuilder: (context, index) {
                    //get each individual doc
                    DocumentSnapshot document = expenseCollection[index];
                    String docID = document.id;

                    //get expense from each doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String expenseName = data['name'];
                    int expensePrice = data['price'];
                    int itemTotal = data['total'];
                    int hargaTotalint = data['hargaTotal'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      elevation: 4, // Adds shadow for depth
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Rounded corners for a polished look
                      ),

                      //list
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10.0),
                        title: Text(
                          expenseName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Jumlah Barang: ${itemTotal.toStringAsFixed(0)}'),
                            Text(
                                'Harga Barang: Rp ${expensePrice.toStringAsFixed(2)}'),
                          ],
                        ),

                        //trail
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total Harga Barang: Rp ${hargaTotalint.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            IconButton(
                              onPressed: () =>
                                  openExBox(docID: docID, currentData: data),
                              icon: const Icon(Icons.settings),
                            ),
                            IconButton(
                              onPressed: () => firestoreService.deleteExpense(
                                  widget.userID, widget.projectID, docID),
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              //if no data
              else {
                return const Text("Belum ada Expense");
              }
            }));
  }
}
