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
    type: Number, // change from Decimal128 → Number
    required: true,
    min: 0,
    max: 5
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

