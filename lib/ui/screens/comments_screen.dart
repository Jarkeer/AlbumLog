import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../models/review_model.dart';
import '../../services/firebase_service.dart';
import '../../viewsmodel/auth_viewmodel.dart';

class CommentsScreen extends StatefulWidget {
  final String ownerId;
  final ReviewModel review;

  const CommentsScreen({
    super.key,
    required this.ownerId,
    required this.review,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _controller = TextEditingController();

  bool _sending = false;

  Future<void> _sendComment() async {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (authVM.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginToComment),
        ),
      );
      return;
    }

    final text = _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _sending = true;
    });

    try {
      await _firebaseService.addComment(
        ownerUid: widget.ownerId,
        reviewId: widget.review.reviewId,
        commenterUid: authVM.user!.uid,
        commenterName: authVM.user!.displayName ?? l10n.user,
        text: text,
      );

      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${l10n.error}: $e"),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _sending = false;
      });
    }
  }

  Widget _buildStars() {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < widget.review.rating
              ? Icons.star
              : Icons.star_border,
          color: Colors.amber,
          size: 22,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.comments),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.review.albumTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildStars(),
                    const SizedBox(height: 15),
                    Text(
                      widget.review.reviewText?.isNotEmpty == true
                          ? widget.review.reviewText!
                          : l10n.noComment,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _firebaseService.getComments(
                widget.ownerId,
                widget.review.reviewId,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.beFirstComment,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final comment = docs[index].data();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          comment["commenterName"] ?? l10n.user,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          comment["text"] ?? "",
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: l10n.writeComment,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _sending
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.deepPurple,
                          ),
                          onPressed: _sendComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}