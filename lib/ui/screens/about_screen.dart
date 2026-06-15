import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de AlbumLog'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.album_rounded, size: 100, color: Colors.deepPurpleAccent),
            const SizedBox(height: 20),
            const Text(
              'AlbumLog',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Text('Versión 1.0.0 (Beta Testing)', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            const Text(
              'AlbumLog es el diario personal para los amantes de la música. '
              'Nuestra misión es permitir que cada melómano pueda catalogar, '
              'puntuar y compartir sus descubrimientos musicales de forma sencilla.\n\n'
              ,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.code),
              title: Text('Desarrollado por'),
              subtitle: Text('Javier Molina '),
            ),
          ],
        ),
      ),
    );
  }
}