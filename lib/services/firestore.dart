import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
   final FirebaseFirestore db = FirebaseFirestore.instance;


  CollectionReference getUserCollection(String userID) {
    return db.collection('users').doc(userID).collection('project');
  }
  
  //create project
Future<void> addProject(String userID, String name) {
    return getUserCollection(userID).add({
      'name': name,
      'timestamp': Timestamp.now(),
    });
  }

  //read project
  Stream<QuerySnapshot> getProject(String userID) {
    return getUserCollection(userID)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }


  //update project (ganti nama)
   Future<void> updateProject(String userID, String docID, String newName) {
    return getUserCollection(userID).doc(docID).update({
      'name': newName,
    });
  }
  //delete project
  Future<void> deleteProject(String userID, String docID) {
    return getUserCollection(userID).doc(docID).delete();
  }
  //expense
  //sub-collection 
  Stream<QuerySnapshot> getExpenses(String userID, String projectID) {
    return db
        .collection('users')
        .doc(userID)
        .collection('project')
        .doc(projectID)
        .collection('expenses')
        .orderBy('hargaTotal', descending: true)
        .snapshots();
  }

  //update expense
    Future<void> updateExpense(String userID, String projectID, String expenseID, String name, int itemPrice, int quantity, int totalPrice) {
    return db
        .collection('users')
        .doc(userID)
        .collection('project')
        .doc(projectID)
        .collection('expenses')
        .doc(expenseID)
        .update({
          'name': name,
          'price': itemPrice,
          'total': quantity,
          'hargaTotal': totalPrice,
    });
  }


  //buat sub-collection expense
    Future<void> addExpense(String userID, String projectID, String name, int itemPrice, int quantity, int totalPrice) {
    return db
        .collection('users')
        .doc(userID)
        .collection('project')
        .doc(projectID)
        .collection('expenses')
        .add({
          'name': name,
          'price': itemPrice,
          'total': quantity,
          'hargaTotal': totalPrice,
        });
  }

  //delete expense
Future<void> deleteExpense(String userID, String projectID, String expenseID) {
    return db
        .collection('users')
        .doc(userID)
        .collection('project')
        .doc(projectID)
        .collection('expenses')
        .doc(expenseID)
        .delete();
  }
}