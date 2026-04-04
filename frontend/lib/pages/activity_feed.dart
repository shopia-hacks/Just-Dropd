import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_dropd/shared/nav_bar.dart';

class ActivityFeed extends StatefulWidget {
  final String? userId;
  const ActivityFeed({super.key, required this.userId});

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  String get _baseUrl => "http://localhost:3000";

  bool _loading = false;
  String? _error;
  List<dynamic> _feedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  Future<void> _fetchFeed() async {
    if (widget.userId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse("$_baseUrl/activity-feed/${widget.userId}");
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception("Failed to load feed (${resp.statusCode}): ${resp.body}");
      }

      setState(() {
        _feedItems = jsonDecode(resp.body) as List<dynamic>;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _respondToMixtape(String mixtapeId, String status) async {
    try {
      final uri = Uri.parse("$_baseUrl/mixtapes/$mixtapeId/respond");

      final resp = await http.patch(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "status": status,
          "receiverId": widget.userId,
        }),
      );

      if (resp.statusCode != 200) {
        throw Exception("Respond failed (${resp.statusCode}): ${resp.body}");
      }

      await _fetchFeed();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Widget _buildPendingMixtapeCard(Map<String, dynamic> itemData) {
    final creator = itemData["creatorId"] as Map<String, dynamic>?;
    final senderName =
        (creator?["name"] ?? creator?["username"] ?? "Friend").toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "New Mixtape Request",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              itemData["title"]?.toString() ?? "Untitled Mixtape",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text("From: $senderName"),
            const SizedBox(height: 6),
            if ((itemData["message"] ?? "").toString().isNotEmpty)
              Text(itemData["message"].toString()),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton(
                  onPressed: () => _respondToMixtape(
                    itemData["_id"].toString(),
                    "rejected",
                  ),
                  child: const Text("Decline"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _respondToMixtape(
                    itemData["_id"].toString(),
                    "accepted",
                  ),
                  child: const Text("Accept"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConcertReviewCard(Map<String, dynamic> itemData) {
    final user = itemData["userId"] as Map<String, dynamic>?;
    final displayName =
        (user?["name"] ?? user?["username"] ?? "User").toString();

    final artistName = itemData["artist_name"]?.toString() ?? "";
    final reviewTitle = itemData["title"]?.toString() ?? "Concert Review";
    final location = itemData["location"]?.toString() ?? "";
    final rating = itemData["rating"]?.toString() ?? "";
    final reviewText = itemData["review_text"]?.toString() ?? "";

    final imageUrls = itemData["image_urls"] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Concert Review",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "$displayName reviewed $artistName",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(reviewTitle),
            if (location.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(location),
            ],
            if (rating.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text("Rating: $rating / 5"),
            ],
            if (reviewText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reviewText.length > 140
                    ? "${reviewText.substring(0, 140)}..."
                    : reviewText,
              ),
            ],
            if (imageUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildFeedImage("$_baseUrl/${imageUrls.first}"),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCard(Map<String, dynamic> feedItem) {
    final type = feedItem["type"];
    final data = feedItem["data"] as Map<String, dynamic>;

    switch (type) {
      case "pending_mixtape":
        return _buildPendingMixtapeCard(data);
      case "concert_review":
        return _buildConcertReviewCard(data);
      case "album_review":
        return _buildAlbumReviewCard(data);
      default:
        return const SizedBox.shrink();
    }

  }

  Widget _buildAlbumReviewCard(Map<String, dynamic> itemData) {
    final user = itemData["userId"] as Map<String, dynamic>?;
    final displayName =
        (user?["name"] ?? user?["username"] ?? "User").toString();

    final albumName = itemData["album_name"]?.toString() ?? "";
    final artistName = itemData["artist_name"]?.toString() ?? "";
    final rating = itemData["rating"]?.toString() ?? "";
    final reviewText = itemData["review_text"]?.toString() ?? "";
    final customImageUrl = itemData["custom_image_url"]?.toString() ?? "";
    final spotifyAlbumImageUrl =
        itemData["spotify_album_image_url"]?.toString() ?? "";

    final imageToShow =
        customImageUrl.isNotEmpty ? customImageUrl : spotifyAlbumImageUrl;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Album Review",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "$displayName reviewed ${albumName.isNotEmpty ? albumName : "an album"}",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (artistName.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(artistName),
            ],
            if (rating.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text("Rating: $rating / 5"),
            ],
            if (reviewText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reviewText.length > 140
                    ? "${reviewText.substring(0, 140)}..."
                    : reviewText,
              ),
            ],
            if (imageToShow.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildFeedImage(imageToShow),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedImage(String imageUrl) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 260,
          maxHeight: 180,
        ),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 120,
                height: 120,
                child: Center(
                  child: Icon(Icons.broken_image, size: 36, color: Colors.grey),
                ),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 120,
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _feedItems.isEmpty
                    ? const Center(child: Text("No activity yet."))
                    : RefreshIndicator(
                        onRefresh: _fetchFeed,
                        child: ListView.builder(
                          itemCount: _feedItems.length,
                          itemBuilder: (context, index) {
                            final item =
                                _feedItems[index] as Map<String, dynamic>;
                            return _buildFeedCard(item);
                          },
                        ),
                      ),
      ),
    );
  }
}