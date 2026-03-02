// controllers/concertReviewsController.js
import ConcertReview from "../models/ConcertReview.js";

// create a new concert review
export async function createConcertReview(req, res) {
  try {
    const review = new ConcertReview(req.body);
    await review.save();
    res.status(201).json(review);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// get all concert reviews for a user (for their profile)
export async function getReviewsByUser(req, res) {
  try {
    const reviews = await ConcertReview.find({ userId: req.params.userId })
      .sort({ createdAt: -1 });
    res.json(reviews);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// get a single concert review
export async function getConcertReviewById(req, res) {
  try {
    const review = await ConcertReview.findById(req.params.id)
      .populate("userId", "username name");
    if (!review) return res.status(404).send("Review not found");
    res.json(review);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// delete a concert review
export async function deleteConcertReview(req, res) {
  try {
    const review = await ConcertReview.findByIdAndDelete(req.params.id);
    if (!review) return res.status(404).send("Review not found");
    res.json({ message: "Concert review deleted" });
  } catch (err) {
    res.status(500).send(err.message);
  }
}