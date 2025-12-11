import 'package:blood_app/Providers/ThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_4),
            title: const Text("App Theme"),
            subtitle: Text(
              themeProvider.themeMode == ThemeMode.system
                  ? "System Default"
                  : themeProvider.themeMode == ThemeMode.dark
                  ? "Dark Mode"
                  : "Light Mode",
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              _showThemeDialog(context, themeProvider);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Theme"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text("System Default"),
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  themeProvider.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text("Light Mode"),
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  themeProvider.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text("Dark Mode"),
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (val) {
                  themeProvider.setTheme(val!);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
