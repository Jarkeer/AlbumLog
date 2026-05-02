import 'package:flutter/material.dart';
import '../../models/album_model.dart';

class DetailView extends StatelessWidget {
  final AlbumModel album;

  const DetailView({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(album.title)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cargamos la imagen local desde la ruta que viene en el modelo
            Image.asset(
              album.imagePath,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(album.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(album.artist, style: const TextStyle(fontSize: 20, color: Colors.grey)),
                  const SizedBox(height: 20),
                  Text(album.description, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}