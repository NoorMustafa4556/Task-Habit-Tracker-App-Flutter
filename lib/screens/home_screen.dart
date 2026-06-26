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
  List<String> todayCompleted = [];
  String dailyQuote = "Loading quote...";
  
  String _profileName = "Noor Mustafa";
  String _profileEmail = "noormustafa4556@gmail.com";

  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadQuote();
    _initNotifications();
    _loadHabitsAndCompletions();
    _loadProfileDetails();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _initNotifications() async {
    await _notificationService.initNotification();
  }

  void _loadProfileDetails() async {
    final name = await _storageService.getUsername();
    final email = await _storageService.getEmail();
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) _profileName = name;
        if (email != null && email.isNotEmpty) _profileEmail = email;
      });
    }
  }

  void _loadHabitsAndCompletions() async {
    final loadedHabits = await _storageService.getHabits();
    final loadedCompletions = await _storageService.getCompletionsForDate(_getTodayKey());
    
    if (mounted) {
      setState(() {
        if (loadedHabits != null && loadedHabits.isNotEmpty) {
          habits = loadedHabits;
        } else {
          habits = ["Drink Water", "Morning Walk", "Read 10 Pages", "Coding Practice"];
          _storageService.saveHabits(habits);
        }
        todayCompleted = loadedCompletions ?? [];
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

  void _toggleTodayCompletion(String habit) async {
    setState(() {
      if (todayCompleted.contains(habit)) {
        todayCompleted.remove(habit);
      } else {
        todayCompleted.add(habit);
      }
    });
    await _storageService.saveCompletionsForDate(_getTodayKey(), todayCompleted);
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

  void _showEditHabitDialog(String oldName, int index) {
    final textController = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Edit Habit", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Rename habit...",
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
                String newName = textController.text.trim();
                if (newName.isNotEmpty && newName != oldName) {
                  setState(() {
                    habits[index] = newName;
                    if (todayCompleted.contains(oldName)) {
                      todayCompleted.remove(oldName);
                      todayCompleted.add(newName);
                    }
                  });
                  await _storageService.saveHabits(habits);
                  await _storageService.saveCompletionsForDate(_getTodayKey(), todayCompleted);
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteHabitDialog(String habitName, int index) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Delete Habit", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to delete '$habitName'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () async {
                setState(() {
                  habits.removeAt(index);
                  todayCompleted.remove(habitName);
                });
                await _storageService.saveHabits(habits);
                await _storageService.saveCompletionsForDate(_getTodayKey(), todayCompleted);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.white)),
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
    
    int completedCount = todayCompleted.length;
    int totalCount = habits.length;
    bool hasPending = completedCount < totalCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Habits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: "Trigger Reminder",
            onPressed: _triggerReminder,
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(_profileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: Text(_profileEmail),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _profileName.isNotEmpty ? _profileName[0].toUpperCase() : "U",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                ),
              ),
              ListTile(
                leading: Icon(Icons.home_outlined, color: colorScheme.primary),
                title: const Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.history_outlined, color: colorScheme.primary),
                title: const Text("History Tracker", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/history');
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: colorScheme.primary),
                title: const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () async {
                  await _storageService.clearData();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
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
            // Daily Progress Banner Card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                color: theme.brightness == Brightness.light ? colorScheme.primaryContainer.withOpacity(0.3) : colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S PROGRESS",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You have completed $completedCount of $totalCount tasks today!",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasPending
                            ? "Please complete the remaining tasks before the day ends!"
                            : "Awesome! You've crushed all your habits for today! 🎉",
                        style: TextStyle(
                          color: hasPending ? Colors.orange[800] : colorScheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: totalCount > 0 ? (completedCount / totalCount) : 0.0,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Quote of the day banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                elevation: 2,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: theme.brightness == Brightness.light
                          ? [colorScheme.primaryContainer.withOpacity(0.3), colorScheme.primaryContainer.withOpacity(0.1)]
                          : [colorScheme.surface, colorScheme.surface.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.format_quote_rounded,
                        size: 32,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
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
                            const SizedBox(height: 4),
                            Text(
                              "\"$dailyQuote\"",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.3,
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
                "My Habits",
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
                        final habit = habits[index];
                        final isCompleted = todayCompleted.contains(habit);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Card(
                            elevation: 2,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              leading: InkWell(
                                onTap: () => _toggleTodayCompletion(habit),
                                child: CircleAvatar(
                                  backgroundColor: isCompleted
                                      ? colorScheme.primary.withOpacity(0.15)
                                      : Colors.grey[200],
                                  child: Icon(
                                    isCompleted
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isCompleted
                                        ? colorScheme.primary
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                              title: Text(
                                habit,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  color: isCompleted ? theme.hintColor : null,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  isCompleted ? "Completed Today" : "Pending",
                                  style: TextStyle(
                                    color: isCompleted ? colorScheme.primary : Colors.orange[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 20),
                                    tooltip: "Edit Habit",
                                    onPressed: () => _showEditHabitDialog(habit, index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                                    tooltip: "Delete Habit",
                                    onPressed: () => _showDeleteHabitDialog(habit, index),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 16,
                                    color: theme.hintColor,
                                  ),
                                ],
                              ),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/details',
                                arguments: habit,
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
