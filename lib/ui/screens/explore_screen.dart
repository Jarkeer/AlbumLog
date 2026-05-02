import 'package:flutter/material.dart';
import '../../models/album_model.dart';
import 'detail_screen.dart';


class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Discos')),
      body: ListView.builder(
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final AlbumModel currentAlbum = albums[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Image.asset(
                currentAlbum.imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.album),
              ),
              title: Text(currentAlbum.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(currentAlbum.artist),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailView(album: currentAlbum),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}