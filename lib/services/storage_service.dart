import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Save Username
  Future<void> saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  // Read Username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // Save Email
  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  // Read Email
  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  // Save Theme Mode (light, dark, system)
  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }

  // Read Theme Mode
  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('theme_mode');
  }

  // Save Habits List
  Future<void> saveHabits(List<String> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('habits', habits);
  }

  // Read Habits List
  Future<List<String>?> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('habits');
  }

  // Save Completed Habits for a specific date (dateStr format: yyyy-MM-dd)
  Future<void> saveCompletionsForDate(String dateStr, List<String> completedHabits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completions_$dateStr', completedHabits);
  }

  // Read Completed Habits for a specific date
  Future<List<String>?> getCompletionsForDate(String dateStr) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('completions_$dateStr');
  }

  // Data Clear (Logout)
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
