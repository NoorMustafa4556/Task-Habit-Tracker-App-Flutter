import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Data Save karne ke liye
  Future<void> saveUsername(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', name);
  }

  // Data Read karne ke liye
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  // Data Clear karne ke liye (Logout ke waqt)
  Future<void> clearData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
