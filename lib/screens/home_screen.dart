import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> habits = const ["Drink Water", "Morning Walk", "Read 10 Pages"];
  String dailyQuote = "Loading quote...";
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadQuote();
  }

  void _loadQuote() async {
    String quote = await _apiService.fetchQuote();
    if (mounted) {
      setState(() {
        dailyQuote = quote;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Habits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.deepPurple[50], borderRadius: BorderRadius.circular(10)),
            child: Text("Quote of the Day:\n\"$dailyQuote\"", style: const TextStyle(fontStyle: FontStyle.italic)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(habits[index]),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.pushNamed(context, '/details', arguments: habits[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
