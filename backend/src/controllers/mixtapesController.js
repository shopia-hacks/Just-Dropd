// controllers/mixtapesController.js
import Mixtape from "../models/Mixtape.js";
import User from "../models/User.js";
import Friendship from "../models/Friendship.js";
import { createSpotifyClient, refreshAccessToken } from "../services/spotifyService.js";

// create & send a mixtape
export async function createMixtape(req, res) {
  try {
    const {
      title,
      creatorId,
      receiverId,
      message,
      type,
      tracks,
      cover_image_url,
      visibility
    } = req.body;

    if (!title || !creatorId || !receiverId) {
      return res.status(400).send("title, creatorId, and receiverId are required");
    }

    if (!Array.isArray(tracks) || tracks.length == 0) {
      return res.status(400).send("At least one track is required");
    }

    if (creatorId === receiverId) {
      return res.status(400).send("Cannot send a mixtape to yourself");
    }

    // optional but recommended: ensure they are accepted friends
    const friendship = await Friendship.findOne({
      status: "accepted",
      $or: [
        { userId: creatorId, friendId: receiverId },
        { userId: receiverId, friendId: creatorId }
      ]
    });

    if (!friendship) {
      return res.status(403).send("Users must be friends before sending a mixtape");
    }

    const mixtape = new Mixtape({
      title,
      creatorId,
      receiverId,
      message: message || "",
      type: (type || "cd").toLowerCase(),
      visibility: visibility || "public",
      cover_image_url: cover_image_url || "",
      status: "pending",
      tracks
    });

    await mixtape.save();

    const populated = await Mixtape.findById(mixtape._id)
      .populate("creatorId receiverId", "username name profile_photo_url");

    res.status(201).json(populated);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// pending received mixtapes for activity feed
export async function getIncomingPending(req, res) {
  try {
    const mixtapes = await Mixtape.find({
      receiverId: req.params.userId,
      status: "pending"
    })
      .sort({ createdAt: -1 })
      .populate("creatorId", "username name profile_photo_url");

    res.json(mixtapes);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// accept or reject a received mixtape
export async function respondToMixtape(req, res) {
  try {
    const { status, receiverId } = req.body;

    if (!["accepted", "rejected"].includes(status)) {
      return res.status(400).send("Status must be 'accepted' or 'rejected'");
    }

    const mixtape = await Mixtape.findById(req.params.id);
    if (!mixtape) return res.status(404).send("Mixtape not found");

    // make sure the intended receiver is the one responding
    if (receiverId && mixtape.receiverId.toString() !== receiverId) {
      return res.status(403).send("Only the receiver can respond to this mixtape");
    }

    if (status === "rejected") {
      mixtape.status = "rejected";
      await mixtape.save();
      return res.json(mixtape);
    }

    // accepted: create Spotify playlist on RECEIVER's account
    const receiver = await User.findById(mixtape.receiverId);
    if (!receiver) return res.status(404).send("Receiver user not found");

    if (!receiver.spotify_access_token || !receiver.spotify_refresh_token) {
      return res.status(400).send("Receiver has not linked Spotify");
    }

    // build Spotify client for the receiver
    let spotify = createSpotifyClient(
      receiver.spotify_access_token,
      receiver.spotify_refresh_token
    );

    const uris = mixtape.tracks
    .sort((a, b) => a.track_order - b.track_order)
    .map((t) => `spotify:track:${t.spotify_track_id}`);

    let createdPlaylist;

    try {
      createdPlaylist = await spotify.createPlaylist(mixtape.title, {
        description: mixtape.message || "Sent with JustDropd",
        public: mixtape.visibility === "public"
      });

      await spotify.addTracksToPlaylist(createdPlaylist.body.id, uris);
    } catch (err) {
      const code = err?.statusCode || err?.body?.error?.status;

      if (code === 401) {
        const {
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        } = await refreshAccessToken(receiver.spotify_refresh_token);

        receiver.spotify_access_token = newAccessToken;
        if (newRefreshToken) {
          receiver.spotify_refresh_token = newRefreshToken;
        }
        await receiver.save();

        spotify = createSpotifyClient(
          newAccessToken,
          receiver.spotify_refresh_token
        );

        createdPlaylist = await spotify.createPlaylist(mixtape.title, {
          description: mixtape.message || "Sent with JustDropd",
          public: mixtape.visibility === "public"
        });

        await spotify.addTracksToPlaylist(createdPlaylist.body.id, uris);
      } else {
        throw err;
      }
    }

    mixtape.status = "accepted";
    mixtape.spotify_playlist_id = createdPlaylist.body.id || "";
    mixtape.spotify_playlist_url =
      createdPlaylist.body.external_urls?.spotify || "";

    await mixtape.save();

    const updated = await Mixtape.findById(mixtape._id)
      .populate("creatorId receiverId", "username name profile_photo_url");

    res.json(updated);
  } catch (err) {
    console.error(err);
    res.status(400).send(err.message);
  }
}

export async function getShelf(req, res) {
  try {
    const { sort } = req.query;
    let sortOption = { createdAt: -1 };
    if (sort === "title") sortOption = { title: 1 };
    if (sort === "sender") sortOption = { creatorId: 1 };

    const mixtapes = await Mixtape.find({
      receiverId: req.params.userId,
      status: "accepted"
    })
      .sort(sortOption)
      .populate("creatorId", "username name profile_photo_url");

    res.json(mixtapes);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

export async function getSent(req, res) {
  try {
    const mixtapes = await Mixtape.find({ creatorId: req.params.userId })
      .sort({ createdAt: -1 })
      .populate("receiverId", "username name profile_photo_url");

    res.json(mixtapes);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

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