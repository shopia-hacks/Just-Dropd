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
import activityFeedRoutes from "./routes/activityfeed.js";


const app = express();
const cors = require('cors');

app.use(cors({
    origin: [
        'https://justdropd.com',
        'https://www.justdropd.com',
        'http://localhost:5500',
        'http://localhost:3000'
    ],
    credentials: true
}));
app.use(express.json());
app.use("/spotify", spotifyRoutes);
app.use("/api/spotify", spotifyRoutes);
app.use("/api/album-reviews", albumReviewRoutes);       // ✅ match the import
app.use("/album-reviews", albumReviewRoutes);     

app.get("/health", (req, res) => res.json({ status: "ok" }));

app.use("/", authRoutes);
app.use("/users", userRoutes);

// new routes
app.use("/friendships", friendshipRoutes);
app.use("/mixtapes", mixtapeRoutes);
app.use("/album-reviews", albumReviewRoutes);
app.use("/concert-reviews", concertReviewRoutes);
app.use('/uploads', express.static('uploads'));
app.use("/countdowns", countdownRoutes);
app.use("/activity-feed", activityFeedRoutes);

export default app;
