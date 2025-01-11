import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expense_tracker/services/auth.dart';
import 'package:expense_tracker/pages/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final passwordController = TextEditingController();

  final usernameController = TextEditingController();

  void signUserIn() {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });

    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: usernameController.text, password: passwordController.text)
        .then((value) {
      Navigator.pop(context); 
      print("User signed in");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    }).catchError((error) {
      Navigator.pop(context); 
      print("Failed to sign in: $error");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Failed to sign in"),
            content: Text("Error: $error"),
          );
        },
      );
    });

    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: usernameController.text, password: passwordController.text)
        .then((value) {
      Navigator.pop(context); // Dismiss the progress indicator
      print("User signed in");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthScreen()),
      );
    }).catchError((error) {
      Navigator.pop(context); // Dismiss the progress indicator
      print("Failed to sign in: $error");
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Failed to sign in"),
            content: Text("Error: $error"),
          );
        },
      );
    });
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
              "hello user",
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
          button(onTap: signUserIn, text: "Sign In"),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterScreen()),
                  );
                },
                child: Text(
                  "Sign Up",
                ),
              )
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    ));
  }
}

class field extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const field({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: const Color.fromARGB(255, 16, 15, 15))),
        style: TextStyle(color: const Color.fromARGB(255, 92, 57, 94)),
      ),
    );
  }
}

class button extends StatelessWidget {
  final Function()? onTap;
  final String text;

  const button({super.key, required this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.symmetric(horizontal: 65),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
