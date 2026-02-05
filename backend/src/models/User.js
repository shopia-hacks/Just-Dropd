// models/User.js
const mongoose = require('mongoose');

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
  password_hash: {
    type: String,
    required: true
  },
  name: String,
  bio: String,
  profile_photo_url: String,
  spotify_user_id: String,
  spotify_access_token: String,
  spotify_refresh_token: String
}, {
  timestamps: true  // automatically adds createdAt and updatedAt
});

module.exports = mongoose.model('User', userSchema);