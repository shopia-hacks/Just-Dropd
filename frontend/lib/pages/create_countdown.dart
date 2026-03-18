import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_dropd/shared/countdown_clock.dart';

const String _baseUrl = "http://localhost:3000";

class CreateCountdownPage extends StatefulWidget {
  final String? userId;
  const CreateCountdownPage({super.key, required this.userId});

  @override
  State<CreateCountdownPage> createState() => _CreateCountdownPageState();
}

class _CreateCountdownPageState extends State<CreateCountdownPage> {

  // ── artist search ──────────────────────────────────────────────────────────
  final TextEditingController _artistSearchController = TextEditingController();
  List<Map<String, dynamic>> _artistResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounce;

  // ── selected artist ────────────────────────────────────────────────────────
  Map<String, dynamic>? _selectedArtist;

  // ── optional fields ────────────────────────────────────────────────────────
  final TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDate;
  bool _setAsMain = false;

  // ── submission ─────────────────────────────────────────────────────────────
  bool _isSubmitting = false;
  String? _submitError;

  @override
  void dispose() {
    _debounce?.cancel();
    _artistSearchController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // ── search Spotify artists ─────────────────────────────────────────────────
  Future<void> _searchArtists(String query) async {
    final q = query.trim();

    if (q.isEmpty) {
      setState(() {
        _artistResults = [];
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
      final uri = Uri.parse("$_baseUrl/spotify/search-artist").replace(
        queryParameters: {
          "userId": widget.userId ?? "",
          "q": q,
        },
      );

      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception("Search failed (${resp.statusCode}): ${resp.body}");
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final artists = (data["artists"] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();

      setState(() {
        _artistResults = artists;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _artistResults = [];
        _isSearching = false;
        _searchError = "Search failed. Please try again.";
      });
    }
  }

  // ── clear selected artist ──────────────────────────────────────────────────
  void _clearSelectedArtist() {
    setState(() {
      _selectedArtist = null;
      _artistResults = [];
      _artistSearchController.clear();
      _submitError = null;
    });
  }

  // ── open date picker ───────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: "Select expected release date",
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Colors.black),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // ── submit: POST /countdowns ───────────────────────────────────────────────
  Future<void> _submit() async {
    if (_selectedArtist == null) {
      setState(() => _submitError = "Please select an artist.");
      return;
    }
    if (_selectedDate == null) {
      setState(() => _submitError = "Please select an expected release date.");
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final uri = Uri.parse("$_baseUrl/countdowns");
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId":            widget.userId,
          "artist_name":       _selectedArtist!["artist_name"],
          "release_date":      _selectedDate!.toIso8601String(),
          if ((_titleController.text.trim()).isNotEmpty)
            "album_title":     _titleController.text.trim(),
          if (_selectedArtist!["image_url"] != null)
            "cover_art_url":   _selectedArtist!["image_url"],
          "spotify_artist_id": _selectedArtist!["spotify_artist_id"],
          "is_main":           _setAsMain,
        }),
      );

      debugPrint("Submit response: ${resp.statusCode} — ${resp.body}"); 

      if (resp.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Countdown added! 🎶")),
        );
      } else if (resp.statusCode == 409) {
        setState(() => _submitError = "You already have a countdown for this artist and date.");
      } else {
        setState(() => _submitError = "Something went wrong. Please try again.");
      }
    } catch (e) {
      setState(() => _submitError = "Could not reach server.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // ── date formatting helper ─────────────────────────────────────────────────
  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  // ── whether to show the live preview ──────────────────────────────────────
  bool get _showPreview => _selectedArtist != null && _selectedDate != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add a Countdown"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── LIVE PREVIEW — shown once artist + date are both set ─────────
            if (_showPreview) ...[
              _buildPreviewCard(),
              const SizedBox(height: 28),
            ],

            // ── STEP 1: Artist search ────────────────────────────────────────
            _SectionLabel(number: "1", text: "Search for an artist  *"),
            const SizedBox(height: 10),

            if (_selectedArtist != null)
              _SelectedArtistCard(
                artist: _selectedArtist!,
                onClear: _clearSelectedArtist,
              )
            else ...[
              TextField(
                controller: _artistSearchController,
                decoration: _inputDecoration("e.g. ASAP Rocky, Billie Eilish..."),
                onChanged: (val) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    _searchArtists(val);
                  });
                },
              ),

