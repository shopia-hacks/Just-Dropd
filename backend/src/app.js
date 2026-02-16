import "dotenv/config"; //loads .env variables
import express from "express";
import cors from "cors"; //CORS allows flutter app (running on a different port) to talk to the backend
import SpotifyWebApi from 'spotify-web-api-node';

const app = express();

//init the spotify API client with credentials from kenzie's Spotify Developer Dashboard
const spotifyAPI = new SpotifyWebApi({
  clientId: process.env.SPOTIFY_CLIENT_ID,
  clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
  redirectUri: process.env.SPOTIFY_REDIRECT_URI //where spotify redirects after login
});

app.use(cors());
app.use(express.json());

//simple endpoint to makesure backend is running
app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

//------------ LOGIN ROUTE ------------
app.get('/login', (req, res) => {

  //permissions the app is requesting from the user
  //these determine what Spotify data you can access
  const scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private'
  ];

  //generates authorization URL, state123 is a placeholder to prevent CSRF attacks?
  const authorizeURL = spotifyAPI.createAuthorizeURL(scopes, 'state123');
  
  //redirects user to Spotify's login screen
  res.redirect(authorizeURL);
});

//-------- CALL BACK ROUTE -------------
app.get("/auth/callback", async (req, res) => {
  res.set("Cache-Control", "no-store");

  console.log("Callback query:", req.query);

  const code = req.query.code ?? null;
  const error = req.query.error ?? null;

  if (error) return res.status(400).send(`Callback Error: ${error}`);
  if (!code) return res.status(400).send("Missing code in callback");

  // ✅ per-request spotify client
  const spotify = new SpotifyWebApi({
    clientId: process.env.SPOTIFY_CLIENT_ID,
    clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
    redirectUri: process.env.SPOTIFY_REDIRECT_URI,
  });

  try {
    const data = await spotify.authorizationCodeGrant(code);
    const accessToken = data.body.access_token;
    const refreshToken = data.body.refresh_token;

    console.log("Grant OK. accessToken length:", accessToken?.length);

    spotify.setAccessToken(accessToken);
    spotify.setRefreshToken(refreshToken);

    // ✅ call getMe on THIS instance
    const user = await spotify.getMe();
    console.log("getMe OK:", user.body.display_name, user.body.id);

    return res.redirect(process.env.FLUTTER_REDIRECT_URL);
  } catch (err) {
    console.error("Callback FAILED");
    console.error("  status:", err?.statusCode);
    console.error("  message:", err?.message);
    console.error("  body:", err?.body);

    const details =
      err?.body?.error_description ||
      err?.body?.error?.message ||
      err?.message ||
      "Unknown error";

    return res.status(500).send(`Callback failed: ${details}`);
  }
});



export default app;
