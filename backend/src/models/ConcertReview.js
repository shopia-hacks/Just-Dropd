// models/ConcertReview.js
import mongoose from "mongoose";

const concertReviewSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true   // e.g. tour name or show title
  },
  artist_name: {
    type: String,
    required: true,
    trim: true
  },
  date: {
    type: Date,
    required: true
  },
  location: {
    type: String,
    required: true,
    trim: true
  },
  rating: {
    // same Decimal128 fix as AlbumReview: ensures bsonType "double" in MongoDB
    type: mongoose.Schema.Types.Double,
    required: true,
    min: 0,
    max: 5,
  },
  review_text: {
    type: String,
    default: ""
  },
  // optional user-uploaded photo (e.g. ticket stub image)
  image_urls: [{
    type: String
  }]
}, {
  timestamps: true,
});

export default mongoose.model("ConcertReview", concertReviewSchema);

