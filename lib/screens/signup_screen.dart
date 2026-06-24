import 'package:flutter/material.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: "Username")),
            const TextField(decoration: InputDecoration(labelText: "Email")),
            const TextField(decoration: InputDecoration(labelText: "Password"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text("Sign Up"),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text("Already have an account? Login"),
            )
          ],
        ),
      ),
    );
  }
}
