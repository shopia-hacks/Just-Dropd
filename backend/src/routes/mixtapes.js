import express from "express";
import { upload } from "../config/multer.js";
import {
  createMixtape,
  respondToMixtape,
  getShelf,
  getSent,
  getMixtapeById,
  getIncomingPending,
} from "../controllers/mixtapesController.js";

const router = express.Router();

router.post("/", upload.single("coverImage"), createMixtape);   // POST /mixtapes
router.patch("/:id/respond", respondToMixtape);                 // PATCH /mixtapes/:id/respond
router.get("/shelf/:userId", getShelf);                         // GET /mixtapes/shelf/:userId
router.get("/sent/:userId", getSent);                           // GET /mixtapes/sent/:userId
router.get("/user/:userId/incoming", getIncomingPending);       // GET /mixtapes/user/:userId/incoming
router.get("/:id", getMixtapeById);                             // GET /mixtapes/:id

export default router;