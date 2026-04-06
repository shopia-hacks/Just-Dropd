import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';
import 'package:just_dropd/shared/countdown_clock.dart';
import 'package:just_dropd/theme/theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String _baseUrl = 'http://localhost:3000';

class CountdownPage extends StatefulWidget {
  final String? userId;
  const CountdownPage({super.key, required this.userId});

  @override
  State<CountdownPage> createState() => _CountdownPageState();
}

class _CountdownPageState extends State<CountdownPage> {
  String _activeTab = 'Friends';

  List<Map<String, dynamic>> _friendsCountdowns = [];
  List<Map<String, dynamic>> _myCountdowns      = [];
  bool   _loadingFriends = true;
  bool   _loadingMe      = true;
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
    setState(() { _loadingFriends = true; _friendsError = null; });
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/countdowns/friends'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': widget.userId}),
      );
      if (resp.statusCode != 200) throw Exception();
      setState(() => _friendsCountdowns =
          (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>());
    } catch (_) {
      setState(() => _friendsError = 'Could not load countdowns.');
    } finally {
      setState(() => _loadingFriends = false);
    }
  }

  Future<void> _fetchMyCountdowns() async {
    if (widget.userId == null) return;
    setState(() { _loadingMe = true; _meError = null; });
    try {
      final resp = await http.get(
          Uri.parse('$_baseUrl/countdowns/user/${widget.userId}'));
      if (resp.statusCode != 200) throw Exception();
      setState(() => _myCountdowns =
          (jsonDecode(resp.body) as List).cast<Map<String, dynamic>>());
    } catch (_) {
      setState(() => _meError = 'Could not load your countdowns.');
    } finally {
      setState(() => _loadingMe = false);
    }
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    try { return DateTime.parse(raw.toString()); } catch (_) { return null; }
  }

  String _formatDate(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun',
                'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  void _showTabDropdown(BuildContext context) async {
    final box     = context.findRenderObject() as RenderBox;
    final overlay = Navigator.of(context).overlay!.context
        .findRenderObject() as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: pos,
      color: AppTheme.blue,
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.radiusMd)),
      items: ['Friends', 'Me'].map((tab) {
        final active = tab == _activeTab;
        return PopupMenuItem<String>(
          value: tab,
          child: Row(children: [
            Text(tab,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? AppTheme.green : AppTheme.pink,
                )),
            if (active) ...[
              const SizedBox(width: 8),
              Icon(Icons.check, size: 16, color: AppTheme.green),
            ],
          ]),
        );
      }).toList(),
    );

    if (selected != null && selected != _activeTab) {
      setState(() => _activeTab = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading  = _activeTab == 'Friends' ? _loadingFriends : _loadingMe;
    final error      = _activeTab == 'Friends' ? _friendsError   : _meError;
    final countdowns = _activeTab == 'Friends' ? _friendsCountdowns : _myCountdowns;
    final onRefresh  = _activeTab == 'Friends'
        ? _fetchFriendsCountdowns
        : _fetchMyCountdowns;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.pagePadding, 20,
                AppLayout.pagePadding, AppLayout.itemGap,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Countdowns',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 28, color: AppTheme.red)),
                  const SizedBox(width: 12),
                  Builder(
                    builder: (ctx) => GestureDetector(
                      onTap: () => _showTabDropdown(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.green,
                          borderRadius:
                              BorderRadius.circular(AppLayout.radiusMd),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(_activeTab,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontSize: 15,
                                    color: AppTheme.blue,
                                    fontWeight: FontWeight.w700,
                                  )),
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              size: 18, color: AppTheme.blue),
                        ]),
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: AppTheme.blue),
                    onPressed: () {
                      _fetchFriendsCountdowns();
                      _fetchMyCountdowns();
                    },
                  ),
                ],
              ),
            ),
            // ── Feed ────────────────────────────────────────────────────────
            Expanded(
              child: _buildFeedList(
                loading: isLoading,
                error: error,
                countdowns: countdowns,
                showUsername: _activeTab == 'Friends',
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
      return Center(
          child: CircularProgressIndicator(color: AppTheme.blue));
    }
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.pagePadding),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(error,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.red)),
            const SizedBox(height: AppLayout.itemGap),
            ElevatedButton(onPressed: onRefresh, child: const Text('Try again')),
          ]),
        ),
      );
    }
    if (countdowns.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppLayout.pagePadding),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('No countdowns yet.',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppLayout.smallGap),
            Text('Tap + to add one!',
                style: Theme.of(context).textTheme.bodyMedium),
          ]),
        ),
      );
    }

    return RefreshIndicator(
      color: AppTheme.blue,
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppLayout.pagePadding, 0,
          AppLayout.pagePadding, AppLayout.sectionGap,
        ),
        itemCount: countdowns.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppLayout.itemGap),
        itemBuilder: (context, i) => _CountdownCard(
          countdown: countdowns[i],
          showUsername: showUsername,
          parseDate: _parseDate,
          formatDate: _formatDate,
        ),
      ),
    );
  }
}