              if (_isSearching) ...[
                const SizedBox(height: 12),
                const Center(child: CircularProgressIndicator()),
              ],

              if (_searchError != null) ...[
                const SizedBox(height: 6),
                Text(_searchError!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],

              if (_artistResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text(
                  "Tap an artist to select",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _artistResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final artist = _artistResults[index];
                      return ListTile(
                        leading: artist["image_url"] != null
                            ? ClipOval(
                                child: Image.network(
                                  artist["image_url"],
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(
                          artist["artist_name"] ?? "",
                          style:
                              const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: (artist["genres"] as List).isNotEmpty
                            ? Text((artist["genres"] as List).join(", "))
                            : null,
                        onTap: () => setState(() {
                          _selectedArtist = artist;
                          _artistResults = [];
                          _artistSearchController.clear();
                          _submitError = null;
                        }),
                      );
                    },
                  ),
                ),
              ],
            ],

            const SizedBox(height: 24),

            // ── STEP 2: Release date ─────────────────────────────────────────
            _SectionLabel(number: "2", text: "Expected release date  *"),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : "Tap to pick a date",
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedDate != null
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── STEP 3: Optional title ───────────────────────────────────────
            _SectionLabel(
                number: "3", text: "Album / project title  (optional)"),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration(
                  "Title if known — you can add or update this later"),
              // rebuild so preview title updates live as user types
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 6),
            const Text(
              "Don't know the title yet? No problem — you can update it later.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // ── Set as main toggle ───────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Switch(
                    value: _setAsMain,
                    activeColor: Colors.black,
                    onChanged: (val) => setState(() => _setAsMain = val),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Set as my main countdown",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Shows at the top of your profile",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_submitError != null) ...[
              const SizedBox(height: 12),
              Text(_submitError!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ],

            const SizedBox(height: 20),

            // ── submit button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text("Add Countdown",
                        style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── live preview card ──────────────────────────────────────────────────────
  // Shown at the top once the user has picked both an artist and a date.
  // Gives them a real-time preview of what their countdown will look like.
  Widget _buildPreviewCard() {
    final artistName = _selectedArtist!["artist_name"] ?? "";
    final imageUrl   = _selectedArtist!["image_url"] as String?;
    final title      = _titleController.text.trim();

    // set release time to midnight on the selected date
    final releaseDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Preview",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // artist image + name + optional album title
              Row(
                children: [
                  if (imageUrl != null)
                    ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.isNotEmpty ? title : "Untitled Project",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          artistName,
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // the live countdown clock
              CountdownClock(releaseDate: releaseDateTime),

              const SizedBox(height: 4),
            ],
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}

// ── selected artist card ───────────────────────────────────────────────────
class _SelectedArtistCard extends StatelessWidget {
  final Map<String, dynamic> artist;
  final VoidCallback onClear;

  const _SelectedArtistCard({required this.artist, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.black, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (artist["image_url"] != null)
            ClipOval(
              child: Image.network(
                artist["image_url"],
                width: 46,
                height: 46,
                fit: BoxFit.cover,
              ),
            )
          else
            const CircleAvatar(radius: 23, child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist["artist_name"] ?? "",
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
                if ((artist["genres"] as List).isNotEmpty)
                  Text(
                    (artist["genres"] as List).join(", "),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close, size: 20),
            tooltip: "Change artist",
          ),
        ],
      ),
    );
  }
}

// ── numbered section label ─────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String number;
  final String text;
  const _SectionLabel({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
              color: Colors.black, shape: BoxShape.circle),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}