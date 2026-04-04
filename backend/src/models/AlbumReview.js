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
  album_name: {
    type: String,
    default: ""
  },
  artist_name: {
    type: String,
    default: ""
  },
  spotify_album_image_url: {
    type: String,
    default: ""
  },
  rating: {
    type: Number,
    required: true,
    min: 0,
    max: 5
  },
  review_text: {
    type: String,
    default: ""
  },
  custom_image_url: {
    type: String,
    default: ""
  }
}, {
  timestamps: true,
  toJSON: {
    transform(doc, ret) {
      if (ret.rating != null) ret.rating = parseFloat(ret.rating.toString());
      return ret;
    }
  }
});

export default mongoose.model("AlbumReview", albumReviewSchema);