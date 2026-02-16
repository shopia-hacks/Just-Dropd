// models/User.js
import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    lowercase: true
  },
  name: String,
  bio: String,
  profile_photo_url: String,

  // spotify specific fields
  spotify_user_id: {
    type: String,
    required: true,
    unique: true  // each Spotify account = one JustDropd account
  },
  spotify_access_token: String,
  spotify_refresh_token: String

}, {
  timestamps: true
});

export default mongoose.model("User", userSchema);