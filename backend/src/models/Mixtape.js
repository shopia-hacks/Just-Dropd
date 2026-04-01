// models/Mixtape.js
import mongoose from "mongoose";

const mixtapeTrackSchema = new mongoose.Schema({
  spotify_track_id: {
    type: String,
    required: true
  },
  track_order: {
    type: Number,
    required: true
  }
}, { _id: false });

const mixtapeSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  creatorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  receiverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  spotify_playlist_id: {
    type: String,
    default: ""
  },
  spotify_playlist_url: {
    type: String,
    default: ""
  },
  cover_image_url: {
    type: String,
    default: ""
  },
  icon_type: {
    type: String,        // e.g. "cd_1", "cassette_2" — matches icon library
    default: "cd_1"
  },
  message: {
    type: String,        // private note from sender to receiver
    default: ""
  },
  type: {
    type: String,
    enum: ["cd", "cassette", "vinyl"],
    default: "cd"
  },
  status: {
    type: String,
    enum: ["pending", "accepted", "rejected"],
    default: "pending"
  },
  visibility: {
    type: String,
    enum: ["public", "private"],
    default: "public"
  },
  tracks: [mixtapeTrackSchema]
}, {
  timestamps: true
});

export default mongoose.model("Mixtape", mixtapeSchema);

