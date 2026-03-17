import express from "express";
import { getMe } from "../controllers/spotifyController.js";
import { searchTracks } from "../controllers/spotifyController.js";

const router = express.Router();

router.get("/me", getMe);
router.get("/search", searchTracks);
router.get("/search-albums", searchAlbums)

export default router;

