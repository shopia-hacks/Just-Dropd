// models/Countdown.js
import mongoose from "mongoose";

const countdownSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  spotify_album_id: {
    type: String,
    required: true
  },
  // true = this is the user's pinned/main profile countdown (only one allowed per user)
  is_main: {
    type: Boolean,
    default: false
  },
  // clock style the user picked, e.g. "digital_red", "analog_pink"
  clock_style: {
    type: String,
    default: "digital_default"
  }
}, {
  timestamps: true
});

// a user can only have one countdown per album
countdownSchema.index({ userId: 1, spotify_album_id: 1 }, { unique: true });

export default mongoose.model("Countdown", countdownSchema);

