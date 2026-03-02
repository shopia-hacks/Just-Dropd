// routes/countdowns.js
import express from "express";
import {
  createCountdown,
  getCountdownsByUser,
  getMainCountdown,
  setMainCountdown,
  deleteCountdown,
  getFriendsCountdowns
} from "../controllers/countdownsController.js";

const router = express.Router();

router.post("/", createCountdown);                         // POST /countdowns
router.post("/friends", getFriendsCountdowns);             // POST /countdowns/friends (pass userIds array)
router.get("/user/:userId", getCountdownsByUser);          // GET  /countdowns/user/:userId
router.get("/user/:userId/main", getMainCountdown);        // GET  /countdowns/user/:userId/main
router.patch("/:id/set-main", setMainCountdown);           // PATCH /countdowns/:id/set-main
router.delete("/:id", deleteCountdown);                    // DELETE /countdowns/:id

export default router;