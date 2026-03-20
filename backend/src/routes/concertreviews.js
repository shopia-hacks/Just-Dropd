// routes/concertReviews.js
import express from "express";
import { upload } from "../config/multer.js";
import {
  createConcertReview,
  getReviewsByUser,
  getConcertReviewById,
  deleteConcertReview
} from "../controllers/concertreviewsController.js";

const router = express.Router();

router.post("/", upload.array("images", 5), createConcertReview);               // POST /concert-reviews
router.get("/user/:userId", getReviewsByUser);       // GET  /concert-reviews/user/:userId
router.get("/:id", getConcertReviewById);            // GET  /concert-reviews/:id
router.delete("/:id", deleteConcertReview);          // DELETE /concert-reviews/:id

export default router;

