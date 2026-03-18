import mongoose from "mongoose";
import AlbumReview from "../models/AlbumReview.js";

export const createAlbumReview = async (req, res) => {
  try {
    const { userId, spotify_album_id, rating, review_text, custom_image_url } = req.body;

    // --- Extra debug: log the payload exactly as MongoDB sees it ---
    const payload = {
      userId,
      spotify_album_id,
      rating: rating, // we'll convert below
      review_text: review_text || "",
      custom_image_url: custom_image_url || null
    };
    console.log("Payload being inserted into MongoDB:", payload);

    // Convert rating to Decimal128 for MongoDB
    payload.rating = mongoose.Types.Decimal128.fromString(rating.toString());

    // Attempt to insert document
    const review = await AlbumReview.create(payload);

    res.status(201).json(review);
  } catch (err) {
    // --- Log full MongoServerError object ---
    console.error("MongoServerError full object:", err);

    // If JSON schema validation failed, show which fields
    if (err.errInfo?.details?.schemaRulesNotSatisfied) {
      console.error("Fields failing MongoDB JSON schema validation:");
      err.errInfo.details.schemaRulesNotSatisfied.forEach((rule, i) => {
        console.error(`Rule ${i}:`, JSON.stringify(rule, null, 2));
      });
    }

    // If Mongoose field-level validation errors exist, show them
    if (err.errors) {
      for (const [field, errorObj] of Object.entries(err.errors)) {
        console.error(`Field "${field}" failed Mongoose validation: ${errorObj.message}`);
      }
    }

    // Return detailed error info to Flutter
    res.status(400).json({
      message: err.message,
      mongoDetails: err.errInfo?.details,
      mongooseErrors: err.errors
    });
  }
};

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

