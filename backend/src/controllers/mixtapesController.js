// controllers/mixtapesController.js
import Mixtape from "../models/Mixtape.js";

// create & send a mixtape
export async function createMixtape(req, res) {
  try {
    const mixtape = new Mixtape(req.body);
    await mixtape.save();
    res.status(201).json(mixtape);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// accept or reject a received mixtape
export async function respondToMixtape(req, res) {
  try {
    const { status } = req.body;  // "accepted" or "rejected"
    if (!["accepted", "rejected"].includes(status)) {
      return res.status(400).send("Status must be 'accepted' or 'rejected'");
    }

    const mixtape = await Mixtape.findById(req.params.id);
    if (!mixtape) return res.status(404).send("Mixtape not found");

    mixtape.status = status;
    await mixtape.save();
    res.json(mixtape);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// get a user's shelf: mixtapes received & accepted
export async function getShelf(req, res) {
  try {
    const { sort } = req.query;  // "date" | "title" | "sender"
    let sortOption = { createdAt: -1 };  // default: newest first
    if (sort === "title") sortOption = { title: 1 };
    if (sort === "sender") sortOption = { creatorId: 1 };

    const mixtapes = await Mixtape.find({
      receiverId: req.params.userId,
      status: "accepted"
    })
      .sort(sortOption)
      .populate("creatorId", "username name");
    res.json(mixtapes);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// get mixtapes a user has created
export async function getSent(req, res) {
  try {
    const mixtapes = await Mixtape.find({ creatorId: req.params.userId })
      .sort({ createdAt: -1 })
      .populate("receiverId", "username name");
    res.json(mixtapes);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// get single mixtape by ID
export async function getMixtapeById(req, res) {
  try {
    const mixtape = await Mixtape.findById(req.params.id)
      .populate("creatorId receiverId", "username name profile_photo_url");
    if (!mixtape) return res.status(404).send("Mixtape not found");
    res.json(mixtape);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// update visibility (public/private) or Spotify playlist ID
export async function updateMixtape(req, res) {
  try {
    const allowed = ["visibility", "spotify_playlist_id"];
    const updates = Object.fromEntries(
      Object.entries(req.body).filter(([k]) => allowed.includes(k))
    );
    const mixtape = await Mixtape.findByIdAndUpdate(req.params.id, updates, { new: true });
    if (!mixtape) return res.status(404).send("Mixtape not found");
    res.json(mixtape);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

