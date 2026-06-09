import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/preferences_viewmodel.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefsVM = Provider.of<PreferencesViewModel>(context);
    final theme = Theme.of(context);
    final TextEditingController nameController = TextEditingController(text: prefsVM.userName);

    if (prefsVM.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perfil', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Nombre de Usuario',
                labelStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 2.0)),
              ),
              onSubmitted: (value) {
                 prefsVM.updateUserName(value);
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre guardado', style: TextStyle(color: Colors.white)), backgroundColor: Colors.deepPurple)
                 );
              },
            ),
            const SizedBox(height: 32),
            Text('Apariencia', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Modo Oscuro', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Cambiar el tema de la aplicación', style: TextStyle(color: Colors.grey)),
              value: prefsVM.isDarkMode,
              activeThumbColor: Colors.deepPurpleAccent,
              onChanged: (bool value) {
                prefsVM.toggleTheme(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}