import AlbumReview from "../models/AlbumReview.js";

export const createAlbumReview = async (req, res) => {
  try {
    const {
      userId,
      spotify_album_id,
      album_name,
      artist_name,
      spotify_album_image_url,
      rating,
      review_text,
      custom_image_url
    } = req.body;

    const payload = {
      userId,
      spotify_album_id,
      album_name: album_name || "",
      artist_name: artist_name || "",
      spotify_album_image_url: spotify_album_image_url || "",
      rating: Number(rating),
      review_text: review_text || "",
      custom_image_url: custom_image_url || ""
    };

    console.log("Payload being inserted into MongoDB:", payload);

    const review = await AlbumReview.create(payload);

    res.status(201).json(review);
  } catch (err) {
    console.error("MongoServerError full object:", err);

    if (err.errInfo?.details?.schemaRulesNotSatisfied) {
      console.error("Fields failing MongoDB JSON schema validation:");
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

