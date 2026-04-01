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
  List<dynamic> _pendingMixtapes = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingMixtapes();
  }

  Future<void> _fetchPendingMixtapes() async {
    if (widget.userId == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse("$_baseUrl/mixtapes/user/${widget.userId}/incoming");
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception("Failed to load feed (${resp.statusCode}): ${resp.body}");
      }

      setState(() {
        _pendingMixtapes = jsonDecode(resp.body) as List<dynamic>;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
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

      await _fetchPendingMixtapes();
    } catch (e) {
      setState(() => _error = e.toString());
    }
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
                : _pendingMixtapes.isEmpty
                    ? const Center(child: Text("No pending mixtapes."))
                    : ListView.builder(
                        itemCount: _pendingMixtapes.length,
                        itemBuilder: (context, index) {
                          final m = _pendingMixtapes[index] as Map<String, dynamic>;
                          final creator = m["creatorId"] as Map<String, dynamic>?;
                          final senderName =
                              (creator?["name"] ?? creator?["username"] ?? "Friend").toString();

                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m["title"]?.toString() ?? "Untitled Mixtape",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text("From: $senderName"),
                                  const SizedBox(height: 6),
                                  Text(m["message"]?.toString() ?? ""),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () => _respondToMixtape(
                                          m["_id"].toString(),
                                          "rejected",
                                        ),
                                        child: const Text("Decline"),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () => _respondToMixtape(
                                          m["_id"].toString(),
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
                        },
                      ),
      ),
    );
  }
}