// app.js
import "dotenv/config"; //loads .env variables
import express from "express";
import cors from "cors"; //CORS allows flutter app (running on a different port) to talk to the backend
import SpotifyWebApi from 'spotify-web-api-node';
import User from "./models/User.js";

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

//------------ LOGIN ROUTE ------------ redirects to spotify
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

//-------- CALL BACK ROUTE ------------- spotify sends user back here after login
app.get("/auth/callback", async (req, res) => {
  //store the parameters Spotify sends back
  console.log("Callback query:", req.query);

  const code = req.query.code ?? null;
  const error = req.query.error ?? null;

  if (error) return res.status(400).send(`Callback Error: ${error}`);
  if (!code) return res.status(400).send("Missing code in callback");

  // FIXED: per-request spotify client
  const spotify = new SpotifyWebApi({
    clientId: process.env.SPOTIFY_CLIENT_ID,
    clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
    redirectUri: process.env.SPOTIFY_REDIRECT_URI,
  });

  try {
    const data = await spotify.authorizationCodeGrant(code);
    const accessToken = data.body.access_token;
    const refreshToken = data.body.refresh_token;
    const expiresIn = data.body.expires_in;

    console.log("Grant OK. accessToken length:", accessToken?.length);

    // set tokens on per-request client, not global one
    spotify.setAccessToken(accessToken);
    spotify.setRefreshToken(refreshToken);

    //GETTING USER INFO FROM SPOTIFY API
    // use spotify per-request, not spotify API to get user info
    const spotifyUser = await spotify.getMe(); //getting user object
    // added
    const spotifyId = spotifyUser.body.id;
    const spotifyName = spotifyUser.body.display_name;
    const spotifyEmail = spotifyUser.body.email;
    console.log("Spotify user logged in:");
    //console.log("   display_name:", user.body.display_name); //displaying user info from spotify
    //console.log("   user_id:", user.body.id);
    console.log("   display_name:", spotifyName);
    console.log("   spotify_id:", spotifyId);
    console.log("   email:", spotifyEmail);

    // check if user already exists in MongoDB
    let user = await User.findOne({ spotify_user_id: spotifyId });

    if (!user) {
      // new user -> create JustDropd account automatically
      console.log("New user! Creating account in MongoDB...");

      user = new User({
        username: spotifyId,    // use spotify_id as default username for now
        email: spotifyEmail,
        name: spotifyName,
        spotify_user_id: spotifyId,
        spotify_access_token: accessToken,
        spotify_refresh_token: refreshToken
      });
      
      await user.save();
      console.log("New user saved to MongoDB!");
    } else {
      // existing user -> update their tokens
      console.log("Existing user found! Updating tokens...");

      user.spotify_access_token = accessToken;
      user.spotify_refresh_token = refreshToken;
      await user.save();
      console.log("Tokens updated in MongoDB!");
    }

    // send user back to Flutter with info
    const redirectUrl = `${process.env.FLUTTER_REDIRECT_URL}?userId=${user._id}&name=${encodeURIComponent(spotifyName)}&isNew=${!user.createdAt}`;
    //res.redirect(process.env.FLUTTER_REDIRECT_URL);
    res.redirect(redirectUrl);

    //automatically refresh the access token before it expires
    setInterval(async () => {
      const refreshed = await spotify.refreshAccessToken();
      spotify.setAccessToken(refreshed.body.access_token);
      console.log("Refreshed access token");
    }, (expiresIn / 2) * 1000);

  } catch (err) {
    console.error("Callback FAILED");
    console.error("  status:", err?.statusCode);
    console.error("  message:", err?.message);
    console.error("  body:", err?.body);

    console.error("  validation errors:", JSON.stringify(err?.errors, null, 2));

    const details =
      err?.body?.error_description ||
      err?.body?.error?.message ||
      err?.message ||
      "Unknown error";

    return res.status(500).send(`Callback failed: ${details}`);
  }
});

export default app;
