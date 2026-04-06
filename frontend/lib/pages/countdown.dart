import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';
import 'package:just_dropd/shared/countdown_clock.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = "http://localhost:3000";

class CountdownPage extends StatefulWidget {
  final String? userId;
  const CountdownPage({super.key, required this.userId});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {

  // which tab is active: "Friends" or "Me"
  String _activeTab = "Friends";

  List<Map<String, dynamic>> _friendsCountdowns = [];
  List<Map<String, dynamic>> _myCountdowns = [];

  bool _loadingFriends = true;
  bool _loadingMe = true;
  String? _friendsError;
  String? _meError;

  @override
  void initState() {
    super.initState();
    _fetchFriendsCountdowns();
    _fetchMyCountdowns();
  }

  Future<void> _fetchFriendsCountdowns() async {
    if (widget.userId == null) return;
    setState(() {
      _loadingFriends = true;
      _friendsError = null;
    });
    try {
      final uri = Uri.parse("$_baseUrl/countdowns/friends");
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"userId": widget.userId}),
      );
      if (resp.statusCode != 200) throw Exception();
      final data = jsonDecode(resp.body) as List<dynamic>;
      setState(() => _friendsCountdowns = data.cast<Map<String, dynamic>>());
    } catch (_) {
      setState(() => _friendsError = "Could not load countdowns.");
    } finally {
      setState(() => _loadingFriends = false);
    }
  }

  Future<void> _fetchMyCountdowns() async {
    if (widget.userId == null) return;
    setState(() {
      _loadingMe = true;
      _meError = null;
    });
    try {
      final uri = Uri.parse("$_baseUrl/countdowns/user/${widget.userId}");
      final resp = await http.get(uri);
      if (resp.statusCode != 200) throw Exception();
      final data = jsonDecode(resp.body) as List<dynamic>;
      setState(() => _myCountdowns = data.cast<Map<String, dynamic>>());
    } catch (_) {
      setState(() => _meError = "Could not load your countdowns.");
    } finally {
      setState(() => _loadingMe = false);
    }
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  // ── show the dropdown menu anchored below the tapped label ─────────────────
  void _showTabDropdown(BuildContext context) async {
    // find where on screen the label is so we can anchor the menu there
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: ["Friends", "Me"].map((tab) {
        final isActive = tab == _activeTab;
        return PopupMenuItem<String>(
          value: tab,
          child: Row(
            children: [
              Text(
                tab,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check, size: 16, color: Colors.black),
              ],
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null && selected != _activeTab) {
      setState(() => _activeTab = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        _activeTab == "Friends" ? _loadingFriends : _loadingMe;
    final error =
        _activeTab == "Friends" ? _friendsError : _meError;
    final countdowns =
        _activeTab == "Friends" ? _friendsCountdowns : _myCountdowns;
    final onRefresh =
        _activeTab == "Friends" ? _fetchFriendsCountdowns : _fetchMyCountdowns;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── header: "Countdowns  Friends ˅" all on one line ───────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // page title
                  Text(
                    "Countdowns",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26)
                  ),

                  const SizedBox(width: 12),

                  // dropdown trigger — tapping this opens the menu
                  Builder(
                    builder: (innerContext) => GestureDetector(
                      onTap: () => _showTabDropdown(innerContext),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _activeTab,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // refresh button stays top right
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                    onPressed: () {
                      _fetchFriendsCountdowns();
                      _fetchMyCountdowns();
                    },
                  ),
                ],
              ),
            ),

            // ── feed ─────────────────────────────────────────────────────────
            Expanded(
              child: _buildFeedList(
                loading: isLoading,
                error: error,
                countdowns: countdowns,
                showUsername: _activeTab == "Friends",
                onRefresh: onRefresh,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedList({
    required bool loading,
    required String? error,
    required List<Map<String, dynamic>> countdowns,
    required bool showUsername,
    required Future<void> Function() onRefresh,
  }) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error, style: TextStyle(color: Theme.of(context).colorScheme.error),),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text("Try again"),
            ),
          ],
        ),
      );
    }
    if (countdowns.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("No countdowns yet.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),),
            const SizedBox(height: 6),
            Text("Tap + to add one!",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),)
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: countdowns.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _CountdownCard(
          countdown: countdowns[index],
          showUsername: showUsername,
          parseDate: _parseDate,
          formatDate: _formatDate,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CountdownCard
// ─────────────────────────────────────────────────────────────────────────────
class _CountdownCard extends StatelessWidget {
  final Map<String, dynamic> countdown;
  final bool showUsername;
  final DateTime? Function(dynamic) parseDate;
  final String Function(DateTime) formatDate;

  const _CountdownCard({
    required this.countdown,
    required this.showUsername,
    required this.parseDate,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    final artistName  = (countdown["artist_name"]  ?? "Unknown Artist").toString();
    final albumTitle  = countdown["album_title"]?.toString();
    final coverArtUrl = countdown["cover_art_url"]?.toString();
    final clockStyle  = countdown["clock_style"]?.toString() ?? "digital_default";
    final releaseDate = parseDate(countdown["release_date"]);
    final isMain      = countdown["is_main"] == true;

    String? username;
    if (showUsername) {
      final userObj = countdown["userId"];
      if (userObj is Map<String, dynamic>) {
        username = userObj["name"]?.toString() ?? userObj["username"]?.toString();
      }
    }

    return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: isMain ? const Color(0xFFFF3B30) : Colors.black12,
        width: isMain ? 2 : 1,
      ),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── top row ────────────────────────────────────────────────────────
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: coverArtUrl != null
                    ? Image.network(
                        coverArtUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isMain) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "MAIN",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      albumTitle ?? "Untitled Project",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      artistName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    if (showUsername && username != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "$username is waiting for this",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── clock ──────────────────────────────────────────────────────────
          if (releaseDate != null)
            Center(
              child: CountdownClock(
                releaseDate: releaseDate,
                clockStyle: clockStyle,
              ),
            )
          else
            const Center(
              child: Text("Release date TBA",
                  style: TextStyle(color: Colors.black38, fontSize: 13)),
            ),

          if (releaseDate != null) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Expected ${formatDate(releaseDate)}",
                style: const TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    ),
  );
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Icon(Icons.music_note, color: Colors.grey, size: 28),
    );
  }
}