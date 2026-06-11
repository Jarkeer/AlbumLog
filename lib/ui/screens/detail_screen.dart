import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class DetailScreen extends StatelessWidget {
  // Ahora recibe un Map de iTunes en vez de AlbumModel local
  final Map<String, dynamic> album;

  const DetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final String nombre = album['collectionName'] ?? 'Desconocido';
    final String artista = album['artistName'] ?? 'Artista desconocido';
    final String? imagenUrl = album['artworkUrl100']?.replaceAll('100x100', '600x600');
    final int tracks = album['trackCount'] ?? 0;
    final String genero = album['primaryGenreName'] ?? '';
    final String fechaRaw = album['releaseDate'] ?? '';
    final String anio = fechaRaw.isNotEmpty ? fechaRaw.substring(0, 4) : '';

    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del álbum
            if (imagenUrl != null)
              Image.network(
                imagenUrl,
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombre, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(artista, style: const TextStyle(fontSize: 20, color: Colors.grey)),
                  const SizedBox(height: 8),

                  // Info del álbum
                  Row(
                    children: [
                      if (anio.isNotEmpty) ...[
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(anio, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                      ],
                      if (tracks > 0) ...[
                        const Icon(Icons.music_note, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('$tracks canciones', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(width: 16),
                      ],
                      if (genero.isNotEmpty) ...[
                        const Icon(Icons.category, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(genero, style: const TextStyle(color: Colors.grey)),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Botones de acción
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star_rate_rounded),
                    label: const Text('Calificar y Reseñar'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Share.share('🎧 Mira este álbum en AlbumLog!\n$nombre de $artista');
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}