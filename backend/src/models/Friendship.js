// models/Friendship.js
import mongoose from "mongoose";

const friendshipSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  friendId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  status: {
    type: String,
    enum: ["pending", "accepted", "rejected"],
    default: "pending",
    required: true
  }
}, {
  timestamps: true
});

// prevent duplicate friendship pairs
friendshipSchema.index({ userId: 1, friendId: 1 }, { unique: true });

export default mongoose.model("Friendship", friendshipSchema);

