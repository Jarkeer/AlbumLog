import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/review_model.dart';
import 'comments_screen.dart';

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
        title: Text("Perfil de $displayName"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.deepPurpleAccent,
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "No se pudo cargar el perfil.",
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final favoriteGenre =
              data['favoriteGenre'] ?? "No especificado";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [

                      CircleAvatar(
                        radius: 45,
                        backgroundImage: photoURL.isNotEmpty
                            ? NetworkImage(photoURL)
                            : const AssetImage(
                                    "assets/images/default_avatar.png")
                                as ImageProvider,
                      ),

                      const SizedBox(height: 15),

                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Chip(
                        backgroundColor:
                            Colors.deepPurple.withOpacity(.3),
                        label: Text(
                          "Género favorito: $favoriteGenre",
                          style:
                              const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Reseñas",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection('reviews')
                      .orderBy(
                        "createdAt",
                        descending: true,
                      )
                      .snapshots(),
                  builder: (context, reviewSnapshot) {
                    if (reviewSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!reviewSnapshot.hasData ||
                        reviewSnapshot.data!.docs.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            "Este usuario todavía no ha publicado reseñas.",
                          ),
                        ),
                      );
                    }

                    final reviews = reviewSnapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review =
                            ReviewModel.fromMap(reviews[index].data()
                                as Map<String, dynamic>);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                Text(
                                  review.albumTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: List.generate(
                                    5,
                                    (star) => Icon(
                                      star < review.rating
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  review.reviewText ??
                                      "Sin comentario.",
                                ),

                                const SizedBox(height: 15),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.comment),
                                    label: const Text(
                                      "Ver comentarios",
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              CommentsScreen(
                                            ownerId: uid,
                                            review: review,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
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