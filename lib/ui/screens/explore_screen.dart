import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _albumList = [];
  bool _isLoading = false;
  String _mensaje = '';

  Future<void> _buscarAlbumes(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _albumList = [];
      _mensaje = 'Buscando...';
    });

    try {
      final encoded = Uri.encodeComponent(query.trim());
      final List<dynamic> allResults = [];

      
      final r1 = await http.get(Uri.parse(
        'https://itunes.apple.com/search?term=$encoded&entity=album&limit=200&country=US',
      ));
      if (r1.statusCode == 200) {
        allResults.addAll(json.decode(r1.body)['results'] ?? []);
      }

      
      final r2 = await http.get(Uri.parse(
        'https://itunes.apple.com/search?term=$encoded&entity=musicArtist&limit=3&country=US',
      ));
      if (r2.statusCode == 200) {
        final artists = json.decode(r2.body)['results'] ?? [];

        // Búsqueda 3: discografía completa de cada artista encontrado
        final futures = (artists as List).map((artist) => http.get(Uri.parse(
          'https://itunes.apple.com/lookup?id=${artist['artistId']}&entity=album&limit=200&country=US',
        ))).toList();

        final discografias = await Future.wait(futures);
        for (final r in discografias) {
          if (r.statusCode == 200) {
            final albums = (json.decode(r.body)['results'] ?? [])
                .where((r) => r['wrapperType'] == 'collection')
                .toList();
            allResults.addAll(albums);
          }
        }
      }

      // Filtrado
      final Set<String> vistos = {};
      final List<dynamic> filtrados = [];

      for (var album in allResults) {
        final String tipo = album['collectionType'] ?? '';
        final String nombre = (album['collectionName'] ?? '').toLowerCase();
        final String artista = (album['artistName'] ?? '').toLowerCase();
        final int tracks = album['trackCount'] ?? 0;
        final String id = album['collectionId']?.toString() ?? '';

        bool esAlbum = tipo == 'Album' || tipo == 'Compilation';
        bool noEsSingle = tracks != 1;
        bool noEsBasura = !nombre.contains('tribute') &&
            !nombre.contains('karaoke') &&
            !nombre.contains('lullaby') &&
            !nombre.contains('renditions') &&
            !nombre.contains('cover') &&
            !nombre.contains('- ep') &&
            !nombre.contains('- single') &&
            !artista.contains('tribute') &&
            !artista.contains('vsq');
        bool noRepetido = id.isNotEmpty && !vistos.contains(id);

        if (esAlbum && noEsSingle && noEsBasura && noRepetido) {
          vistos.add(id);
          filtrados.add(album);
        }
      }

      setState(() {
        _albumList = filtrados;
        _mensaje = filtrados.isEmpty
            ? 'No se encontraron álbumes para "$query"'
            : '${filtrados.length} álbumes encontrados';
      });
    } catch (e) {
      setState(() => _mensaje = 'Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
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
              decoration: InputDecoration(
                hintText: 'Buscar álbum, artista...',
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.deepPurple),
                  onPressed: () => _buscarAlbumes(_searchController.text),
                ),
              ),
              onSubmitted: _buscarAlbumes,
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          else if (_mensaje.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_mensaje,
                style: const TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold),
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: _albumList.length,
              itemBuilder: (context, index) {
                final album = _albumList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: album['artworkUrl100'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(album['artworkUrl100'], width: 50, height: 50, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.album, size: 50, color: Colors.grey),
                    title: Text(album['collectionName'] ?? 'Desconocido',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    subtitle: Text(album['artistName'] ?? '',
                      style: const TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.deepPurpleAccent),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(album: album),
                      ),
                    ),
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