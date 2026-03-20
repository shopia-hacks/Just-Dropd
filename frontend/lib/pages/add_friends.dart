import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_dropd/shared/nav_bar.dart';

//ADD FRIENDS PAGE - Where users can search for usernames and send and accept/decline friend requests
// 1. Send friend request
// 2. View pending friend requests
// 3. Accept/reject friend requests
// 4. View current friends

class AddFriendsPage extends StatefulWidget {
  final String? userId; // Mongo _id of logged in user
  const AddFriendsPage({super.key, required this.userId});

  @override
  State<AddFriendsPage> createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  //the base url for the backend API so we can pull and push data to the backend
  String get _baseUrl => "http://localhost:3000";

  //controller for the text field where a user types a Spotify username (id)
  final _usernameController = TextEditingController(); //TextEditingController lets us read what the user typed and be able to clear it later

  //states for the different parts of the page (helps show spinners when requests are in progress)
  bool _loadingFriends = false;
  bool _loadingPending = false;
  bool _sending = false;

  //error and success messages to show in the UI
  String? _error;
  String? _success;

  //these arrays will store the data returned from the backend
  List<dynamic> _friends = []; //accepted friends
  List<dynamic> _pending = []; //incoming friend requests

  @override
  void initState() {
    super.initState(); //runs once when the page is first created
    _refreshAll(); //use to immediately load user's friends + pending requests
  }

  @override
  void dispose() {
    _usernameController.dispose(); //always should dispose controllers when widget is removed to prevent memory leaks?
    super.dispose();
  }

  Future<void> _refreshAll() async { //reload friends and current/pending requests at the same time
    await Future.wait([ //Future.wait runs multiple functions in parallel and waits for both
      _fetchFriends(),
      _fetchPending(),
    ]);
  }

