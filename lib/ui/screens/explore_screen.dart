import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/album_model.dart';
import '../../services/lastfm_service.dart';
import 'detail_screen.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final TextEditingController _searchController = TextEditingController();

  // Servicio de Last.fm
  final LastFmService _lastFmService = LastFmService();

  bool _isLoading = false;
  List<dynamic> _albumList = [];
  String _mensaje = "";

  Future<void> _searchAlbums() async {
    final String query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _mensaje = AppLocalizations.of(context)!.searching;
      _albumList = [];
    });

    try {
      final List<dynamic> results =
          await _lastFmService.searchAlbums(query);

      setState(() {
        _albumList = results;

        if (_albumList.isEmpty) {
          _mensaje = AppLocalizations.of(context)!.noAlbumsFound;
        } else {
          _mensaje = "";
        }
      });
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;

      String error = e.toString();

      if (error.contains("Servidor")) {
        _mensaje = l10n.serverUnavailable;
      } else if (error.contains("Timeout")) {
        _mensaje = l10n.requestTimeout;
      } else if (error.contains("Conexión")) {
        _mensaje = l10n.connectionFailed;
      } else {
        _mensaje = error.replaceAll("Exception: ", "");
      }

      setState(() {});
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
    final l10n = AppLocalizations.of(context)!;

    if (!_isLoading &&
        _albumList.isEmpty &&
        _mensaje.isEmpty) {
      _mensaje = l10n.searchYourFavoriteAlbum;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exploreAlbums),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: l10n.searchAlbumArtist,
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.deepPurple,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.deepPurple,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.deepPurpleAccent,
                  ),
                  onPressed: _searchAlbums,
                ),
              ),
              onSubmitted: (_) => _searchAlbums(),
            ),
          ),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                color: Colors.deepPurple,
              ),
            )
          else if (_mensaje.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                _mensaje,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              itemCount: _albumList.length,
              itemBuilder: (context, index) {
                final album = _albumList[index];

                final String albumName =
                    album['name'] ?? l10n.unknown;

                final String artistName =
                    album['artist'] ?? l10n.unknownArtist;

                final String imageUrl = _lastFmService.getImageUrl(
                  album['image'],
                  'large',
                );

                final String imageExtraLargeUrl =
                    _lastFmService.getImageUrl(
                  album['image'],
                  'extralarge',
                );

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(
                            Icons.album,
                            color: Colors.grey,
                            size: 50,
                          ),
                    title: Text(
                      albumName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      artistName,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.deepPurpleAccent,
                    ),
                    onTap: () {
                      final selectedAlbum = AlbumModel(
                        id: DateTime.now()
                            .millisecondsSinceEpoch
                            .toString(),
                        title: albumName,
                        artist: artistName,
                        imagePath: imageExtraLargeUrl.isNotEmpty
                            ? imageExtraLargeUrl
                            : '',
                        description: l10n.lastFmDescription,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(album: selectedAlbum),
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