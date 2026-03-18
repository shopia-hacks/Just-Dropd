import User from "../models/User.js"
import { createSpotifyClient} from "../services/spotifyService.js";


export async function getMe(req, res) {
 try {
   const authHeader = req.headers.authorization;
   if (!authHeader || !authHeader.startsWith("Bearer ")) {
     return res.status(401).send("Missing access token");
   }
   const accessToken = authHeader.replace("Bearer ", "");


   const spotify = createSpotifyClient(accessToken);
   const me = await spotify.getMe();


   res.json(me.body);
 } catch (err) {
   console.error(err);
   res.status(401).send("Not authenticated");
 }
}


// GET /api/spotify/search?userId=...&q=...
export async function searchTracks(req, res) {
 try {
   const userId = req.query.userId;
   const q = (req.query.q || "").trim();
   const limit = Math.min(parseInt(req.query.limit || "10", 10), 20);


   if (!userId) return res.status(400).send("Missing userId");
   if (!q) return res.json({ tracks: [] });


   const user = await User.findById(userId);
   if (!user) return res.status(404).send("User not found");
   if (!user.spotify_access_token || !user.spotify_refresh_token) {
     return res.status(401).send("User not linked to Spotify");
   }


   // Create spotify client with current tokens
   let spotify = createSpotifyClient(user.spotify_access_token, user.spotify_refresh_token);


   // Try search; if token expired, refresh and retry once
   try {
     const result = await spotify.searchTracks(q, { limit }); //spotify search API functionality


     const tracks = (result.body.tracks?.items || []).map((t) => ({
       spotify_track_id: t.id,
       name: t.name,
       artist: (t.artists || []).map((a) => a.name).join(", "),
       album: t.album?.name || "",
       imageUrl: t.album?.images?.[0]?.url || null,
       uri: t.uri,
     }));


     return res.json({ tracks });
   } catch (err) {
     const status = err?.statusCode || err?.body?.error?.status;


     // Spotify returns 401 when the access token is expired/invalid
     if (status === 401) {
       const { accessToken: newAccessToken } = await refreshAccessToken(user.spotify_refresh_token);


       user.spotify_access_token = newAccessToken;
       await user.save();


       spotify = createSpotifyClient(newAccessToken, user.spotify_refresh_token);


       const result2 = await spotify.searchTracks(q, { limit });


       const tracks2 = (result2.body.tracks?.items || []).map((t) => ({
         spotify_track_id: t.id,
         name: t.name,
         artist: (t.artists || []).map((a) => a.name).join(", "),
         album: t.album?.name || "",
         imageUrl: t.album?.images?.[0]?.url || null,
         uri: t.uri,
       }));


       return res.json({ tracks: tracks2 });
     }


     console.error("Spotify search error:", err?.body || err);
     return res.status(500).send("Spotify search failed");
   }
 } catch (err) {
   console.error(err);
   res.status(500).send("Server error");
 }
}


