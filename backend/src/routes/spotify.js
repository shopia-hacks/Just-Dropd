import express from "express";
import { getMe, searchTracks, searchAlbums, searchArtists } from "../controllers/spotifyController.js";

const router = express.Router();

router.get("/me", getMe);
router.get("/search", searchTracks);        
router.get("/search-albums", searchAlbums);
router.get("/search-artist", searchArtists); // used by create_countdown.dart

export default router;

