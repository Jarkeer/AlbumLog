import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/auth_viewmodel.dart';
import '../../services/friendship_service.dart';

class PublicProfileScreen extends StatefulWidget {
  final String uid;
  final String displayName;
  final String photoURL;

  const PublicProfileScreen({
    super.key,
    required this.uid,
    required this.displayName,
    required this.photoURL,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  // Instanciamos el servicio de amistad
  final FriendshipService _friendshipService = FriendshipService();

  @override
  Widget build(BuildContext context) {
    // Obtenemos al usuario autenticado actual para la lógica de amistad
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authVM.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de ${widget.displayName}'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Consultamos los detalles extendidos del usuario
        future: FirebaseFirestore.instance.collection('users').doc(widget.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Error al cargar la información del perfil'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final favoriteGenre = data['favoriteGenre'] ?? 'No especificado';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera del perfil
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: widget.photoURL.isNotEmpty
                            ? NetworkImage(widget.photoURL)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.displayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Género Favorito: $favoriteGenre'),
                        backgroundColor: Colors.deepPurple.withOpacity(0.3),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // BOTÓN DINÁMICO DE AMISTAD
                      if (currentUser != null && currentUser.uid != widget.uid)
                        StreamBuilder<DocumentSnapshot?>(
                          stream: _friendshipService.getRelationshipStream(currentUser.uid, widget.uid),
                          builder: (context, relationshipSnapshot) {
                            if (!relationshipSnapshot.hasData || relationshipSnapshot.data == null || !relationshipSnapshot.data!.exists) {
                              // Caso 1: No hay ninguna relación
                              return ElevatedButton.icon(
                                icon: const Icon(Icons.person_add),
                                label: const Text('Enviar Solicitud'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                onPressed: () => _friendshipService.sendFriendRequest(
                                  senderId: currentUser.uid,
                                  receiverId: widget.uid,
                                ),
                              );
                            }

                            final reqData = relationshipSnapshot.data!.data() as Map<String, dynamic>;
                            final String status = reqData['status'] ?? '';
                            final String senderId = reqData['senderId'] ?? '';

                            if (status == 'accepted') {
                              // Caso 2: Ya son amigos
                              return OutlinedButton.icon(
                                icon: const Icon(Icons.people, color: Colors.green),
                                label: const Text('Amigos (Eliminar)', style: TextStyle(color: Colors.redAccent)),
                                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.green)),
                                onPressed: () => _friendshipService.deleteFriendship(
                                  senderId: currentUser.uid,
                                  receiverId: widget.uid,
                                ),
                              );
                            } else if (status == 'pending' && senderId == currentUser.uid) {
                              // Caso 3: Solicitud enviada por mí, esperando respuesta
                              return ElevatedButton.icon(
                                icon: const Icon(Icons.hourglass_top, color: Colors.white),
                                label: const Text('Solicitud Pendiente (Cancelar)', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
                                onPressed: () => _friendshipService.deleteFriendship(
                                  senderId: currentUser.uid,
                                  receiverId: widget.uid,
                                ),
                              );
                            } else if (status == 'pending' && senderId == widget.uid) {
                              // Caso 4: Solicitud recibida (puedo aceptar o rechazar)
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.check, color: Colors.white),
                                    label: const Text('Aceptar', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    onPressed: () => _friendshipService.acceptFriendRequest(
                                      senderId: widget.uid,
                                      receiverId: currentUser.uid,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                                    onPressed: () => _friendshipService.deleteFriendship(
                                      senderId: widget.uid,
                                      receiverId: currentUser.uid,
                                    ),
                                    child: const Text('Rechazar', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'Su Actividad Musical',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                ),
                const SizedBox(height: 12),

                // Lista de reseñas del usuario
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .collection('reviews') 
                      .snapshots(),
                  builder: (context, reviewSnapshot) {
                    if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!reviewSnapshot.hasData || reviewSnapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'Este usuario aún no ha compartido reseñas.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    final reviews = reviewSnapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, revIndex) {
                        final review = reviews[revIndex].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            leading: const Icon(Icons.album, color: Colors.deepPurple),
                            title: Text(review['albumTitle'] ?? 'Álbum Desconocido'),
                            subtitle: Text('Nota: ${review['rating']}/5\n"${review['reviewText'] ?? ''}"'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}