import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_dropd/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
      final uri = Uri.parse("http://localhost:3000/album-reviews/user/${widget.userId}");
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

    final uri = Uri.parse("http://localhost:3000/mixtapes/shelf/$id");

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

    final uri = Uri.parse("http://localhost:3000/users/$id");

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
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= PROFILE HEADER CARD =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 156,
                            height: 158,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                              shape: const OvalBorder(),
                            ),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 36,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '@$username',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  bio,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ================= RECEIVED MIXTAPES SECTION =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Received Mixtapes",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FutureBuilder<List<dynamic>>(
                            future: _receivedMixtapesFuture,
                            builder: (context, mixtapeSnapshot) {
                              if (mixtapeSnapshot.connectionState != ConnectionState.done) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (mixtapeSnapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "Error loading mixtapes: ${mixtapeSnapshot.error}",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final acceptedMixtapes = mixtapeSnapshot.data ?? [];

                              if (acceptedMixtapes.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "No accepted mixtapes yet.",
                                    style: TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: acceptedMixtapes.map((mixtape) {
                                    final title = mixtape['title'] ?? 'Untitled Mixtape';

                                    final senderName =
                                        mixtape['creatorId'] is Map<String, dynamic>
                                            ? (mixtape['creatorId']['username'] ??
                                                mixtape['creatorId']['name'] ??
                                                'Unknown sender')
                                            : 'Unknown sender';

                                    final imageUrl =
                                        mixtape['cover_image_url'] != null &&
                                                mixtape['cover_image_url'].toString().isNotEmpty
                                            ? mixtape['cover_image_url']
                                            : 'https://placehold.co/136x136.png';

                                    final playlistUrl = mixtape['spotify_playlist_url'] ?? '';

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: _MixtapeShelfCard(
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
                        ],
                      ),
                    ),

                    // ================= MY CONCERT REVIEWS SECTION =================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(
                        "My Concert Reviews",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    concertReviews.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text("No concert reviews yet."),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: concertReviews.length,
                            itemBuilder: (context, index) {
                              final review = concertReviews[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review['artist_name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        review['title'] ?? '',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      Text("Location: ${review['location'] ?? ''}"),
                                      Text("Date: ${review['date']?.toString().substring(0, 10) ?? ''}"),
                                      Text("${review['rating'] ?? ''}"),
                                      const SizedBox(height: 8),
                                      Text(review['review_text'] ?? ''),
                                      if ((review['image_urls'] as List?)?.isNotEmpty ?? false)
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: (review['image_urls'] as List).length,
                                            itemBuilder: (context, imgIndex) {
                                              final imageUrl =
                                                  "http://localhost:3000/${review['image_urls'][imgIndex]}";
                                              return Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: 100,
                                                    height: 100,
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
                                  ),
                                ),
                              );
                            },
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text(
                              "My Album Reviews",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),

                          albumReviews.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text("No album reviews yet."),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: albumReviews.length,
                                  itemBuilder: (context, index) {
                                    final review = albumReviews[index];

                                    final imageUrl =
                                        (review['custom_image_url'] != null &&
                                                review['custom_image_url'].toString().isNotEmpty)
                                            ? review['custom_image_url']
                                            : (review['spotify_album_image_url'] ?? '');

                                    return Card(
                                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (imageUrl.toString().isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(right: 12),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    imageUrl,
                                                    width: 90,
                                                    height: 90,
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
                                                  Text(
                                                    review['album_name'] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    review['artist_name'] ?? '',
                                                    style: const TextStyle(color: Colors.grey),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text("Rating: ${review['rating'] ?? ''} / 5"),
                                                  const SizedBox(height: 8),
                                                  Text(review['review_text'] ?? ''),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
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

// reusable little card for the shelf section
class _MixtapeShelfCard extends StatelessWidget {
  final String title;
  final String sender;
  final String imageUrl;
  final String playlistUrl;

  const _MixtapeShelfCard({
    required this.title,
    required this.sender,
    required this.imageUrl,
    required this.playlistUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
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
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          border: Border.all(color: const Color(0xFFD9D9D9)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 136,
                height: 136,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sender,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}