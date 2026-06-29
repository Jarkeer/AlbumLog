import 'package:album_log/viewsmodel/preferences_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; 
import 'package:provider/provider.dart';
import '../../models/album_model.dart';
import '../../models/review_model.dart'; 
import '../../services/local_preferences_services.dart';

class DetailScreen extends StatefulWidget {
  final AlbumModel album;

  const DetailScreen({super.key, required this.album});
  
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cargarRatingGuardado();
  }

  Future<void> _cargarRatingGuardado() async {
    final ratingGuardado = await LocalPreferencesService().getAlbumRating(widget.album.id);
    if (mounted) {
      setState(() {
        _rating = ratingGuardado;
      });
    }
  }

  @override
  void dispose() {
    _reviewController.dispose(); 
    super.dispose();
  }

  void _compartirAlbum() {
    Share.share(
      '¡Mira este tremendo disco que encontré en AlbumLog! \n'
      '${widget.album.title} de ${widget.album.artist}\n\n'
      '¡Descarga la app y arma tu colección!'
    );
  }

  Future<void> _guardarCalificacion() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona al menos 1 estrella')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final reviewText = _reviewController.text.trim();
      
      // Instanciamos el modelo con los datos recolectados en la vista
      final newReview = ReviewModel(
        albumId: widget.album.id,
        albumTitle: widget.album.title,
        rating: _rating,
        reviewText: reviewText.isNotEmpty ? reviewText : null,
      );

      
      await LocalPreferencesService().saveAlbumReview(newReview);
      
      if (mounted) {
        Provider.of<PreferencesViewModel>(context, listen: false).refreshAlbums();
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Reseña guardada en tu colección local!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar localmente: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.album.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Compartir álbum',
            onPressed: _compartirAlbum,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            widget.album.imagePath.startsWith('http')
                ? Image.network(
                    widget.album.imagePath,
                    width: double.infinity,
                    height: 350,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                  )
                : Image.asset(
                    widget.album.imagePath,
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
                  Text(widget.album.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text(widget.album.artist, style: const TextStyle(fontSize: 20, color: Colors.grey)),
                  const SizedBox(height: 16),
                  Text(widget.album.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                  
                  // PANEL DE CALIFICACIÓN Y RESEÑA
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '¿Qué te pareció este disco?',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        
                        // Sistema de Estrellas Interactivo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return IconButton(
                              iconSize: 40,
                              icon: Icon(
                                index < _rating ? Icons.star : Icons.star_border,
                                color: index < _rating ? Colors.amber : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _rating = index + 1;
                                });
                              },
                            );
                          }),
                        ),
                        const SizedBox(height: 10),

                        // Campo de texto para la reseña
                        TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          maxLength: 300,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Escribe tu reseña (opcional)',
                            labelStyle: const TextStyle(color: Colors.grey),
                            alignLabelWithHint: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade700),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Botón de Guardar en Memoria Local
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _guardarCalificacion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text(
                                    'Publicar Reseña',
                                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Discos Similares',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: albums.length, 
                      itemBuilder: (context, index) {
                        final similarAlbum = albums[index];
                        if (similarAlbum.id == widget.album.id) return const SizedBox.shrink(); 
                        
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: similarAlbum.imagePath.startsWith('http')
                                    ? Image.network(
                                        similarAlbum.imagePath,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.album, size: 60),
                                      )
                                    : Image.asset(
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