  //Helper function to get all accepted friendships for the logged in user
  Future<void> _fetchFriends() async {
    if (widget.userId == null) return; //if somehow the user id doesn't exist (user not logged in, do nothing)

    setState(() { //trigger the loading state and clear any old errors
      _loadingFriends = true;
      _error = null;
    });

    try {
      //build the GET endpoint
      final uri = Uri.parse("$_baseUrl/friendships/user/${widget.userId}");
      final resp = await http.get(uri);

      if (resp.statusCode != 200) { //if backend request railed, throw an error
        throw Exception("Friends fetch failed (${resp.statusCode}): ${resp.body}");
      }

    //convert the JSON response body into a dart list and store it in the friends array from above
      setState(() {
        _friends = jsonDecode(resp.body) as List<dynamic>;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loadingFriends = false);
    }
  }

  //Helper function to fetch the pending friend requests of the logged in user
  Future<void> _fetchPending() async {
    if (widget.userId == null) return;

    setState(() {
      _loadingPending = true;
      _error = null;
    });

    try {
      //GET request for pending friends
      final uri = Uri.parse("$_baseUrl/friendships/user/${widget.userId}/pending");
      final resp = await http.get(uri);

      if (resp.statusCode != 200) {
        throw Exception("Pending fetch failed (${resp.statusCode}): ${resp.body}");
      }

      setState(() {
        _pending = jsonDecode(resp.body) as List<dynamic>; //store the list in the pending array we made earlier
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loadingPending = false);
    }
  }

  //Helper function to send a new friend request to another user
  Future<void> _sendFriendRequest() async {
    if (widget.userId == null) return;

    //get the text the user typed into the box and remove extra spaces
    var friendUsername = _usernameController.text.trim();

    if (friendUsername.isEmpty) return; //if user didn't type anything don't do anything

    // remove leading @ if user typed it
    if (friendUsername.startsWith("@")) {
      friendUsername = friendUsername.substring(1);
    }

    //show the loading state and clear old error messages
    setState(() {
      _sending = true;
      _error = null;
      _success = null;
    });

    try {
      final uri = Uri.parse("$_baseUrl/friendships");

      //send a POST request to the backend with JSON body (the sender + receiver of the friend request)
      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": widget.userId, //sender
          "friendUsername": friendUsername, //person being added
        }),
      );

      if (resp.statusCode == 201) { //"created successfully"
        setState(() {
          _success = "Friend request sent to @$friendUsername";
          _usernameController.clear(); //clear text field after it's submitted
        });
      } else {
        throw Exception("Send failed (${resp.statusCode}): ${resp.body}");
      }
    } catch (e) {
      setState(() => _error = e.toString()); 
    } finally {
      setState(() => _sending = false); //stop the spinner if error or success (either way)
      await _refreshAll();
    }
  }

  //Helper function to accept or reject a pending friend request
  //friendshipID = ID of the friendship record in MongoDB
  //status should be either "accepted" or "rejected"
  Future<void> _respondToRequest(String friendshipId, String status) async {
    setState(() {
      _error = null;
      _success = null;
    });

    try {
      //Getting the PATCH endpoint to get the friendships from backend
      final uri = Uri.parse("$_baseUrl/friendships/$friendshipId");

      final resp = await http.patch(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": status}), // accepted / rejected
      );

      if (resp.statusCode != 200) {
        throw Exception("Respond failed (${resp.statusCode}): ${resp.body}");
      }

      setState(() => _success = "Request $status");
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      //refresh both of the lists so that:
      // accepted requests moves into friends
      // rejected requests disapears altogether
      await _refreshAll();
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //adding in the custom nav bar jessica made
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18),

        //listView makes the page scrollable if the content gets too long!
        child: ListView(
          children: [

            // ---------------- Add Friend Section ----------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add a friend (enter Spotify User ID)"),
                  const SizedBox(height: 10),

                  //the text field where the user enters another user's spotifyID
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: "@spotify_user_id",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  //the send button to submit request
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sending ? null : _sendFriendRequest,
                      child: _sending
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("Send Friend Request"),
                    ),
                  ),

                  //show error message if one exists...
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],

                  //show success message if one exists...
                  if (_success != null) ...[
                    const SizedBox(height: 8),
                    Text(_success!, style: const TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------------- Pending Requests Section ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Pending requests",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                
                //manual refresh button for pending requests
                IconButton(
                  onPressed: _fetchPending,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),

            //if still loading, show the spinner
            if (_loadingPending)
              const Center(child: CircularProgressIndicator())
            //else if no pending requests, show "no requests"
            else if (_pending.isEmpty)
              const Text("No pending requests.")

            //otherwise, build one card per pending request!
            else
              ..._pending.map((p) {
                final req = p as Map<String, dynamic>;
                //userId appears to bethe sender of the friend request
                final fromUser = req["userId"] as Map<String, dynamic>?;
                
                //the friendship record id
                final id = req["_id"].toString();

                //prefer the spotify_user_id, otherwise can use the username
                final handle = (fromUser?["spotify_user_id"] ??
                        fromUser?["username"] ??
                        "")
                    .toString();

                final name = (fromUser?["name"] ?? "").toString();

                //the card to be displayed for each request
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),

                    //show real name if available, otherwise the handle
                    title: Text(name.isNotEmpty ? name : handle),
                    //show the username under the title if available
                    subtitle:
                        handle.isNotEmpty ? Text("@$handle") : null,
                    
                    //buttons to accept/reject the request
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        TextButton( //reject button
                          onPressed: () =>
                              _respondToRequest(id, "rejected"),
                          child: const Text("Decline"),
                        ),
                        ElevatedButton( //accept button
                          onPressed: () =>
                              _respondToRequest(id, "accepted"),
                          child: const Text("Accept"),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 24),

            // ---------------- Friends Section ----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Your friends",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                
                //manual refresh button for friends list
                IconButton(
                  onPressed: _fetchFriends,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),

            if (_loadingFriends)
              const Center(child: CircularProgressIndicator())
            else if (_friends.isEmpty)
              const Text("No friends yet.")
            else
              ..._friends.map((f) {
                //get the OTHER person in the friendship using the helper function!
                final other = _otherUserFromFriendship(f);
                final handle = (other?["spotify_user_id"] ??
                        other?["username"] ??
                        "")
                    .toString();
                final name = (other?["name"] ?? "").toString();

                return ListTile( //return/show a list of the 
                  leading: const Icon(Icons.person),
                  title: Text(name.isNotEmpty ? name : handle),
                  subtitle:
                      handle.isNotEmpty ? Text("@$handle") : null,
                );
              }),
          ],
        ),
      ),
    );
  }
}