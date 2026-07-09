import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/auth_viewmodel.dart';
import '../../services/friendship_service.dart';
import '../../services/comment_service.dart';
import '../../l10n/app_localizations.dart';

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
  final CommentService _commentService = CommentService();
  final Map<String, TextEditingController> _commentControllers = {};

  @override
  void dispose() {
    for (final controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // Obtenemos al usuario autenticado actual para la lógica de amistad
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authVM.user;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileOf(widget.displayName)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // Consultamos los detalles extendidos del usuario
        future: FirebaseFirestore.instance.collection('users').doc(widget.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(l10n.errorLoadingProfile),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final favoriteGenre =
            data['favoriteGenre'] ?? l10n.notSpecified;

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
                        label: Text(
                          l10n.favoriteGenreLabel(favoriteGenre),
                        ),
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
                                label: Text(l10n.sendFriendRequest),
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
                                label: Text(
                                  l10n.friendsRemove,
                                  style: const TextStyle(color: Colors.redAccent),
                                ),
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
                                label: Text(
                                    l10n.pendingRequestCancel,
                                    style: const TextStyle(color: Colors.white),
                                  ),
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
                                    label: Text(
                                      l10n.accept,
                                      style: const TextStyle(color: Colors.white),
                                    ),
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
                                    child: Text(
                                      l10n.reject,
                                      style: const TextStyle(color: Colors.redAccent),
                                    ),
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
                
                Text(
                  l10n.musicActivity,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
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
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                        child: Text(
                          l10n.userNoReviews,
                          style: const TextStyle(color: Colors.grey),
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
                      final reviewDoc = reviews[revIndex];
                      final reviewId = reviewDoc.id;

                      if (!_commentControllers.containsKey(reviewId)) {
                        _commentControllers[reviewId] = TextEditingController();
                      }

                      final review = reviewDoc.data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.album,
                                    color: Colors.deepPurple,
                                  ),
                                  title: Text(review['albumTitle'] ?? l10n.album),
                                  subtitle: Text(
                                    '${l10n.ratingLabel}: ${review['rating']}/5\n"${review['reviewText'] ?? ''}"',
                                  ),
                                ),

                                const Divider(),

                                Text(
                                  l10n.comments,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                StreamBuilder<QuerySnapshot>(
                                  stream: _commentService.getComments(
                                    widget.uid,
                                    reviewId,
                                  ),
                                  builder: (context, commentSnapshot) {

                                    if (!commentSnapshot.hasData) {
                                      return const SizedBox();
                                    }

                                    final comments = commentSnapshot.data!.docs;

                                    if (comments.isEmpty) {
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          l10n.noCommentsYet,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: comments.length,
                                      itemBuilder: (context, i) {

                                        final data =
                                            comments[i].data() as Map<String, dynamic>;

                                        return ListTile(
                                          dense: true,
                                          leading: const Icon(Icons.person),
                                          title: Text(data['senderName'] ?? ''),
                                          subtitle: Text(data['text'] ?? ''),
                                        );
                                      },
                                    );
                                  },
                                ),

                                const SizedBox(height: 10),

                                if (currentUser != null)
                                  Row(
                                    children: [

                                      Expanded(
                                        child: TextField(
                                          controller: _commentControllers[reviewId],
                                          decoration: InputDecoration(
                                            hintText: l10n.writeComment,
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        icon: const Icon(Icons.send),
                                        color: Colors.deepPurple,
                                        onPressed: () async {

                                        final controller = _commentControllers[reviewId]!;

                                        if (controller.text.trim().isEmpty) {
                                          return;
                                        }

                                        await _commentService.addComment(
                                          reviewOwnerUid: widget.uid,
                                          reviewId: reviewId,
                                          senderUid: currentUser.uid,
                                          senderName: currentUser.displayName ?? l10n.user,
                                          text: controller.text.trim(),
                                        );

                                        controller.clear();
                                        },
                                      ),
                                    ],
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