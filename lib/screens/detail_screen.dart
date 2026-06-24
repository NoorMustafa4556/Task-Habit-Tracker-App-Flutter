import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Home screen se habit ka naam receive karna
    final String habitName = (ModalRoute.of(context)?.settings.arguments as String?) ?? "Habit Details";

    return Scaffold(
      appBar: AppBar(title: Text(habitName)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Habit: $habitName", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Status: In Progress", style: TextStyle(color: Colors.orange, fontSize: 18)),
            const SizedBox(height: 20),
            const Text("Description: This is a detailed view of your habit tracking progress. Keep it up!"),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back to List"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
