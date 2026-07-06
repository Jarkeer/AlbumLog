import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/preferences_viewmodel.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Consumer<PreferencesViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  l10n.visualAspect,
                  style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                title: Text(l10n.darkMode),
                subtitle: Text(l10n.changeTheme),
                secondary: const Icon(Icons.dark_mode),
                activeColor: Colors.deepPurpleAccent,
                value: viewModel.isDarkMode,
                onChanged: (bool value) => viewModel.toggleDarkMode(value),
              ),
              const Divider(),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  l10n.account,
                  style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(l10n.language),
                subtitle: Text(l10n.spanishChile),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Futura implementación
                },
              ),
            ],
          );
        },
      ),
    );
  }
}