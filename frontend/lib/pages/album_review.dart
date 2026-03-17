import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AddAlbumReviewPage extends StatefulWidget {
  final String? userId;

  const AddAlbumReviewPage({super.key, required this.userId});

  @override
  State<AddAlbumReviewPage> createState() => _AddAlbumReviewPageState();
}

class _AddAlbumReviewPageState extends State<AddAlbumReviewPage> {

  final _reviewController = TextEditingController();
  final _albumSearchController = TextEditingController();

  final List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedAlbum;

  bool _isSearching = false;
  String? _searchError;

  Timer? _debounce;

  double _rating = 0;

  String get _baseUrl {
    return "http://localhost:3000";
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _albumSearchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _searchSpotifyAlbums(String query) async {

    final q = query.trim();

    if (q.isEmpty) {
      setState(() {
        _searchResults.clear();
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {

      final uri = Uri.parse("$_baseUrl/api/spotify/search").replace(
        queryParameters: {
          "userId": widget.userId ?? "",
          "q": q,
          "limit": "10",
        },
      );

      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception("Search failed ${resp.body}");
      }

      final data = jsonDecode(resp.body);

      final albums = (data["albums"] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      setState(() {
        _searchResults
          ..clear()
          ..addAll(albums);

        _isSearching = false;
      });

    } catch (e) {

      setState(() {
        _searchResults.clear();
        _isSearching = false;
        _searchError = e.toString();
      });
    }
  }

  void _selectAlbum(Map<String, dynamic> album) {

    setState(() {
      _selectedAlbum = album;
      _searchResults.clear();
      _albumSearchController.clear();
    });
  }

  Widget _buildStarRating() {

    return Row(
      children: List.generate(5, (index) {

        final starIndex = index + 1;

        IconData icon;

        if (_rating >= starIndex) {
          icon = Icons.star;
        } 
        else if (_rating >= starIndex - 0.5) {
          icon = Icons.star_half;
        } 
        else {
          icon = Icons.star_border;
        }

        return GestureDetector(

          onTapDown: (details) {

            final box = context.findRenderObject() as RenderBox;
            final localX = box.globalToLocal(details.globalPosition).dx;

            final width = box.size.width / 5;

            double newRating;

            if (localX < (index * width + width / 2)) {
              newRating = index + 0.5;
            } else {
              newRating = index + 1.0;
            }

            setState(() {
              _rating = newRating;
            });
          },

          child: Icon(
            icon,
            color: Colors.amber,
            size: 36,
          ),
        );
      }),
    );
  }

  void _submitReview() {

    if (_selectedAlbum == null) {
      debugPrint("No album selected");
      return;
    }

    final payload = {

      "userId": widget.userId,
      "spotify_album_id": _selectedAlbum!["spotify_album_id"],
      "rating": _rating,
      "review": _reviewController.text

    };

    debugPrint("Submit review payload: $payload");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,

      body: Center(
        child: SingleChildScrollView(

          child: Container(
            width: 700,
            padding: const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Text(
                  "Album Review",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold
                  ),
                ),

                const SizedBox(height: 30),

                const Text("Search Album"),

                const SizedBox(height: 8),

                TextField(

                  controller: _albumSearchController,

                  decoration: InputDecoration(

                    hintText: "Search Spotify albums",

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),

                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),

                  onChanged: (val) {

                    _debounce?.cancel();

                    _debounce = Timer(
                      const Duration(milliseconds: 300),
                      () {
                        _searchSpotifyAlbums(val);
                      }
                    );
                  },
                ),

                const SizedBox(height: 12),

                if (_searchResults.isNotEmpty)

                  Container(

                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: ListView.builder(

                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: _searchResults.length,

                      itemBuilder: (context, i) {

                        final album = _searchResults[i];

                        return ListTile(

                          leading: album["imageUrl"] != null
                              ? Image.network(
                                  album["imageUrl"],
                                  width: 40,
                                  height: 40,
                                )
                              : const Icon(Icons.album),

                          title: Text(album["name"]),
                          subtitle: Text(album["artist"]),

                          onTap: () => _selectAlbum(album),
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 30),

                if (_selectedAlbum != null)

                  Container(

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Row(

                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _selectedAlbum!["imageUrl"],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(
                                _selectedAlbum!["name"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _selectedAlbum!["artist"],
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                const Text("Rating"),

                _buildStarRating(),

                const SizedBox(height: 20),

                const Text("Review"),

                const SizedBox(height: 8),

                TextField(

                  controller: _reviewController,

                  maxLines: 6,

                  decoration: InputDecoration(
                    hintText: "Write your review...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8AD2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),

                    onPressed: _submitReview,

                    child: const Text(
                      "Submit Review",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}