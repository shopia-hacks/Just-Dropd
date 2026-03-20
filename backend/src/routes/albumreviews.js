import express from "express";
import {
  createAlbumReview,
  getReviewsByUser,
  getAlbumReviewById,
  deleteAlbumReview
} from "../controllers/albumreviewsController.js";

const router = express.Router();

router.post("/", createAlbumReview);                 // POST /album-reviews
router.get("/user/:userId", getReviewsByUser);       // GET /album-reviews/user/:userId
router.get("/:id", getAlbumReviewById);              // GET  /album-reviews/:id
router.delete("/:id", deleteAlbumReview);

export default router;