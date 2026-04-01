import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart'; //for uploading cover art images

class AddMixtapePage extends StatefulWidget {
  final String? userId;
  const AddMixtapePage({super.key, required this.userId});

  @override
  State<AddMixtapePage> createState() => _AddMixtapePageState();
}

class _AddMixtapePageState extends State<AddMixtapePage> {
  final _mixtapeTitleController = TextEditingController();
  final _mixtapeMessageController = TextEditingController();
  final _receiverUsernameController = TextEditingController();
  final _songSearchController = TextEditingController();

  // store spotify_track_ids to store in our database + track order
  final List<Map<String, String>> _songs = [];

  String? _mixtapeType; // dropdown value

  final List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounce;

  final ImagePicker _picker = ImagePicker(); //for upload images

  // store cover art locally (no DB submission yet, need to complete friends functionality first)
  XFile? _coverFile;
  Uint8List? _coverBytes; // needed for preview on web
  String? _coverError;

  //friends dropdown state:
  //stores the "other user" objects extracted from the friendship records
  final List<Map<String, dynamic>> _friends = [];
  bool _loadingFriends = false;
  String? _friendsError;
  String? _selectedFriendId; //the friend they select from the drop down (mongo db id)

  //submitting to database states:
  bool _creatingMixtape = false;
  String? _createMixtapeError;
  String? _createMixtapeSuccess;

  String get _baseUrl {
    return "http://localhost:3000";
  }

  @override
  void initState() {
    super.initState();

    //load current friends so the dropdown has options
    _fetchFriends();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _mixtapeTitleController.dispose();
    _mixtapeMessageController.dispose();
    _receiverUsernameController.dispose();
    _songSearchController.dispose();
    super.dispose();
  }

  //Helper function: given one friendship record, determine who the "other user" is
  //(getting the list of friends for a current logged in user) -> have to sort through friendship records
  // ex: if I am userId, return friendId
  //     if I am friendId, return userId
  // This function helps decide which side of the friendship relationship the logged in user is on!
  Map<String, dynamic>? _otherUserFromFriendship(dynamic friendshipJson) {
    final me = widget.userId;
    final f = friendshipJson as Map<String, dynamic>; //get the friendship records that match with the logged in user

    final userObj = f["userId"];
    final friendObj = f["friendId"];

    //make sure both of the values are user objects and now just rawIDs
    if (userObj is Map<String, dynamic> &&
        friendObj is Map<String, dynamic>) {
      final userId = userObj["_id"]?.toString();
      final friendId = friendObj["_id"]?.toString(); 

      if (userId == me) return friendObj;  //logged in sender -> show reciever
      if (friendId == me) return userObj; //logged in is reciever -> show sender
      return friendObj;
    }
    return null;
  }

