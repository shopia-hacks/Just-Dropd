import express from "express";
import { getUserById, createUser } from "../controllers/usersController.js";

const router = express.Router();

router.get("/:id", getUserById);
router.post("/", createUser);

export default router;