import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_dropd/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:just_dropd/theme/theme.dart';

class CreateProfileRoute extends StatefulWidget {
  final String? userId;

  const CreateProfileRoute({super.key, this.userId});

  @override
  State<CreateProfileRoute> createState() => _CreateProfileRouteState();
}

class _CreateProfileRouteState extends State<CreateProfileRoute> {
  late Future<Map<String, dynamic>> _userFuture;
  late Future<List<dynamic>> _receivedMixtapesFuture;
  List<dynamic> concertReviews = [];
  List<dynamic> albumReviews = [];

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
    _receivedMixtapesFuture = _fetchReceivedMixtapes();
    _loadConcertReviews();
    _loadAlbumReviews();
  }

  Future<void> _loadConcertReviews() async {
    if (widget.userId == null) return;
    try {
      final reviews = await ApiService.fetchConcertReviews(widget.userId!);
      setState(() {
        concertReviews = reviews;
      });
    } catch (e) {
      print("Error fetching concert reviews: $e");
    }
  }

  Future<void> _loadAlbumReviews() async {
    if (widget.userId == null) return;

    try {
      final uri = Uri.parse("https://api.justdropd.com/album-reviews/user/${widget.userId}");
      final resp = await http.get(uri, headers: {
        "Content-Type": "application/json",
      });

      if (resp.statusCode != 200) {
        throw Exception("Failed to load album reviews: ${resp.statusCode} ${resp.body}");
      }

      final reviews = jsonDecode(resp.body) as List<dynamic>;

      setState(() {
        albumReviews = reviews;
      });
    } catch (e) {
      print("Error fetching album reviews: $e");
    }
  }

  Future<List<dynamic>> _fetchReceivedMixtapes() async {
    final id = widget.userId;

    if (id == null || id.isEmpty) {
      throw Exception("Missing userId in route");
    }

    final uri = Uri.parse("https://api.justdropd.com/mixtapes/shelf/$id");

    final resp = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });

    if (resp.statusCode != 200) {
      throw Exception("Failed to load mixtapes: ${resp.statusCode} ${resp.body}");
    }

    final data = jsonDecode(resp.body);

    if (data is List) {
      return data;
    } else {
      throw Exception("Expected a list of mixtapes");
    }
  }

  Future<Map<String, dynamic>> _fetchUser() async {
    final id = widget.userId;

    if (id == null || id.isEmpty) {
      throw Exception("Missing userId in route");
    }

    final uri = Uri.parse("https://api.justdropd.com/users/$id");

    final resp = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });

    if (resp.statusCode != 200) {
      throw Exception("Failed to load user: ${resp.statusCode} ${resp.body}");
    }

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    return Scaffold(
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: text.bodyLarge,
              ),
            );
          }

          final user = snapshot.data!;
          final name = (user['name'] ?? 'User') as String;
          final username = (user['username'] ?? '') as String;
          final bio = (user['bio'] ?? "Hi I’m $name! This is my bio") as String;
          final profileImageUrl = user['profile_photo_url'] as String?;

          final imageProvider =
              (profileImageUrl != null && profileImageUrl.isNotEmpty)
                  ? NetworkImage(profileImageUrl)
                  : const NetworkImage("https://placehold.co/156x158.png");

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppLayout.pagePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeaderCard(
                      name: name,
                      username: username,
                      bio: bio,
                      imageProvider: imageProvider,
                    ),

                    const SizedBox(height: AppLayout.sectionGap),

                    _SectionShell(
                      title: "Mixtape Shelf",
                      child: FutureBuilder<List<dynamic>>(
                        future: _receivedMixtapesFuture,
                        builder: (context, mixtapeSnapshot) {
                          if (mixtapeSnapshot.connectionState != ConnectionState.done) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (mixtapeSnapshot.hasError) {
                            return Text(
                              "Error loading mixtapes: ${mixtapeSnapshot.error}",
                              style: text.bodyMedium?.copyWith(color: AppTheme.red),
                            );
                          }

                          final acceptedMixtapes = mixtapeSnapshot.data ?? [];

                          if (acceptedMixtapes.isEmpty) {
                            return Text(
                              "No mixtapes here yet.",
                              style: text.bodyLarge,
                            );
                          }

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: acceptedMixtapes.asMap().entries.map((entry) {
                                final index = entry.key;
                                final mixtape = entry.value;

                                final title = mixtape['title'] ?? 'Untitled Mixtape';

                                final senderName =
                                    mixtape['creatorId'] is Map<String, dynamic>
                                        ? (mixtape['creatorId']['username'] ??
                                            mixtape['creatorId']['name'] ??
                                            'Unknown sender')
                                        : 'Unknown sender';

                                final rawCoverPath = (mixtape['cover_image_url'] ?? '').toString();

                                final imageUrl = rawCoverPath.isNotEmpty
                                    ? (rawCoverPath.startsWith('http')
                                        ? rawCoverPath
                                        : 'https://api.justdropd.com/$rawCoverPath')
                                    : 'https://placehold.co/136x136.png';

                                final playlistUrl = mixtape['spotify_playlist_url'] ?? '';

                                return Padding(
                                  padding: EdgeInsets.only(
                                    right: index == acceptedMixtapes.length - 1
                                        ? 0
                                        : AppLayout.itemGap,
                                  ),
                                  child: _MixtapeShelfCard(
                                    index: index,
                                    title: title,
                                    sender: '@$senderName',
                                    imageUrl: imageUrl,
                                    playlistUrl: playlistUrl,
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppLayout.sectionGap),

                    _SectionTitle(title: "Concert Reviews"),

                    const SizedBox(height: AppLayout.smallGap),

                    concertReviews.isEmpty
                        ? const _EmptyStateCard(message: "No concert reviews yet.")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: concertReviews.length,
                            itemBuilder: (context, index) {
                              final review = concertReviews[index];
                              return _ConcertReviewCard(review: review);
                            },
                          ),

                    const SizedBox(height: AppLayout.sectionGap),

                    _SectionTitle(title: "Album Reviews"),

                    const SizedBox(height: AppLayout.smallGap),

                    albumReviews.isEmpty
                        ? const _EmptyStateCard(message: "No album reviews yet.")
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: albumReviews.length,
                            itemBuilder: (context, index) {
                              return _AlbumReviewCard(review: albumReviews[index]);
                            },
                          ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String username;
  final String bio;
  final ImageProvider imageProvider;

  const _ProfileHeaderCard({
    required this.name,
    required this.username,
    required this.bio,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(AppLayout.radiusXl),
        border: Border.all(color: AppTheme.pink, width: 1.5),
      ),
      child: Wrap(
        spacing: 24,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 220, maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: text.displayLarge),
                const SizedBox(height: 6),
                Text(
                  '@$username',
                  style: text.titleMedium?.copyWith(color: AppTheme.orange),
                ),
                const SizedBox(height: 12),
                Text(
                  bio,
                  style: text.bodyLarge?.copyWith(
                    height: 1.4,
                    color: AppTheme.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionShell({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: AppTheme.pink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: text.titleLarge),
          const SizedBox(height: AppLayout.smallGap),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String message;

  const _EmptyStateCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
        border: Border.all(color: AppTheme.pink),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _ConcertReviewCard extends StatelessWidget {
  final dynamic review;

  const _ConcertReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final images = (review['image_urls'] as List?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: AppLayout.itemGap),
      child: Card(
        color: AppTheme.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          side: const BorderSide(color: AppTheme.pink),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review['artist_name'] ?? '', style: text.titleMedium),
              const SizedBox(height: 4),
              Text(
                review['title'] ?? '',
                style: text.labelLarge?.copyWith(color: AppTheme.orange),
              ),
              const SizedBox(height: 8),
              Text("Location: ${review['location'] ?? ''}", style: text.bodyMedium),
              Text(
                "Date: ${review['date']?.toString().substring(0, 10) ?? ''}",
                style: text.bodyMedium,
              ),
              Text("Rating: ${review['rating'] ?? ''}", style: text.bodyMedium),
              const SizedBox(height: 10),
              Text(review['review_text'] ?? '', style: text.bodyLarge),

              if (images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, imgIndex) {
                      final imageUrl = "https://api.justdropd.com/${images[imgIndex]}";
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppLayout.radiusSm),
                          child: Image.network(
                            imageUrl,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 40),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AlbumReviewCard extends StatelessWidget {
  final dynamic review;

  const _AlbumReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    final imageUrl =
        (review['custom_image_url'] != null &&
                review['custom_image_url'].toString().isNotEmpty)
            ? review['custom_image_url']
            : (review['spotify_album_image_url'] ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: AppLayout.itemGap),
      child: Card(
        color: AppTheme.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusLg),
          side: const BorderSide(color: AppTheme.pink),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl.toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppLayout.radiusSm),
                    child: Image.network(
                      imageUrl,
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 40),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['album_name'] ?? '', style: text.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      review['artist_name'] ?? '',
                      style: text.labelLarge?.copyWith(color: AppTheme.orange),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Rating: ${review['rating'] ?? ''} / 5",
                      style: text.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(review['review_text'] ?? '', style: text.bodyLarge),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MixtapeShelfCard extends StatelessWidget {
  final int index;
  final String title;
  final String sender;
  final String imageUrl;
  final String playlistUrl;

  const _MixtapeShelfCard({
    required this.index,
    required this.title,
    required this.sender,
    required this.imageUrl,
    required this.playlistUrl,
  });

  @override
  Widget build(BuildContext context) {
    final pair = AppTheme.pairAt(index);

    return InkWell(
      borderRadius: BorderRadius.circular(AppLayout.radiusMd),
      onTap: () async {
        if (playlistUrl.isEmpty) return;

        final uri = Uri.parse(playlistUrl);
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_blank',
        );
      },
      child: Container(
        width: 172,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: pair["bg"],
          borderRadius: BorderRadius.circular(AppLayout.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppLayout.radiusSm),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 136,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 136,
                    color: AppTheme.cream,
                    child: const Center(
                      child: Icon(Icons.album, size: 40, color: AppTheme.blue),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: pair["fg"],
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              sender,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: pair["fg"],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}