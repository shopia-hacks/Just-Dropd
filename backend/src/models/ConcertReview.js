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
    type: mongoose.Schema.Types.Decimal128,
    required: true,
    validate: {
      validator: (v) => parseFloat(v) >= 0 && parseFloat(v) <= 5,
      message: "Rating must be between 0 and 5"
    }
  },
  review_text: {
    type: String,
    default: ""
  },
  // optional user-uploaded photo (e.g. ticket stub image)
  image_url: {
    type: String
  }
}, {
  timestamps: true,
  // serialize Decimal128 → plain JS number in JSON responses to Flutter
  toJSON: {
    transform(doc, ret) {
      if (ret.rating) ret.rating = parseFloat(ret.rating.toString());
      return ret;
    }
  }
});

export default mongoose.model("ConcertReview", concertReviewSchema);

