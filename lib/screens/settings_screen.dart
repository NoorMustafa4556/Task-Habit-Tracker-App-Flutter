import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationEnabled = true;
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Noor Mustafa"),
            accountEmail: Text("noor@example.com"),
            currentAccountPicture: CircleAvatar(child: Icon(Icons.person)),
          ),
          SwitchListTile(
            title: const Text("Enable Notifications"),
            secondary: const Icon(Icons.notifications),
            value: _isNotificationEnabled,
            onChanged: (bool value) {
              setState(() {
                _isNotificationEnabled = value;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text("App Theme"),
            subtitle: const Text("Light Mode"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () async {
              await _storageService.clearData();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}
