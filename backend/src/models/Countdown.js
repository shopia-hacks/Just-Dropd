// models/Countdown.js
import mongoose from "mongoose";

const countdownSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },

  // ── required fields ───────────────────────────────────────────────────────
  artist_name: {
    type: String,
    required: true,
    trim: true
  },
  release_date: {
    type: Date,
    required: true
  },

  // ── optional fields (can be filled in later by the user) ─────────────────
  album_title: {
    type: String,
    trim: true,
    default: null
  },
  cover_art_url: {
    type: String,
    default: null       // Spotify artist image URL or user-provided URL
  },

  // ── spotify fields (optional, filled in if/when album appears on Spotify) ─
  spotify_artist_id: {
    type: String,
    default: null
  },
  spotify_album_id: {
    type: String,
    default: null
  },

  // ── display options ───────────────────────────────────────────────────────
  is_main: {
    type: Boolean,
    default: false      // true = pinned at top of user's profile
  },
  clock_style: {
    type: String,
    default: "digital_default"
  }
}, {
  timestamps: true
});

// Prevent a user from making duplicate countdowns for the same artist + date
countdownSchema.index({ userId: 1, artist_name: 1, release_date: 1 }, { unique: true });

export default mongoose.model("Countdown", countdownSchema);