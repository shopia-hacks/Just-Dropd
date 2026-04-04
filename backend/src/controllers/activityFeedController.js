import mongoose from "mongoose";
import Friendship from "../models/Friendship.js";
import ConcertReview from "../models/ConcertReview.js";
import AlbumReview from "../models/AlbumReview.js";
import Mixtape from "../models/Mixtape.js";

export async function getActivityFeed(req, res) {
  try {
    const userId = req.params.userId;

    if (!mongoose.Types.ObjectId.isValid(userId)) {
      return res.status(400).send("Invalid userId");
    }

    const userObjectId = new mongoose.Types.ObjectId(userId);

    // ---------------------------------------------------
    // 1) Find accepted friends
    // ---------------------------------------------------
    const acceptedFriendships = await Friendship.find({
      $or: [{ userId: userId }, { friendId: userId }],
      status: "accepted",
    });

    const friendIds = acceptedFriendships.map((friendship) => {
      return friendship.userId.toString() === userId
        ? friendship.friendId
        : friendship.userId;
    });

    const visibleUserIds = [userObjectId, ...friendIds];

    // ---------------------------------------------------
    // 2) Get incoming pending mixtapes for this user
    // ---------------------------------------------------
    const pendingMixtapes = await Mixtape.find({
      receiverId: userObjectId,
      status: "pending",
    })
      .populate("creatorId", "username name profile_photo_url")
      .sort({ createdAt: -1 });

    const mixtapeFeedItems = pendingMixtapes.map((mixtape) => ({
      type: "pending_mixtape",
      createdAt: mixtape.createdAt,
      data: {
        _id: mixtape._id,
        title: mixtape.title,
        message: mixtape.message ?? "",
        status: mixtape.status,
        creatorId: mixtape.creatorId,
        cover_image_url: mixtape.cover_image_url ?? "",
      },
    }));

    // ---------------------------------------------------
    // 3) Get concert reviews by user + accepted friends
    // ---------------------------------------------------
    const concertReviews = await ConcertReview.find({
      userId: { $in: visibleUserIds },
    })
      .populate("userId", "username name profile_photo_url")
      .sort({ createdAt: -1 });

    const concertFeedItems = concertReviews.map((review) => ({
      type: "concert_review",
      createdAt: review.createdAt,
      data: {
        _id: review._id,
        userId: review.userId,
        title: review.title,
        artist_name: review.artist_name,
        date: review.date,
        location: review.location,
        rating: review.rating,
        review_text: review.review_text,
        image_urls: review.image_urls ?? [],
      },
    }));

    // ---------------------------------------------------
    // 4) Get album reviews by user + accepted friends
    // ---------------------------------------------------
    const albumReviews = await AlbumReview.find({
      userId: { $in: visibleUserIds },
    })
      .populate("userId", "username name profile_photo_url")
      .sort({ createdAt: -1 });

    const albumFeedItems = albumReviews.map((review) => ({
        type: "album_review",
        createdAt: review.createdAt,
        data: {
            _id: review._id,
            userId: review.userId,
            spotify_album_id: review.spotify_album_id,
            album_name: review.album_name ?? "",
            artist_name: review.artist_name ?? "",
            spotify_album_image_url: review.spotify_album_image_url ?? "",
            rating: review.rating,
            review_text: review.review_text ?? "",
            custom_image_url: review.custom_image_url ?? "",
        },
    }));

    // ---------------------------------------------------
    // 5) Merge + sort newest first
    // ---------------------------------------------------
    const mergedFeed = [
      ...mixtapeFeedItems,
      ...concertFeedItems,
      ...albumFeedItems,
    ].sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));

    res.json(mergedFeed);
  } catch (err) {
    console.error("Error loading activity feed:", err);
    res.status(500).send(err.message);
  }
}