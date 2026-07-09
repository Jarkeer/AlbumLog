import 'package:album_log/viewsmodel/preferences_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewsmodel/auth_viewmodel.dart'; 
import 'public_profile_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/comment_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<String> _genres(AppLocalizations l10n) => [
        l10n.rock,
        l10n.pop,
        l10n.metal,
        l10n.jazz,
        l10n.electronic,
        l10n.hipHop,
        l10n.allGenres,
      ];
  final CommentService _commentService = CommentService();

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
        final l10n = AppLocalizations.of(context)!;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.myMusicProfile),
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
                                          authVM.user!.displayName ?? l10n.googleUser,
                                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                        ),
                                        Text(
                                          authVM.user!.email ?? '',
                                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.public, color: Colors.deepPurpleAccent),
                                        tooltip: l10n.viewPublicProfile,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PublicProfileScreen(
                                                uid: authVM.user!.uid,
                                                displayName: authVM.user!.displayName ?? l10n.user,
                                                photoURL: authVM.user!.photoURL ?? "",
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.logout, color: Colors.redAccent),
                                        tooltip: l10n.logout,
                                        onPressed: () async {
                                          await authVM.signOut();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(l10n.logoutSuccess)),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Text(
                                    l10n.syncCloud,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.syncCloudDescription,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 45,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.login, color: Colors.white),
                                      label: Text(
                                        l10n.signInGoogle,
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
                                                content: Text('${l10n.welcome} ${authVM.user!.displayName}! 🎉'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${l10n.authenticationError} $e')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      
                      const SizedBox(height: 24),

                    
                      Text(
                        l10n.accountPreferences,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                      ),
                      const SizedBox(height: 12),
                      
                      // Input de Nombre de Usuario
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.username,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (value) => preferencesVM.updateUsername(value),
                      ),
                      const SizedBox(height: 16),

                      // Selector de Género
                      DropdownButtonFormField<String>(
                        initialValue: _genres(l10n).contains(preferencesVM.favoriteGenre)
                          ? preferencesVM.favoriteGenre
                          : l10n.allGenres,
                        decoration: InputDecoration(
                          labelText: l10n.favoriteGenre,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.music_note),
                        ),
                        items: _genres(l10n).map((String genre) {
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
                          Text(
                            l10n.myRatedAlbums,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurpleAccent),
                          ),
                          Chip(
                            label: Text('${preferencesVM.savedReviews.length} ${l10n.albums}'),
                            backgroundColor: Colors.deepPurple.withOpacity(0.2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                        authVM.user == null
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Text(
                                    l10n.signInGoogle,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              )
                            : StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(authVM.user!.uid)
                                    .collection('reviews')
                                    .snapshots(),
                                builder: (context, reviewSnapshot) {
                          if (reviewSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!reviewSnapshot.hasData || reviewSnapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 30),
                                child: Text(
                                  l10n.noSavedAlbums,
                                  textAlign: TextAlign.center,
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
                            itemBuilder: (context, index) {
                              final reviewDoc = reviews[index];
                              final reviewId = reviewDoc.id;
                              final review = reviewDoc.data() as Map<String, dynamic>;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: Colors.deepPurple,
                                    child: Icon(Icons.album, color: Colors.white),
                                  ),
                                  title: Text(
                                    review['albumTitle'] ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),

                                      Row(
                                        children: List.generate(5, (i) {
                                          final rating = review['rating'] ?? 0;
                                          return Icon(
                                            i < rating ? Icons.star : Icons.star_border,
                                            color: Colors.amber,
                                            size: 18,
                                          );
                                        }),
                                      ),

                                      if ((review['reviewText'] ?? '').toString().isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          '"${review['reviewText']}"',
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 12),
                                      const Divider(),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        l10n.noCommentsYet,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ),

                                      StreamBuilder<QuerySnapshot>(
                                        stream: _commentService.getComments(
                                          authVM.user!.uid,
                                          reviewId,
                                        ),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const SizedBox();
                                          }

                                          final comments = snapshot.data!.docs;

                                          if (comments.isEmpty) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              child: Text(
                                                "Aún no hay comentarios.",
                                                style: TextStyle(color: Colors.grey),
                                              ),
                                            );
                                          }

                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: comments.length,
                                            itemBuilder: (context, i) {
                                              final comment =
                                                  comments[i].data() as Map<String, dynamic>;

                                              return ListTile(
                                                dense: true,
                                                leading: const Icon(Icons.person, size: 20),
                                                title: Text(comment['senderName'] ?? ''),
                                                subtitle: Text(comment['text'] ?? ''),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(authVM.user!.uid)
                                          .collection('reviews')
                                          .doc(reviewId)
                                          .delete();
                                    },
                                  ),
                                ),
                              );
                            },
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