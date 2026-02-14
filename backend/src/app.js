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

  //store the parameters Spotify sends back
  console.log("Callback query:", req.query);

  const code = req.query.code ?? null; //authorization code used for access token
  const error = req.query.error ?? null; //error returned if login failed

  if (error) { //handle any spotify login errors
    return res.status(400).send(`Callback Error: ${error}`);
  }

  if (!code) {
    return res.status(400).send("Missing code in callback (did you open this URL directly?)");
  }

  try {
    //exchange the auth code for access and refresh tokens
    const data = await spotifyAPI.authorizationCodeGrant(code);

    const accessToken = data.body.access_token; //token used to access API
    const refreshToken = data.body.refresh_token; //token to refresh access token
    const expiresIn = data.body.expires_in; //token lifetime

    spotifyAPI.setAccessToken(accessToken); //store the tokens we got in the API client
    spotifyAPI.setRefreshToken(refreshToken);

    //GETTING USER INFO FROM SPOTIFY API
    const user = await spotifyAPI.getMe(); //getting user object
    console.log("Spotify user logged in:");
    console.log("   display_name:", user.body.display_name); //displaying user info from spotify
    console.log("   user_id:", user.body.id);

    res.redirect(process.env.FLUTTER_REDIRECT_URL);

    //automatically refresh the access token before it expires
    setInterval(async () => {
      const refreshed = await spotifyAPI.refreshAccessToken();
      spotifyAPI.setAccessToken(refreshed.body.access_token);
      console.log("Refreshed access token");
    }, (expiresIn / 2) * 1000);
  } catch (err) {
    //if token related errors when refreshing, shown here
    console.error("Token exchange failed:", err);
    res.status(500).send(`Token exchange failed: ${err}`);
  }
});

export default app;
