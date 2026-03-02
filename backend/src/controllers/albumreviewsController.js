// controllers/albumReviewsController.js
import AlbumReview from "../models/AlbumReview.js";

// create a new album review
export async function createAlbumReview(req, res) {
  try {
    const review = new AlbumReview(req.body);
    await review.save();
    res.status(201).json(review);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// get all album reviews for a user (for their profile)
export async function getReviewsByUser(req, res) {
  try {
    const reviews = await AlbumReview.find({ userId: req.params.userId })
      .sort({ createdAt: -1 });
    res.json(reviews);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// get a single review
export async function getAlbumReviewById(req, res) {
  try {
    const review = await AlbumReview.findById(req.params.id)
      .populate("userId", "username name");
    if (!review) return res.status(404).send("Review not found");
    res.json(review);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// delete a review
export async function deleteAlbumReview(req, res) {
  try {
    const review = await AlbumReview.findByIdAndDelete(req.params.id);
    if (!review) return res.status(404).send("Review not found");
    res.json({ message: "Review deleted" });
  } catch (err) {
    res.status(500).send(err.message);
  }
}

