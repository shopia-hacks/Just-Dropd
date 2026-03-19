// routes/countdowns.js
import express from "express";
import {
  createCountdown,
  updateCountdownDetails,
  getCountdownsByUser,
  getMainCountdown,
  getFriendsCountdowns,
  setMainCountdown,
  updateClockStyle,
  deleteCountdown,
  searchArtists,
} from "../controllers/countdownsController.js";

const router = express.Router();

// search must come before /:id routes to avoid param conflicts
router.get("/search-artist", searchArtists);               // GET  /countdowns/search-artist?q=&userId=

router.post("/", createCountdown);                         // POST /countdowns
router.post("/friends", getFriendsCountdowns);             // POST /countdowns/friends
router.get("/user/:userId", getCountdownsByUser);          // GET  /countdowns/user/:userId
router.get("/user/:userId/main", getMainCountdown);        // GET  /countdowns/user/:userId/main
router.patch("/:id/details", updateCountdownDetails);      // PATCH /countdowns/:id/details
router.patch("/:id/set-main", setMainCountdown);           // PATCH /countdowns/:id/set-main
router.patch("/:id/update-clock-style", updateClockStyle); // PATCH /countdowns/:id/update-clock-style
router.delete("/:id", deleteCountdown);                    // DELETE /countdowns/:id

export default router;