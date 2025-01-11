import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/services/firestore.dart';
import 'package:expense_tracker/pages/expense_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  //DocID dari userID
  final String userID;

  const HomePage({super.key, required this.userID});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController nameController = TextEditingController();

  //dialog box buat bikin project
  void addNewProject({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: nameController,
              ),
              actions: [
                //button to save
                ElevatedButton(
                    onPressed: () {
                      //add new project
                      if (docID == null) {
                        firestoreService.addProject(
                            widget.userID, nameController.text);
                      }

                      //update
                      else {
                        firestoreService.updateProject(
                            widget.userID, docID, nameController.text);
                      }

                      //clear textcontroller
                      nameController.clear();

                      //close box
                      Navigator.pop(context);
                    },
                    child: const Text('add'))
              ],
            ));
  }

  //logout
  void logOut() async {
    await FirebaseAuth.instance.signOut();
    // Navigate back to the login screen
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Expense Tracker'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: logOut,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addNewProject,
          child: const Icon(Icons.add),
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getProject(widget.userID),
            builder: (context, snapshot) {
              //if we have data get all docs
              if (snapshot.hasData) {
                List projectCollection = snapshot.data!.docs;

                //display as list
                return ListView.builder(
                  itemCount: projectCollection.length,
                  itemBuilder: (context, index) {
                    //get each individual doc
                    DocumentSnapshot document = projectCollection[index];
                    String docID = document.id;

                    //get project from each doc
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    String projectName = data['name'];

                    //display as a list title
                    return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpensePage(
                                  userID: widget.userID, projectID: docID),
                            ),
                          );
                        },
                        title: Text(projectName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //Update button
                            IconButton(
                              onPressed: () => addNewProject(docID: docID),
                              icon: const Icon(Icons.settings),
                            ),

                            //delete button
                            IconButton(
                              onPressed: () => firestoreService.deleteProject(
                                  widget.userID, docID),
                              icon: const Icon(Icons.delete),
                            ),

                            //open project button
                          ],
                        ));
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
