import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PublicProfileScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de $displayName'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Consultamos los detalles extendidos del usuario
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
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
                        backgroundImage: photoURL.isNotEmpty
                            ? NetworkImage(photoURL)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        displayName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text('Género Favorito: $favoriteGenre'),
                        backgroundColor: Colors.deepPurple.withOpacity(0.3),
                        labelStyle: const TextStyle(color: Colors.white),
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

                
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
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