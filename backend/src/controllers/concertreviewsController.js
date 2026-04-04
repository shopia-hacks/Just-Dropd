// controllers/concertReviewsController.js
import ConcertReview from "../models/ConcertReview.js";
import mongoose from "mongoose";
import { Double } from "bson";

// create a new concert review
export async function createConcertReview(req, res) {
  console.log("req.body:", req.body);
  console.log("req.files:", req.files);

  try {
    const imagePaths = req.files?.map((f) => f.path.replace(/\\/g, "/")) ?? [];

    const review = new ConcertReview({
      ...req.body,
      userId: new mongoose.Types.ObjectId(req.body.userId),
      date: new Date(req.body.date),
      rating: new Double(parseFloat(req.body.rating)),
      image_urls: imagePaths,
    });

    await review.save();
    res.status(201).json(review);
  } catch (err) {
    console.error("Concert review save error:", err);

    if (err.errInfo?.details?.schemaRulesNotSatisfied) {
      console.error("MongoDB schema validation details:");
      err.errInfo.details.schemaRulesNotSatisfied.forEach((rule, i) => {
        console.error(`Rule ${i}:`, JSON.stringify(rule, null, 2));
      });
    }

    if (err.errors) {
      for (const [field, errorObj] of Object.entries(err.errors)) {
        console.error(`Field "${field}" failed Mongoose validation: ${errorObj.message}`);
      }
    }

    res.status(400).json({
      message: err.message,
      mongoDetails: err.errInfo?.details,
      mongooseErrors: err.errors,
    });
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