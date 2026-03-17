import "dotenv/config";
import express from "express";
import cors from "cors";

import authRoutes from "./routes/auth.js";
import userRoutes from "./routes/users.js";
import spotifyRoutes from "./routes/spotify.js";
import friendshipRoutes from "./routes/friendships.js";
import mixtapeRoutes from "./routes/mixtapes.js";
import albumReviewRoutes from "./routes/albumreviews.js";
import concertReviewRoutes from "./routes/concertreviews.js";
import countdownRoutes from "./routes/countdowns.js";


const app = express();

app.use(cors());
app.use(express.json());
app.use("/api/spotify", spotifyRoutes);

app.get("/health", (req, res) => res.json({ status: "ok" }));

app.use("/", authRoutes);
app.use("/users", userRoutes);
app.use("/spotify", spotifyRoutes);

// new routes
app.use("/friendships", friendshipRoutes);
app.use("/mixtapes", mixtapeRoutes);
app.use("/album-reviews", albumReviewRoutes);
app.use("/concert-reviews", concertReviewRoutes);
app.use("/countdowns", countdownRoutes);

export default app;
