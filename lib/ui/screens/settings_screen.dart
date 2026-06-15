import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/preferences_viewmodel.dart';
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: Consumer<PreferencesViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Aspecto Visual',
                  style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                ),
              ),
              SwitchListTile(
                title: const Text('Modo Oscuro'),
                subtitle: const Text('Cambia el tema de toda la aplicación'),
                secondary: const Icon(Icons.dark_mode),
                activeColor: Colors.deepPurpleAccent,
                value: viewModel.isDarkMode,
                onChanged: (bool value) => viewModel.toggleDarkMode(value),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Cuenta',
                  style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Idioma'),
                subtitle: const Text('Español (Chile)'),
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