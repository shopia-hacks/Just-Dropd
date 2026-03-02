// routes/friendships.js
import express from "express";
import {
  sendRequest,
  respondToRequest,
  getFriends,
  getPendingRequests
} from "../controllers/friendshipsController.js";

const router = express.Router();

router.post("/", sendRequest);                             // POST /friendships
router.patch("/:id", respondToRequest);                   // PATCH /friendships/:id
router.get("/user/:userId", getFriends);                  // GET  /friendships/user/:userId
router.get("/user/:userId/pending", getPendingRequests);  // GET  /friendships/user/:userId/pending

export default router;