  // fetch accepted friends from backend and convert friendship records
  // into a clean list of just friend user objects
  Future<void> _fetchFriends() async {
    if (widget.userId == null) return;

    setState(() {
      _loadingFriends = true;
      _friendsError = null;
    });

    try {
      final uri = Uri.parse("$_baseUrl/friendships/user/${widget.userId}");
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception("Friends fetch failed (${resp.statusCode}): ${resp.body}");
      }

      final data = jsonDecode(resp.body) as List<dynamic>;

      final extractedFriends = data
          .map((f) => _otherUserFromFriendship(f))
          .whereType<Map<String, dynamic>>()
          .toList();

      setState(() {
        _friends
          ..clear()
          ..addAll(extractedFriends);
      });
    } catch (e) {
      setState(() {
        _friendsError = e.toString();
      });
    } finally {
      setState(() {
        _loadingFriends = false;
      });
    }
  }

  Future<void> _searchSpotifyTracks(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _searchResults.clear();
        _searchError = null;
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
        throw Exception("Search failed (${resp.statusCode}): ${resp.body}");
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final tracks = (data["tracks"] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      setState(() {
        _searchResults
          ..clear()
          ..addAll(tracks);
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

  //function to pick a cover image (uploading functionality)
  Future<void> _pickCoverImage() async {
    try {
      setState(() => _coverError = null);

      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200, // keeps it reasonably sized
        imageQuality: 85, // compress a bit
      );

      if (file == null) return; // user canceled

      final bytes = await file.readAsBytes(); // works on web + mobile

      setState(() {
        _coverFile = file;
        _coverBytes = bytes;
      });
    } catch (e) {
      setState(() => _coverError = "Couldn’t pick image: $e");
    }
  }

  // called when user taps a result
  void _addSpotifyTrackFromResult(Map<String, dynamic> t) {
    final trackId = (t["spotify_track_id"] ?? "").toString();
    final name = (t["name"] ?? "").toString();
    final artist = (t["artist"] ?? "").toString();
    final label = "$name — $artist";

    if (trackId.isEmpty) return;

    final alreadyAdded = _songs.any((s) => s["spotify_track_id"] == trackId);
    if (alreadyAdded) return;

    setState(() {
      _songs.add({
        "spotify_track_id": trackId,
        "label": label,
      });

      _songSearchController.clear();
      _searchResults.clear();
      _searchError = null;
    });
  }

  //helper function to submit a mixtape to the database
  Future<void> _createMixtape() async {
    if (widget.userId == null) return;

    final title = _mixtapeTitleController.text.trim();
    final message = _mixtapeMessageController.text.trim();
    final receiverId = _selectedFriendId;

    if (title.isEmpty) {
      setState(() => _createMixtapeError = "Please enter a mixtape title.");
      return;
    }

    if (receiverId == null || receiverId.isEmpty) {
      setState(() => _createMixtapeError = "Please select a friend.");
      return;
    }

    if (_songs.isEmpty) {
      setState(() => _createMixtapeError = "Please add at least one song.");
      return;
    }

    final tracks = _songs.asMap().entries.map((entry) {
      return {
        "spotify_track_id": entry.value["spotify_track_id"],
        "track_order": entry.key + 1,
      };
    }).toList();

    setState(() {
      _creatingMixtape = true;
      _createMixtapeError = null;
      _createMixtapeSuccess = null;
    });

    try {
      final uri = Uri.parse("$_baseUrl/mixtapes");

      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "creatorId": widget.userId,
          "receiverId": receiverId,
          "message": message,
          "type": (_mixtapeType ?? "CD").toLowerCase(),
          "visibility": "public",
          "cover_image_url": "", // later replace with uploaded image url
          "tracks": tracks,
        }),
      );

      if (resp.statusCode != 201) {
        throw Exception("Create mixtape failed (${resp.statusCode}): ${resp.body}");
      }

      setState(() {
        _createMixtapeSuccess = "Mixtape sent!";
        _mixtapeTitleController.clear();
        _mixtapeMessageController.clear();
        _receiverUsernameController.clear();
        _songSearchController.clear();
        _songs.clear();
        _searchResults.clear();
        _selectedFriendId = null;
        _mixtapeType = null;
        _coverFile = null;
        _coverBytes = null;
      });
    } catch (e) {
      setState(() => _createMixtapeError = e.toString());
    } finally {
      setState(() => _creatingMixtape = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildLeftFormCard()),
                            const SizedBox(width: 24),
                            SizedBox(width: 364, child: _buildRightSongsCard()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftFormCard(),
                            const SizedBox(height: 20),
                            _buildRightSongsCard(),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Mixtape Title",
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _mixtapeTitleController,
            decoration: InputDecoration(
              hintText: "Enter mixtape title",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),

          //this should be a dropdown with a list of the user's current friends
          const Text(
            "Receiver Username",
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 8),

          //friends dropdown
          if (_loadingFriends)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            )
          else
            DropdownButtonFormField<String>(
              value: _selectedFriendId,
              decoration: InputDecoration(
                hintText: "Select a friend",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _friends.map((friend) {
                final id = friend["_id"]?.toString() ?? "";
                final handle = (friend["spotify_user_id"] ?? friend["username"] ?? "").toString();
                final name = (friend["name"] ?? "").toString();

                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(name.isNotEmpty ? "$name (@$handle)" : "@$handle"),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFriendId = value;

                  // when user selects from dropdown, also fill in the receiver text box
                  final selectedFriend = _friends.cast<Map<String, dynamic>?>().firstWhere(
                        (f) => f?["_id"]?.toString() == value,
                        orElse: () => null,
                      );

                  if (selectedFriend != null) {
                    final handle = (selectedFriend["spotify_user_id"] ??
                            selectedFriend["username"] ??
                            "")
                        .toString();

                    _receiverUsernameController.text = handle;
                  }
                });
              },
            ),

          if (_friendsError != null) ...[
            const SizedBox(height: 6),
            Text(
              _friendsError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),

          //mixtape message
          const Text(
            "Mixtape Message",
            style: TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.40,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _mixtapeMessageController,
            decoration: InputDecoration(
              hintText: "Message",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 20),

          // Cover Image + Type row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Cover Image",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickCoverImage,
                      child: Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _coverBytes == null
                            ? const Center(
                                child: Text(
                                  "Upload Image",
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.memory(
                                    _coverBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                  // optional little edit badge
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              //error handling the cover image
              if (_coverError != null) ...[
                const SizedBox(height: 6),
                Text(_coverError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Type",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _mixtapeType,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFFF8BD2),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFFF8BD2)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      dropdownColor: Colors.white,
                      iconEnabledColor: Colors.white,
                      hint: const Text(
                        "Select an Item",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter'),
                      ),
                      style: const TextStyle(color: Colors.black),
                      items: const [
                        DropdownMenuItem(value: "CD", child: Text("CD")),
                        DropdownMenuItem(value: "Cassette", child: Text("Cassette")),
                        DropdownMenuItem(value: "Vinyl", child: Text("Vinyl")),
                      ],
                      onChanged: (val) => setState(() => _mixtapeType = val),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            "Add Songs",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),

          // - onChanged triggers debounced search
          // - button can manually add pasted URL/ID if you want
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _songSearchController,
                  decoration: InputDecoration(
                    hintText: "Search Spotify songs",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9999)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9999),
                      borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    suffixIcon: _isSearching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : (_songSearchController.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _songSearchController.clear();
                                  setState(() {
                                    _searchResults.clear();
                                    _searchError = null;
                                  });
                                },
                              )),
                  ),
                  onChanged: (val) {
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 300), () {
                      _searchSpotifyTracks(val);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),

          // results list appears right under the search bar
          const SizedBox(height: 10),

          if (_searchError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _searchError!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          if (_searchResults.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final t = _searchResults[i];
                  final name = (t["name"] ?? "").toString();
                  final artist = (t["artist"] ?? "").toString();
                  final album = (t["album"] ?? "").toString();
                  final imageUrl = t["imageUrl"]?.toString();

                  return ListTile(
                    leading: (imageUrl != null && imageUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(imageUrl, width: 42, height: 42, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.music_note),
                    title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      "$artist • $album",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _addSpotifyTrackFromResult(t),
                  );
                },
              ),
            ),

          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8AD2),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _creatingMixtape ? null : _createMixtape,
                child: _creatingMixtape
                  ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text(
                      "Create Mixtape",
                      style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Roboto'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSongsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Songs Added:",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          const SizedBox(height: 12),

          if (_songs.isEmpty)
            const Text("No songs yet.", style: TextStyle(color: Colors.black54))
          else
            ..._songs.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  s["label"] ?? (s["spotify_track_id"] ?? ""),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}