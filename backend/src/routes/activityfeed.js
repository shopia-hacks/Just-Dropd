import express from "express";
import { getActivityFeed } from "../controllers/activityFeedController.js";

const router = express.Router();

router.get("/:userId", getActivityFeed);

export default router;