// ─── Countdown card ──────────────────────────────────────────────────────────
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
    final artistName  = (countdown['artist_name'] ?? 'Unknown Artist').toString();
    final albumTitle  = countdown['album_title']?.toString();
    final coverArtUrl = countdown['cover_art_url']?.toString();
    final clockStyle  = countdown['clock_style']?.toString() ?? 'digital_default';
    final releaseDate = parseDate(countdown['release_date']);
    final isMain      = countdown['is_main'] == true;

    // Compute once here — both InfoSection and the clock use this
    final effectiveStyle = AppClockTheme.effectiveStyle(
      clockStyle,
      isMain: isMain,
    );

    String? username;
    if (showUsername) {
      final u = countdown['userId'];
      if (u is Map<String, dynamic>) {
        username = u['name']?.toString() ?? u['username']?.toString();
      }
    }

    return Card(
      // White card — color comes from the clock shell, not the card background
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.cardPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < AppLayout.clockBreakpoint;

            final infoSection = _InfoSection(
              artistName:  artistName,
              albumTitle:  albumTitle,
              coverArtUrl: coverArtUrl,
              username:    showUsername ? username : null,
              isMain:      isMain,
              formatDate:  releaseDate != null ? formatDate(releaseDate) : null,
              effectiveStyle: effectiveStyle,
            );

            final clockSection = releaseDate != null
                ? CountdownClock(
                    releaseDate: releaseDate,
                    clockStyle:  clockStyle,
                    compact:     narrow,   // compact when narrow
                    isMain:      isMain,
                  )
                : Text('Release date TBA',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.red));

            // ── Narrow: artist info on top, clock below ──────────────────
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoSection,
                  const SizedBox(height: AppLayout.itemGap),
                  Center(child: clockSection),
                ],
              );
            }

            // ── Wide: artist info left, clock right (takes more space) ───
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: infoSection),
                const SizedBox(width: AppLayout.itemGap),
                Expanded(flex: 5, child: Align(
                  alignment: Alignment.centerRight,
                  child: clockSection,
                )),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Artist / album info block ───────────────────────────────────────────────
class _InfoSection extends StatelessWidget {
  final String  artistName;
  final String? albumTitle;
  final String? coverArtUrl;
  final String? username;
  final bool    isMain;
  final String? formatDate;
  final String effectiveStyle;

  const _InfoSection({
    required this.artistName,
    required this.albumTitle,
    required this.coverArtUrl,
    required this.username,
    required this.isMain,
    required this.formatDate,
    required this.effectiveStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Derive colors from the effective style once, use everywhere below
    final shellColor     = AppClockTheme.shellColor(effectiveStyle);
    final highlightColor = AppClockTheme.highlightColor(effectiveStyle);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover art
        ClipRRect(
          borderRadius:
              BorderRadius.circular(AppLayout.coverArtRadius),
          child: coverArtUrl != null
              ? Image.network(
                  coverArtUrl!,
                  width:  AppLayout.coverArtSize,
                  height: AppLayout.coverArtSize,
                  fit:    BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(width: AppLayout.itemGap),
        // Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MAIN badge
              if (isMain) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.red,
                    borderRadius:
                        BorderRadius.circular(AppLayout.radiusSm),
                  ),
                  child: Text('MAIN',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color: AppTheme.pink,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          )),
                ),
                const SizedBox(height: AppLayout.smallGap),
              ],
              // Album / project title
              Text(
                albumTitle ?? 'Untitled Project',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: shellColor,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Artist name
              Text(artistName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: shellColor,
                        fontWeight: FontWeight.w600,
                      )),
              // "X is waiting for this"
              if (username != null) ...[
                const SizedBox(height: AppLayout.smallGap),
                Text('$username is waiting for this',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: shellColor,
                          fontWeight: FontWeight.w600,
                        )),
              ],
              // Expected date
              if (formatDate != null) ...[
                const SizedBox(height: 4),
                Text('Expected $formatDate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: highlightColor,
                          fontWeight: FontWeight.w600,
                        )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width:  AppLayout.coverArtSize,
      height: AppLayout.coverArtSize,
      decoration: BoxDecoration(
        color: AppTheme.green,
        borderRadius: BorderRadius.circular(AppLayout.coverArtRadius),
      ),
      child: Icon(Icons.music_note,
          color: AppTheme.blue, size: 30),
    );
  }
}