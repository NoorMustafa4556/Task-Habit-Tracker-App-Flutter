import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  List<String> allHabits = [];
  List<String> completedHabits = [];
  
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  String _formatDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _formatDisplayDate(DateTime date) {
    final List<String> weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    final List<String> months = [
      "January", "February", "March", "April", "May", "June", 
      "July", "August", "September", "October", "November", "December"
    ];
    return "${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  void _loadData() async {
    final habitsList = await _storageService.getHabits() ?? [];
    final completionsList = await _storageService.getCompletionsForDate(_formatDateKey(_selectedDate)) ?? [];

    if (mounted) {
      setState(() {
        allHabits = habitsList;
        completedHabits = completionsList;
      });
    }
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadData();
    }
  }

  void _toggleCompletion(String habit) async {
    setState(() {
      if (completedHabits.contains(habit)) {
        completedHabits.remove(habit);
      } else {
        completedHabits.add(habit);
      }
    });
    await _storageService.saveCompletionsForDate(_formatDateKey(_selectedDate), completedHabits);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter and Sort: Completed habits first, then uncompleted
    final List<String> completedList = allHabits.where((h) => completedHabits.contains(h)).toList();
    final List<String> pendingList = allHabits.where((h) => !completedHabits.contains(h)).toList();
    final List<String> sortedHabits = [...completedList, ...pendingList];

    return Scaffold(
      appBar: AppBar(
        title: const Text("History Tracker"),
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
            // Date Selector Banner
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SELECTED DATE",
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDisplayDate(_selectedDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_month_outlined, color: colorScheme.primary),
                        tooltip: "Select Date",
                        onPressed: _selectDate,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Completions Summary Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sorted by Completion",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${completedList.length} of ${allHabits.length} Completed",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Habits List sorted
            Expanded(
              child: allHabits.isEmpty
                  ? Center(
                      child: Text(
                        "No habits created yet.",
                        style: TextStyle(color: theme.hintColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: sortedHabits.length,
                      itemBuilder: (context, index) {
                        final habit = sortedHabits[index];
                        final isCompleted = completedHabits.contains(habit);

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
                              leading: InkWell(
                                onTap: () => _toggleCompletion(habit),
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
                                  isCompleted ? "Completed" : "Pending",
                                  style: TextStyle(
                                    color: isCompleted ? colorScheme.primary : Colors.orange[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
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
    );
  }
}
