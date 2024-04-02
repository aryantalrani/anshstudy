import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            SwitchListTile(
              title: Text('Enable Notifications'),
              subtitle: Text('Receive notifications for important updates.'),
              value: true, // This should ideally be linked to a state management solution or a settings model.
              onChanged: (bool value) {
                // Update the state of the notification setting
              },
            ),
            ListTile(
              title: Text('Account'),
              subtitle: Text('Manage your account settings'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to account settings page
              },
            ),
            ListTile(
              title: Text('Privacy'),
              subtitle: Text('Review privacy policy and settings'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to privacy settings page
              },
            ),
            ListTile(
              title: Text('Help & Feedback'),
              subtitle: Text('Get help and send feedback'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to help and feedback page
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
