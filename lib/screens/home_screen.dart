import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> habits = [];
  String dailyQuote = "Loading quote...";
  
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _initNotifications();
    _loadHabits();
  }

  void _initNotifications() async {
    await _notificationService.initNotification();
  }

  void _loadHabits() async {
    final loadedHabits = await _storageService.getHabits();
    if (mounted) {
      setState(() {
        if (loadedHabits != null && loadedHabits.isNotEmpty) {
          habits = loadedHabits;
        } else {
          habits = ["Drink Water", "Morning Walk", "Read 10 Pages", "Coding Practice"];
          _storageService.saveHabits(habits);
        }
      });
    }
  }

  void _loadQuote() async {
    String quote = await _apiService.fetchQuote();
    if (mounted) {
      setState(() {
        dailyQuote = quote;
      });
    }
  }

  void _triggerReminder() async {
    await _notificationService.showNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Reminder Notification Sent!"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _showAddHabitDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add New Habit", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Enter habit name...",
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: theme.colorScheme.primary)),
            ),
            ElevatedButton(
              onPressed: () async {
                String habitName = textController.text.trim();
                if (habitName.isNotEmpty) {
                  setState(() {
                    habits.add(habitName);
                  });
                  await _storageService.saveHabits(habits);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Habits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: "Trigger Reminder",
            onPressed: _triggerReminder,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: "Settings",
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.light
                ? [colorScheme.primary.withOpacity(0.05), Colors.white]
                : [colorScheme.primary.withOpacity(0.02), Colors.black],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Quote of the day banner
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: theme.brightness == Brightness.light
                          ? [colorScheme.primaryContainer.withOpacity(0.5), colorScheme.primaryContainer.withOpacity(0.2)]
                          : [colorScheme.surface, colorScheme.surface.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 40,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "QUOTE OF THE DAY",
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "\"$dailyQuote\"",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Title for habits section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                "My Routines",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            // Habits List
            Expanded(
              child: habits.isEmpty
                  ? Center(
                      child: Text(
                        "No habits added yet. Press '+' to add one!",
                        style: TextStyle(color: theme.hintColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                habits[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                "Status: In Progress",
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: theme.hintColor,
                              ),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/details',
                                arguments: habits[index],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHabitDialog,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        tooltip: "Add Habit",
        child: const Icon(Icons.add),
      ),
    );
  }
}
