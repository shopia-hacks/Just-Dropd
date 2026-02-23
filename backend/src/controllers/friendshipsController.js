// controllers/friendshipsController.js
import Friendship from "../models/Friendship.js";

// send a friend request
export async function sendRequest(req, res) {
  try {
    const { userId, friendId } = req.body;
    if (userId === friendId) return res.status(400).send("Cannot friend yourself");

    // check if a relationship already exists in either direction
    const existing = await Friendship.findOne({
      $or: [
        { userId, friendId },
        { userId: friendId, friendId: userId }
      ]
    });
    if (existing) return res.status(409).send("Friend request already exists");

    const friendship = new Friendship({ userId, friendId, status: "pending" });
    await friendship.save();
    res.status(201).json(friendship);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// accept or reject a friend request
export async function respondToRequest(req, res) {
  try {
    const { status } = req.body;  // "accepted" or "rejected"
    if (!["accepted", "rejected"].includes(status)) {
      return res.status(400).send("Status must be 'accepted' or 'rejected'");
    }

    const friendship = await Friendship.findById(req.params.id);
    if (!friendship) return res.status(404).send("Friend request not found");

    friendship.status = status;
    await friendship.save();
    res.json(friendship);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// get all accepted friends for a user
export async function getFriends(req, res) {
  try {
    const userId = req.params.userId;
    const friends = await Friendship.find({
      $or: [{ userId }, { friendId: userId }],
      status: "accepted"
    }).populate("userId friendId", "username name profile_photo_url");
    res.json(friends);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// get all pending incoming requests for a user
export async function getPendingRequests(req, res) {
  try {
    const requests = await Friendship.find({
      friendId: req.params.userId,
      status: "pending"
    }).populate("userId", "username name profile_photo_url");
    res.json(requests);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

