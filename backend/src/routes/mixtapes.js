// routes/mixtapes.js
import express from "express";
import {
  createMixtape,
  respondToMixtape,
  getShelf,
  getSent,
  getMixtapeById,
  updateMixtape
} from "../controllers/mixtapesController.js";

const router = express.Router();

router.post("/", createMixtape);                         // POST /mixtapes
router.patch("/:id/respond", respondToMixtape);          // PATCH /mixtapes/:id/respond
router.patch("/:id", updateMixtape);                     // PATCH /mixtapes/:id
router.get("/:id", getMixtapeById);                      // GET  /mixtapes/:id
router.get("/shelf/:userId", getShelf);                  // GET  /mixtapes/shelf/:userId
router.get("/sent/:userId", getSent);                    // GET  /mixtapes/sent/:userId

export default router;

