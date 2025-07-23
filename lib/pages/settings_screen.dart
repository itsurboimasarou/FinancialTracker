import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedTheme = 'System'; 

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.language_outlined, color: Theme.of(context).colorScheme.primary),
          title: const Text('Languages'),
          subtitle: const Text('English'), 
          onTap: () {

          },
        ),
        ListTile(
          leading: Icon(Icons.straighten_outlined, color: Theme.of(context).colorScheme.primary),
          title: const Text('Units'),
          subtitle: const Text('Metric, USD'), 
          onTap: () {
          },
        ),
        ListTile(
          leading: Icon(Icons.brightness_6_outlined, color: Theme.of(context).colorScheme.primary),
          title: const Text('Theme'),
          trailing: DropdownButton<String>(
            value: _selectedTheme,
            underline: Container(),
            items: <String>['Light', 'Dark', 'System'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedTheme = newValue;
              });
            },
          ),
        ),
        ListTile(
          leading: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.primary),
          title: const Text('Notification'),
          trailing: Switch( 
            value: true, 
            onChanged: (bool value) {
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          onTap: () {

          },
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
          title: const Text('About'),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Testing Financial App'),
                content: const Text('xdk_2.9.2_lumia_s1 v1.0.0\nDeveloped with Flutter.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}