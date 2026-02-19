import express from "express";
import { login, callback } from "../controllers/authController.js";

const router = express.Router();

router.get("/login", login);
router.get("/auth/callback", callback);

export default router;
