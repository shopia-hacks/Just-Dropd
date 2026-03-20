// controllers/concertReviewsController.js
import ConcertReview from "../models/ConcertReview.js";
import mongoose from "mongoose";

// create a new concert review
export async function createConcertReview(req, res) {
  console.log("req.body:", req.body);
  console.log("req.files:", req.files);
  try {
    const imagePaths = req.files?.map(f => f.path) ?? [];
    
    const review = new ConcertReview({ 
      ...req.body, 
      userId: new mongoose.Types.ObjectId(req.body.userId),
      date: new Date(req.body.date),
      rating: parseFloat(req.body.rating),
      image_urls: imagePaths 
    });

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