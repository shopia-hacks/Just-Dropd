import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_dropd/shared/nav_bar.dart';
import 'package:just_dropd/theme/theme.dart'; // Ensure this points to your theme file

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

  // ─── Shared Bottom Description ──────────────────────────────────────
  Widget _buildDescriptionText(String text, int index) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: AppLayout.smallGap),
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.activityColorAt(index),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  // ─── Feed Item Builders ───────────────────────────────────────────
  Widget _buildPendingMixtapeCard(Map<String, dynamic> itemData, int index) {
    final creator = itemData["creatorId"] as Map<String, dynamic>?;
    final senderName =
        (creator?["name"] ?? creator?["username"] ?? "Friend").toString();
    final description = "$senderName sent you a mixtape request.";

    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppLayout.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemData["title"]?.toString() ?? "Untitled Mixtape",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if ((itemData["message"] ?? "").toString().isNotEmpty) ...[
                  const SizedBox(height: AppLayout.smallGap),
                  Text(
                    itemData["message"].toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: AppLayout.itemGap),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _respondToMixtape(
                        itemData["_id"].toString(),
                        "rejected",
                      ),
                      child: const Text("Decline"),
                    ),
                    const SizedBox(width: AppLayout.smallGap),
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
          _buildDescriptionText(description, index),
        ],
      ),
    );
  }

  Widget _buildConcertReviewCard(Map<String, dynamic> itemData, int index) {
    final user = itemData["userId"] as Map<String, dynamic>?;
    final displayName =
        (user?["name"] ?? user?["username"] ?? "User").toString();

    final artistName = itemData["artist_name"]?.toString() ?? "";
    final reviewTitle = itemData["title"]?.toString() ?? "Concert Review";
    final location = itemData["location"]?.toString() ?? "";
    final rating = itemData["rating"]?.toString() ?? "";
    final reviewText = itemData["review_text"]?.toString() ?? "";
    final imageUrls = itemData["image_urls"] as List<dynamic>? ?? [];

    final description = "$displayName reviewed $artistName.";

    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppLayout.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reviewTitle, style: Theme.of(context).textTheme.titleMedium),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(location, style: Theme.of(context).textTheme.labelLarge),
                ],
                if (rating.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text("Rating: $rating / 5", style: Theme.of(context).textTheme.bodyMedium),
                ],
                if (reviewText.isNotEmpty) ...[
                  const SizedBox(height: AppLayout.smallGap),
                  Text(
                    reviewText.length > 140
                        ? "${reviewText.substring(0, 140)}..."
                        : reviewText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (imageUrls.isNotEmpty) ...[
                  const SizedBox(height: AppLayout.itemGap),
                  _buildFeedImage("$_baseUrl/${imageUrls.first}"),
                ],
              ],
            ),
          ),
          _buildDescriptionText(description, index),
        ],
      ),
    );
  }

  Widget _buildAlbumReviewCard(Map<String, dynamic> itemData, int index) {
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

    final description = "$displayName reviewed ${albumName.isNotEmpty ? albumName : "an album"}.";

    return Padding(
      padding: const EdgeInsets.only(bottom: AppLayout.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppLayout.cardPadding),
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(AppLayout.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (artistName.isNotEmpty)
                  Text(artistName, style: Theme.of(context).textTheme.titleMedium),
                if (rating.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text("Rating: $rating / 5", style: Theme.of(context).textTheme.labelLarge),
                ],
                if (reviewText.isNotEmpty) ...[
                  const SizedBox(height: AppLayout.smallGap),
                  Text(
                    reviewText.length > 140
                        ? "${reviewText.substring(0, 140)}..."
                        : reviewText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (imageToShow.isNotEmpty) ...[
                  const SizedBox(height: AppLayout.itemGap),
                  _buildFeedImage(imageToShow),
                ],
              ],
            ),
          ),
          _buildDescriptionText(description, index),
        ],
      ),
    );
  }

  Widget _buildFeedImage(String imageUrl) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppLayout.radiusSm),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 150,
              color: AppTheme.white,
              child: const Center(
                child: Icon(Icons.broken_image, size: 36, color: Colors.grey),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 150,
              color: AppTheme.white,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedCard(Map<String, dynamic> feedItem, int index) {
    final type = feedItem["type"];
    final data = feedItem["data"] as Map<String, dynamic>;

    switch (type) {
      case "pending_mixtape":
        return _buildPendingMixtapeCard(data, index);
      case "concert_review":
        return _buildConcertReviewCard(data, index);
      case "album_review":
        return _buildAlbumReviewCard(data, index);
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header matching Countdown Page ───────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.pagePadding,
                20,
                AppLayout.pagePadding,
                AppLayout.itemGap,
              ),
              child: Text(
                'Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 28,
                      color: AppTheme.red,
                    ),
              ),
            ),
            // ─── Feed List ──────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!))
                      : _feedItems.isEmpty
                          ? const Center(child: Text("No activity yet."))
                          : RefreshIndicator(
                              onRefresh: _fetchFeed,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppLayout.pagePadding,
                                ),
                                itemCount: _feedItems.length,
                                itemBuilder: (context, index) {
                                  final item = _feedItems[index]
                                      as Map<String, dynamic>;
                                  // Pass index for the alternating text colors
                                  return _buildFeedCard(item, index);
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}