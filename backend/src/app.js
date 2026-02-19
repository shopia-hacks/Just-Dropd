import "dotenv/config";
import express from "express";
import cors from "cors";

import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/users.js";
import spotifyRoutes from "./routes/spotify.js";

const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => res.json({ status: "ok" }));

app.use("/", authRoutes);
app.use("/users", userRoutes);
app.use("/spotify", spotifyRoutes);

export default app;
