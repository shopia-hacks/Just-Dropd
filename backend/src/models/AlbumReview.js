// models/AlbumReview.js
import mongoose from "mongoose";

const albumReviewSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  spotify_album_id: {
    type: String,
    required: true
  },
  rating: {
    // stored as Decimal128 so MongoDB receives bsonType "double", not Int32
    // without this, whole numbers like 4 or 5 fail the "double" validator
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
  // optional custom cover image; if null, the Spotify album art is used
  custom_image_url: {
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

export default mongoose.model("AlbumReview", albumReviewSchema);

