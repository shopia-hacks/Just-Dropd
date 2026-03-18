import Countdown from "../models/Countdown.js";
import Friendship from "../models/Friendship.js";
import User from "../models/User.js";
import { createSpotifyClient } from "../services/spotifyService.js";

// ─────────────────────────────────────────────────────────────────────────────
// POST /countdowns
// Required body: { userId, artist_name, release_date }
// Optional body: { album_title, cover_art_url, spotify_artist_id,
//                  spotify_album_id, is_main, clock_style }
// ─────────────────────────────────────────────────────────────────────────────
export async function createCountdown(req, res) {
  try {
    const {
      userId,
      artist_name,
      release_date,
      album_title,
      cover_art_url,
      spotify_artist_id,
      spotify_album_id,
      is_main = false,
      clock_style,
    } = req.body;

    if (!userId || !artist_name || !release_date) {
      return res.status(400).send("userId, artist_name, and release_date are required");
    }

    // Prevent duplicate countdowns for the same user + artist + date
    const existing = await Countdown.findOne({
      userId,
      artist_name: { $regex: new RegExp(`^${artist_name}$`, "i") }, // case-insensitive
      release_date: new Date(release_date),
    });
    if (existing) {
      return res.status(409).send("You already have a countdown for this artist and date");
    }

    // Demote any existing main if this is being set as main
    if (is_main) {
      await Countdown.updateMany({ userId, is_main: true }, { is_main: false });
    }

    const countdown = new Countdown({
      userId,
      artist_name,
      release_date: new Date(release_date),
      album_title:       album_title       ?? null,
      cover_art_url:     cover_art_url     ?? null,
      spotify_artist_id: spotify_artist_id ?? null,
      spotify_album_id:  spotify_album_id  ?? null,
      is_main,
      clock_style,
    });

    await countdown.save();
    res.status(201).json(countdown);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PATCH /countdowns/:id/details
// Lets a user fill in optional fields after the countdown is created:
// album_title, cover_art_url, spotify_album_id
// ─────────────────────────────────────────────────────────────────────────────
export async function updateCountdownDetails(req, res) {
  try {
    const allowed = ["album_title", "cover_art_url", "spotify_album_id", "release_date"];
    const updates = Object.fromEntries(
      Object.entries(req.body).filter(([k]) => allowed.includes(k))
    );

    if (updates.release_date) {
      updates.release_date = new Date(updates.release_date);
    }

    const countdown = await Countdown.findByIdAndUpdate(
      req.params.id,
      updates,
      { new: true }
    );
    if (!countdown) return res.status(404).send("Countdown not found");
    res.json(countdown);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /countdowns/user/:userId
// All countdowns for a user (Me tab) — sorted main first, then soonest
// ─────────────────────────────────────────────────────────────────────────────
export async function getCountdownsByUser(req, res) {
  try {
    const countdowns = await Countdown.find({ userId: req.params.userId })
      .sort({ is_main: -1, release_date: 1 });
    res.json(countdowns);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /countdowns/user/:userId/main
// The user's pinned main countdown — used on the profile page
// ─────────────────────────────────────────────────────────────────────────────
export async function getMainCountdown(req, res) {
  try {
    const countdown = await Countdown.findOne({
      userId: req.params.userId,
      is_main: true,
    });
    if (!countdown) return res.status(404).send("No main countdown set");
    res.json(countdown);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// POST /countdowns/friends
// Friends tab feed — returns user's + friends' countdowns, sorted by
// release_date ascending (soonest first)
// ─────────────────────────────────────────────────────────────────────────────
export async function getFriendsCountdowns(req, res) {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).send("userId is required");

    const user = await User.findById(userId);
    if (!user) return res.status(404).send("User not found");

    const friendships = await Friendship.find({
      $or: [{ userId }, { friendId: userId }],
      status: "accepted",
    });
    const friendIds = friendships.map((f) =>
      f.userId.toString() === userId ? f.friendId.toString() : f.userId.toString()
    );
    const userIds = [userId, ...friendIds];

    const countdowns = await Countdown.find({ userId: { $in: userIds } })
      .populate("userId", "username name profile_photo_url")
      .sort({ release_date: 1 });   // soonest first

    res.json(countdowns);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PATCH /countdowns/:id/set-main
// Body: { userId }
// Promotes a countdown to main, demotes the previous main
// ─────────────────────────────────────────────────────────────────────────────
export async function setMainCountdown(req, res) {
  try {
    const { userId } = req.body;
    if (!userId) return res.status(400).send("userId is required");

    await Countdown.updateMany({ userId, is_main: true }, { is_main: false });

    const countdown = await Countdown.findByIdAndUpdate(
      req.params.id,
      { is_main: true },
      { new: true }
    );
    if (!countdown) return res.status(404).send("Countdown not found");
    res.json(countdown);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PATCH /countdowns/:id/update-clock-style
// Body: { clock_style }
// ─────────────────────────────────────────────────────────────────────────────
export async function updateClockStyle(req, res) {
  try {
    const { clock_style } = req.body;
    if (!clock_style) return res.status(400).send("clock_style is required");

    const countdown = await Countdown.findByIdAndUpdate(
      req.params.id,
      { clock_style },
      { new: true }
    );
    if (!countdown) return res.status(404).send("Countdown not found");
    res.json(countdown);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE /countdowns/:id
// Returns was_main so Flutter knows to prompt the user to pick a new main
// ─────────────────────────────────────────────────────────────────────────────
export async function deleteCountdown(req, res) {
  try {
    const countdown = await Countdown.findByIdAndDelete(req.params.id);
    if (!countdown) return res.status(404).send("Countdown not found");
    res.json({ message: "Countdown deleted", was_main: countdown.is_main });
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET /countdowns/search-artist?q=<query>&userId=<id>
// Searches Spotify for artists to populate the artist picker on the create
// countdown page. Returns artist name, image, and Spotify ID.
// ─────────────────────────────────────────────────────────────────────────────
export async function searchArtists(req, res) {
  try {
    const { q, userId } = req.query;
    if (!q || !userId) return res.status(400).send("q and userId are required");

    const user = await User.findById(userId);
    if (!user) return res.status(404).send("User not found");

    const spotify = createSpotifyClient(
      user.spotify_access_token,
      user.spotify_refresh_token
    );
    const result = await spotify.searchArtists(q, { limit: 8 });

    const artists = result.body.artists.items.map((artist) => ({
      spotify_artist_id: artist.id,
      artist_name:       artist.name,
      image_url:         artist.images?.[0]?.url ?? null,  // used as placeholder cover art
      genres:            artist.genres?.slice(0, 2) ?? [], // first 2 genres for display
    }));

    res.json(artists);
  } catch (err) {
    res.status(500).send(err.message);
  }
}
