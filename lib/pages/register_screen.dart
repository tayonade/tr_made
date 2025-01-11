import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/pages/welcome_Screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final passwordController = TextEditingController();

  final usernameController = TextEditingController();

  void Userregister() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: usernameController.text, password: passwordController.text)
        .then((value) {
      print("User registered");
      addUser(usernameController.text, passwordController.text);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Failed to register"),
            content: Text("Error: $error"),
          );
        },
      );
    });
  }

  Future<void> addUser(String email, String pass) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return users
        .add({
          'email': email,
          'password': pass,
        })
        .then((value) => print("User added successfully!"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_rounded,
              size: 100,
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 20),
              child: Text(
                "please register",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            field(
              controller: usernameController,
              hintText: "username or email",
              obscureText: false,
            ),
            SizedBox(
              height: 20,
            ),
            field(
              controller: passwordController,
              hintText: "password",
              obscureText: true,
            ),
            SizedBox(
              height: 20,
            ),
            button(onTap: Userregister, text: "Register"),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "have an account?",
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    );
                  },
                  child: Text(
                    "Log in",
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
