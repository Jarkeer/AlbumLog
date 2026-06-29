import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../../models/album_model.dart';
import 'detail_screen.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final TextEditingController _searchController = TextEditingController();
  
  final String _lastFmApiKey = '3892c0bae522895e4cef36d817718d35'; 
  
  bool _isLoading = false;
  List<dynamic> _albumList = [];
  String _mensaje = "Busca tu álbum o artista favorito...";

  Future<void> _searchAlbums() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _mensaje = "Buscando en la red...";
      _albumList = [];
    });

    try {
      final String encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse('http://ws.audioscrobbler.com/2.0/?method=album.search&album=$encodedQuery&api_key=$_lastFmApiKey&format=json&limit=15');
      final response = await http
        .get(url)
        .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> albums = data['results']?['albummatches']?['album'] ?? [];
        
        if (albums.isNotEmpty) {
           final validAlbums = albums.where((a) => a['name'] != '(null)' && a['name'] != '').toList();
           setState(() {
            _albumList = validAlbums;
            _mensaje = ""; // Limpiamos el mensaje si hay resultados
          });
        } else {
          setState(() => _mensaje = "No se encontraron álbumes.");
        }
      }
     else {
        setState(() {
            _mensaje = "Servidor no disponible.";
        });
      }
    } on TimeoutException {
      setState(() => _mensaje = "Tiempo de espera agotado.");
    } catch (e) {
      setState(() => _mensaje = "Fallo de conexión.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Extrae la imagen del JSON de Last.fm
  String _getImageUrl(List<dynamic>? images, String size) {
    if (images == null || images.isEmpty) return '';
    try {
      final imageObj = images.firstWhere((img) => img['size'] == size, orElse: () => images.last);
      return imageObj['#text'] ?? '';
    } catch (e) {
      return '';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explorar Discos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar álbum o artista...',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.deepPurple, width: 2.0),
                  borderRadius: BorderRadius.circular(10)
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                  onPressed: _searchAlbums,
                ),
              ),
              onSubmitted: (_) => _searchAlbums(), 
            ),
          ),
          
          // 2. Estado de carga o mensajes
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          else if (_mensaje.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(_mensaje, style: const TextStyle(color: Colors.grey, fontSize: 16)),
            ),

          // 3. Lista de Resultados Dinámica
          Expanded(
            child: ListView.builder(
              itemCount: _albumList.length,
              itemBuilder: (context, index) {
                final album = _albumList[index];
                final String albumName = album['name'] ?? 'Desconocido';
                final String artistName = album['artist'] ?? 'Artista desconocido';
                final String imageUrl = _getImageUrl(album['image'], 'large');
                final String imageExtraLargeUrl = _getImageUrl(album['image'], 'extralarge');

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: imageUrl.isNotEmpty 
                        ? Image.network(imageUrl,width: 50,height: 50,fit: BoxFit.cover,errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),)
                        : const Icon(Icons.album, color: Colors.grey, size: 50),
                    title: Text(albumName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(artistName, style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.deepPurpleAccent),
                    onTap: () {
                      
                      final selectedAlbum = AlbumModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(), 
                        title: albumName,
                        artist: artistName,
                        imagePath: imageExtraLargeUrl.isNotEmpty ? imageExtraLargeUrl : '', 
                        description: 'Álbum obtenido desde la base de datos de Last.fm', 
                        );

                      // Navegamos al detalle original
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(album: selectedAlbum),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}