// GET /api/spotify/search-albums?userId=...&q=...
export async function searchAlbums(req, res) {
 try {
   // Extract query parameters
   const userId = req.query.userId;
   const q = (req.query.q || "").trim();
   const limit = Math.min(parseInt(req.query.limit || "10", 10), 20);


   // Validate required inputs
   if (!userId) return res.status(400).send("Missing userId");
   if (!q) return res.json({ albums: [] });


   // Find user in database
   const user = await User.findById(userId);
   if (!user) return res.status(404).send("User not found");


   // Ensure user has connected Spotify account
   if (!user.spotify_access_token || !user.spotify_refresh_token) {
     return res.status(401).send("User not linked to Spotify");
   }


   // Create Spotify client with stored tokens
   let spotify = createSpotifyClient(
     user.spotify_access_token,
     user.spotify_refresh_token
   );


   try {
     // Perform search for albums only
     // Spotify returns albums, EPs, and singles under this type
     const result = await spotify.search(q, ["album"], { limit });


     // Process and format album results
     const albums = (result.body.albums?.items || [])
       // Exclude singles so only albums and EPs remain
       .filter((a) => a.album_type !== "single")
       .map((a) => ({
         spotify_album_id: a.id,
         name: a.name,
         artist: (a.artists || []).map((ar) => ar.name).join(", "),
         album_type: a.album_type,
         release_date: a.release_date,
         total_tracks: a.total_tracks,
         imageUrl: a.images?.[0]?.url || null,
         uri: a.uri,
       }));


     // Return formatted response
     return res.json({ albums });
   } catch (err) {
     // Handle expired or invalid access token
     const status = err?.statusCode || err?.body?.error?.status;


     if (status === 401) {
       // Refresh access token using stored refresh token
       const { accessToken: newAccessToken } = await refreshAccessToken(
         user.spotify_refresh_token
       );


       // Save new access token to database
       user.spotify_access_token = newAccessToken;
       await user.save();


       // Recreate Spotify client with new token
       spotify = createSpotifyClient(
         newAccessToken,
         user.spotify_refresh_token
       );


       // Retry album search with refreshed token
       const result2 = await spotify.search(q, ["album"], { limit });


       const albums2 = (result2.body.albums?.items || [])
         .filter((a) => a.album_type !== "single")
         .map((a) => ({
           spotify_album_id: a.id,
           name: a.name,
           artist: (a.artists || []).map((ar) => ar.name).join(", "),
           album_type: a.album_type,
           release_date: a.release_date,
           total_tracks: a.total_tracks,
           imageUrl: a.images?.[0]?.url || null,
           uri: a.uri,
         }));


       return res.json({ albums: albums2 });
     }


     // Log and return generic error for other failures
     console.error("Spotify album search error:", err?.body || err);
     return res.status(500).send("Spotify album search failed");
   }
 } catch (err) {
   // Catch any unexpected server errors
   console.error(err);
   res.status(500).send("Server error");
 }
}

// GET /api/spotify/search?userId=...&q=...
export async function searchTracks(req, res) {
  try {
    const userId = req.query.userId;
    const q = (req.query.q || "").trim();
    const limit = Math.min(parseInt(req.query.limit || "10", 10), 20);

    if (!userId) return res.status(400).send("Missing userId");
    if (!q) return res.json({ tracks: [] });

    const user = await User.findById(userId);
    if (!user) return res.status(404).send("User not found");
    if (!user.spotify_access_token || !user.spotify_refresh_token) {
      return res.status(401).send("User not linked to Spotify");
    }

    // Create spotify client with current tokens
    let spotify = createSpotifyClient(user.spotify_access_token, user.spotify_refresh_token);

    // Try search; if token expired, refresh and retry once
    try {
      const result = await spotify.searchTracks(q, { limit }); //spotify search API functionality 

      const tracks = (result.body.tracks?.items || []).map((t) => ({
        spotify_track_id: t.id, 
        name: t.name,
        artist: (t.artists || []).map((a) => a.name).join(", "),
        album: t.album?.name || "",
        imageUrl: t.album?.images?.[0]?.url || null,
        uri: t.uri,
      }));

      return res.json({ tracks });
    } catch (err) {
      const status = err?.statusCode || err?.body?.error?.status;

      // Spotify returns 401 when the access token is expired/invalid
      if (status === 401) {
        const { accessToken: newAccessToken } = await refreshAccessToken(user.spotify_refresh_token);

        user.spotify_access_token = newAccessToken;
        await user.save();

        spotify = createSpotifyClient(newAccessToken, user.spotify_refresh_token);

        const result2 = await spotify.searchTracks(q, { limit });

        const tracks2 = (result2.body.tracks?.items || []).map((t) => ({
          spotify_track_id: t.id,
          name: t.name,
          artist: (t.artists || []).map((a) => a.name).join(", "),
          album: t.album?.name || "",
          imageUrl: t.album?.images?.[0]?.url || null,
          uri: t.uri,
        }));

        return res.json({ tracks: tracks2 });
      }

      console.error("Spotify search error:", err?.body || err);
      return res.status(500).send("Spotify search failed");
    }
  } catch (err) {
    console.error(err);
    res.status(500).send("Server error");
  }
}
