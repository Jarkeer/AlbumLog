import 'package:flutter/material.dart';
import '../../models/album_model.dart';

class DetailScreen extends StatelessWidget {
  final AlbumModel album;

  const DetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(album.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  const SizedBox(height: 16),
                  Text(album.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.star_rate_rounded),
                    label: const Text('Calificar y Reseñar'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Discos Similares',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista Horizontal
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: albums.length, 
                      itemBuilder: (context, index) {
                        final similarAlbum = albums[index];
                        if (similarAlbum.id == album.id) return const SizedBox.shrink(); 
                        
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  similarAlbum.imagePath,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.album, size: 60),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                similarAlbum.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, 
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
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