import 'package:album_log/viewsmodel/preferences_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/auth_viewmodel.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _genres = ['Rock', 'Pop', 'Metal', 'Jazz', 'Electrónica', 'Hip-Hop', 'Todos'];

  @override
  void initState() {
    super.initState();
    final viewModel = Provider.of<PreferencesViewModel>(context, listen: false);
    _nameController.text = viewModel.username;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PreferencesViewModel, AuthViewModel>(
      builder: (context, preferencesVM, authVM, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi Perfil Musical'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => preferencesVM.refreshAlbums(),
              )
            ],
          ),
          body: preferencesVM.isLoading || authVM.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                   
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: authVM.user != null
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: authVM.user!.photoURL != null
                                        ? NetworkImage(authVM.user!.photoURL!)
                                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          authVM.user!.displayName ?? 'Usuario de Google',
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        Text(
                                          authVM.user!.email ?? '',
                                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                                    tooltip: 'Cerrar Sesión',
                                    onPressed: () async {
                                      await authVM.signOut();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sesión cerrada correctamente')),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const Text(
                                    'Sincroniza tu cuenta en la nube',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Inicia sesión para respaldar tus reseñas y calificaciones.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 45,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.login, color: Colors.white),
                                      label: const Text(
                                        'Iniciar Sesión con Google',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.deepPurpleAccent, width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () async {
                                        try {
                                          await authVM.signInWithGoogle();
                                          if (authVM.user != null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('¡Bienvenido, ${authVM.user!.displayName}! 🎉'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error de autenticación: $e')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      
                      const SizedBox(height: 24),

                    
                      const Text(
                        'Mi Cuenta y Preferencias',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                      ),
                      const SizedBox(height: 12),
                      
                      // Input de Nombre de Usuario
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de Usuario',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (value) => preferencesVM.updateUsername(value),
                      ),
                      const SizedBox(height: 16),

                      // Selector de Género
                      DropdownButtonFormField<String>(
                        initialValue: _genres.contains(preferencesVM.favoriteGenre) ? preferencesVM.favoriteGenre : 'Todos',
                        decoration: const InputDecoration(
                          labelText: 'Género Musical Favorito',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.music_note),
                        ),
                        items: _genres.map((String genre) {
                          return DropdownMenuItem<String>(
                            value: genre,
                            child: Text(genre),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            preferencesVM.updateFavoriteGenre(newValue);
                          }
                        },
                      ),
                      
                      const Divider(height: 40),

                      
                      Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mis Álbumes Calificados',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                          ),
                          Chip(
                            label: Text('${preferencesVM.savedReviews.length} discos'),
                            backgroundColor: Colors.deepPurple.withOpacity(0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      preferencesVM.savedReviews.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30),
                                child: Text(
                                  'No tienes álbumes guardados en local.\n¡Califica discos en el buscador!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: preferencesVM.savedReviews.length,
                              itemBuilder: (context, index) {
                                // Obtenemos el modelo completo
                                final review = preferencesVM.savedReviews[index];

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      backgroundColor: Colors.deepPurple,
                                      child: Icon(Icons.album, color: Colors.white),
                                    ),
                                    // Usamos el título que viene en el modelo
                                    title: Text(
                                      review.albumTitle,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        // Estrellas
                                        Row(
                                          children: List.generate(5, (starIndex) {
                                            return Icon(
                                              starIndex < review.rating ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 18,
                                            );
                                          }),
                                        ),
                                        // Texto de la reseña (condicional)
                                        if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            '"${review.reviewText}"',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () {
                                        preferencesVM.removeAlbum(review.albumId);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Registro eliminado de la memoria local')),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}