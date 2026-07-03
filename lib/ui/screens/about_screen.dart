import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(
              Icons.album_rounded,
              size: 100,
              color: Colors.deepPurpleAccent,
            ),
            const SizedBox(height: 20),

            Text(
              l10n.appTitle,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              l10n.version,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            Text(
              l10n.aboutDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 40),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.code),
              title: Text(l10n.developedBy),
              subtitle: const Text('Javier Molina, Martin Alvarez'),
            ),
          ],
        ),
      ),
    );
  }
}