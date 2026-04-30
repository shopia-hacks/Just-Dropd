import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_dropd/shared/countdown_clock.dart';
import 'package:just_dropd/theme/theme.dart';

const String _baseUrl = "https://api.justdropd.com";

class CreateCountdownPage extends StatefulWidget {
  final String? userId;
  const CreateCountdownPage({super.key, required this.userId});

  @override
  State<CreateCountdownPage> createState() => _CreateCountdownPageState();
}

class _CreateCountdownPageState extends State<CreateCountdownPage> {
  final TextEditingController _artistSearchController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  List<Map<String, dynamic>> _artistResults = [];
  bool _isSearching = false;
  String? _searchError;
  Timer? _debounce;

  Map<String, dynamic>? _selectedArtist;

  DateTime? _selectedDate;
  bool _setAsMain = false;

  bool _isSubmitting = false;
  String? _submitError;

  String _selectedClockStyle = "blue";

  @override
  void dispose() {
    _debounce?.cancel();
    _artistSearchController.dispose();
    _titleController.dispose();
    super.dispose();
  }

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
        queryParameters: {"userId": widget.userId ?? "", "q": q},
      );

      final resp = await http.get(uri);
      if (resp.statusCode != 200) throw Exception();

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      setState(() {
        _artistResults = (data["artists"] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        _isSearching = false;
      });
    } catch (_) {
      setState(() {
        _artistResults = [];
        _isSearching = false;
        _searchError = "Search failed. Please try again.";
      });
    }
  }

  void _clearSelectedArtist() {
    setState(() {
      _selectedArtist = null;
      _artistResults = [];
      _artistSearchController.clear();
      _submitError = null;
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: "Select expected release date",
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppTheme.red,
              onPrimary: AppTheme.pink,
              surface: AppTheme.white,
              onSurface: AppTheme.blue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.green,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

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
          "userId": widget.userId,
          "artist_name": _selectedArtist!["artist_name"],
          "release_date": _selectedDate!.toIso8601String(),
          if ((_titleController.text.trim()).isNotEmpty)
            "album_title": _titleController.text.trim(),
          if (_selectedArtist!["image_url"] != null)
            "cover_art_url": _selectedArtist!["image_url"],
          "spotify_artist_id": _selectedArtist!["spotify_artist_id"],
          "is_main": _setAsMain,
          "clock_style": _selectedClockStyle,
        }),
      );

      if (resp.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.green,
            content: Text(
              "Countdown added! 🎶",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.blue,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        );
      } else if (resp.statusCode == 409) {
        setState(() {
          _submitError =
              "You already have a countdown for this artist and date.";
        });
      } else {
        setState(() {
          _submitError = "Something went wrong. Please try again.";
        });
      }
    } catch (_) {
      setState(() => _submitError = "Could not reach server.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  bool get _showPreview => _selectedArtist != null && _selectedDate != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "Add a Countdown",
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppTheme.blue,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showPreview) ...[
              _buildPreviewCard(),
              const SizedBox(height: 28),
            ],

            const _SectionLabel(number: "1", text: "Search for an artist *"),
            const SizedBox(height: 10),

            if (_selectedArtist != null)
              _SelectedArtistCard(
                artist: _selectedArtist!,
                onClear: _clearSelectedArtist,
              )
            else ...[
              TextField(
                controller: _artistSearchController,
                decoration:
                    _inputDecoration("e.g. ASAP Rocky, Billie Eilish..."),
                onChanged: (val) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 400), () {
                    _searchArtists(val);
                  });
                },
              ),
              if (_isSearching) ...[
                const SizedBox(height: 12),
                Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.blue,
                  ),
                ),
              ],
              if (_searchError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _searchError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.red,
                  ),
                ),
              ],
              if (_artistResults.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  "Tap an artist to select",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.green,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  color: AppTheme.green,
                  margin: EdgeInsets.zero,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _artistResults.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 0),
                    itemBuilder: (context, index) {
                      final artist = _artistResults[index];
                      final genres = (artist["genres"] as List?) ?? [];

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        leading: artist["image_url"] != null
                            ? ClipOval(
                                child: Image.network(
                                  artist["image_url"],
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: AppTheme.blue,
                                child: Icon(
                                  Icons.person,
                                  color: AppTheme.green,
                                ),
                              ),
                        title: Text(
                          artist["artist_name"] ?? "",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.blue,
                          ),
                        ),
                        subtitle: genres.isNotEmpty
                            ? Text(
                                genres.join(", "),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.blue,
                                ),
                              )
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

            const _SectionLabel(number: "2", text: "Expected release date *"),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppLayout.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: AppTheme.blue,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : "Tap to pick a date",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const _SectionLabel(
              number: "3",
              text: "Album / project title (optional)",
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration(
                "Title if known — you can add or update this later",
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              "Don't know the title yet? No problem — you can update it later.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.green,
              ),
            ),

            const SizedBox(height: 24),

            const _SectionLabel(number: "4", text: "Choose clock color"),
            const SizedBox(height: 12),
            _ClockStylePicker(
              selectedStyle: _selectedClockStyle,
              onSelected: (style) {
                setState(() => _selectedClockStyle = style);
              },
            ),

            const SizedBox(height: 24),

            Card(
              color: AppTheme.white,
              margin: EdgeInsets.zero,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Switch(
                      value: _setAsMain,
                      activeColor: AppTheme.green,
                      activeTrackColor: AppTheme.blue,
                      inactiveThumbColor: AppTheme.orange,
                      inactiveTrackColor: AppTheme.yellow,
                      onChanged: (val) => setState(() => _setAsMain = val),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Set as my main countdown",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.blue,
                            ),
                          ),
                          Text(
                            "Shows at the top of your profile",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_submitError != null) ...[
              const SizedBox(height: 12),
              Text(
                _submitError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.red,
                ),
              ),
            ],

            const SizedBox(height: 28),

            Center(
              child: SizedBox(
                width: 220,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.blue,
                    foregroundColor: AppTheme.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isSubmitting
                      ? CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: AppTheme.green,
                        )
                      : Text(
                          "Add Countdown",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final theme = Theme.of(context);
    final artistName = _selectedArtist!["artist_name"] ?? "";
    final imageUrl = _selectedArtist!["image_url"] as String?;
    final title = _titleController.text.trim();

    final releaseDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
    );

    // Resolve what color the clock will actually be
    final effectiveStyle = AppClockTheme.effectiveStyle(
      _selectedClockStyle,
      isMain: _setAsMain,
    );
    final shellColor     = AppClockTheme.shellColor(effectiveStyle);
    final highlightColor = AppClockTheme.highlightColor(effectiveStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Preview",
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.green,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          color: Colors.white,
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppLayout.cardPadding),
            child: Column(
              children: [
                Row(
                  children: [
                    if (imageUrl != null)
                      ClipOval(
                        child: Image.network(
                          imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: shellColor,
                        child: Icon(Icons.person, color: highlightColor),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : "Untitled Project",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: shellColor,       // matches clock body
                            ),
                          ),
                          Text(
                            artistName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: shellColor,       // matches digits
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CountdownClock(
                  releaseDate: releaseDateTime,
                  clockStyle: _selectedClockStyle,
                  isMain: _setAsMain,              // ← this is what was missing
                  compact: false,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
    );
  }
}

class _SelectedArtistCard extends StatelessWidget {
  final Map<String, dynamic> artist;
  final VoidCallback onClear;

  const _SelectedArtistCard({
    required this.artist,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genres = (artist["genres"] as List?) ?? [];

    return Card(
      color: AppTheme.blue,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            if (artist["image_url"] != null)
              ClipOval(
                child: Image.network(
                  artist["image_url"],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            else
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.green,
                child: Icon(
                  Icons.person,
                  color: AppTheme.blue,
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    artist["artist_name"] ?? "",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.green,
                    ),
                  ),
                  if (genres.isNotEmpty)
                    Text(
                      genres.join(", "),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.pink,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: Icon(
                Icons.close,
                size: 20,
                color: AppTheme.red,
              ),
              tooltip: "Change artist",
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String number;
  final String text;

  const _SectionLabel({
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppTheme.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.blue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.blue,
          ),
        ),
      ],
    );
  }
}

class _ClockStylePicker extends StatelessWidget {
  final String selectedStyle;
  final ValueChanged<String> onSelected;

  const _ClockStylePicker({
    required this.selectedStyle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: AppClockTheme.userStyles.map((style) {
        final shell     = AppClockTheme.shellColor(style);
        final highlight = AppClockTheme.highlightColor(style);
        final selected  = selectedStyle == style;

        return GestureDetector(
          onTap: () => onSelected(style),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: shell,
              borderRadius: BorderRadius.circular(AppLayout.radiusMd),
              border: selected
                  ? Border.all(color: highlight, width: 2.5)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, color: highlight, size: 18),
                const SizedBox(width: 8),
                Text(
                  AppClockTheme.label(style),
                  style: TextStyle(
                    color: highlight,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.check_circle, color: highlight, size: 16),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}