import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:album_log/viewsmodel/preferences_viewmodel.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuchamos el ViewModel
    final prefsVM = Provider.of<PreferencesViewModel>(context);
    final theme = Theme.of(context);

    // Controlador para el campo de texto
    final TextEditingController nameController = TextEditingController(text: prefsVM.userName);

    if (prefsVM.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perfil', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de Usuario',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2.0),
                ),
              ),
              onSubmitted: (value) {
                 prefsVM.updateUserName(value);
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nombre guardado'), backgroundColor: Colors.deepPurple)
                 );
              },
            ),
            const SizedBox(height: 32),
            Text('Apariencia', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Modo Oscuro'),
              subtitle: const Text('Cambiar el tema de la aplicación'),
              value: prefsVM.isDarkMode,
              activeColor: Colors.deepPurple,
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