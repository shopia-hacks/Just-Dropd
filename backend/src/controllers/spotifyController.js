import { createSpotifyClient, refreshAccessToken } from "../services/spotifyService.js";
import User from "../models/User.js";

// GET /spotify/me
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

// GET /spotify/search?userId=&q=&limit=10
export async function searchTracks(req, res) {
  try {
    const { userId, q, limit = "10" } = req.query;
    if (!userId || !q) return res.status(400).send("userId and q are required");

    let user = await User.findById(userId);
    if (!user) return res.status(404).send("User not found");

    let spotify = createSpotifyClient(
      user.spotify_access_token,
      user.spotify_refresh_token
    );

    let result;
    try {
      result = await spotify.searchTracks(q, { limit: parseInt(limit) });
    } catch (err) {
      if (err.statusCode === 401) {
        const { accessToken: newToken } = await refreshAccessToken(user.spotify_refresh_token);
        await User.findByIdAndUpdate(userId, { spotify_access_token: newToken });
        spotify = createSpotifyClient(newToken, user.spotify_refresh_token);
        result = await spotify.searchTracks(q, { limit: parseInt(limit) });
      } else {
        throw err;
      }
    }

    const tracks = (result.body.tracks?.items ?? []).map((t) => ({
      spotify_track_id: t.id,
      name:             t.name,
      artist:           t.artists?.[0]?.name ?? "Unknown",
      album:            t.album?.name ?? "",
      imageUrl:         t.album?.images?.[0]?.url ?? null,
    }));

    res.json({ tracks });
  } catch (err) {
    console.error("Spotify search error:", err.message);
    res.status(500).send(err.message);
  }
}

// GET /spotify/search-artist?userId=&q=
export async function searchArtists(req, res) {
  try {
    const { userId, q } = req.query;
    console.log("searchArtists hit — userId:", userId, "q:", q);
    if (!userId || !q) return res.status(400).send("userId and q are required");

    let user = await User.findById(userId);
    if (!user) return res.status(404).send("User not found");

    let spotify = createSpotifyClient(
      user.spotify_access_token,
      user.spotify_refresh_token
    );

    let result;
    try {
      result = await spotify.searchArtists(q, { limit: 8 });
    } catch (err) {
      if (err.statusCode === 401) {
        const { accessToken: newToken } = await refreshAccessToken(user.spotify_refresh_token);
        await User.findByIdAndUpdate(userId, { spotify_access_token: newToken });
        spotify = createSpotifyClient(newToken, user.spotify_refresh_token);
        result = await spotify.searchArtists(q, { limit: 8 });
      } else {
        throw err;
      }
    }

    const artists = (result.body.artists?.items ?? []).map((a) => ({
      spotify_artist_id: a.id,
      artist_name:       a.name,
      image_url:         a.images?.[0]?.url ?? null,
      genres:            a.genres?.slice(0, 2) ?? [],
    }));

    res.json({ artists });
  } catch (err) {
    console.error("Spotify artist search error:", err.message);
    res.status(500).send(err.message);
  }
}