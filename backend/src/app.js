import express from "express";
import cors from "cors";
import SpotifyWebApi from 'spotify-web-api-node';

const app = express();

const spotifyApi = new SpotifyWebApi({
  clientId: process.env.SPOTIFY_CLIENT_ID || 'e87aeecef35e49c7974ae1843c2788e9',
  clientSecret: process.env.SPOTIFY_CLIENT_SECRET || 'a1a030f530ac460080dabd00137fb457',
  redirectUri: 'http://127.0.0.1:3000/auth/callback'
});

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get('/login', (req, res) => { //getting login page, redirecting user to spotify login
  const scopes = [
    'user-read-private',
    'user-read-email',
    'playlist-read-private'
  ];
  const authorizeURL = spotifyApi.createAuthorizeURL(scopes, 'state123');
  res.redirect(authorizeURL);
});

app.get("/auth/callback", async (req, res) => {
  console.log("Callback query:", req.query);

  const code = req.query.code ?? null;
  const error = req.query.error ?? null;

  if (error) {
    return res.status(400).send(`Callback Error: ${error}`);
  }

  if (!code) {
    return res.status(400).send("Missing code in callback (did you open this URL directly?)");
  }

  try {
    const data = await spotifyApi.authorizationCodeGrant(code);

    const accessToken = data.body.access_token;
    const refreshToken = data.body.refresh_token;
    const expiresIn = data.body.expires_in;

    spotifyApi.setAccessToken(accessToken);
    spotifyApi.setRefreshToken(refreshToken);

    res.send("Login successful! ✅");

    setInterval(async () => {
      const refreshed = await spotifyApi.refreshAccessToken();
      spotifyApi.setAccessToken(refreshed.body.access_token);
      console.log("Refreshed access token");
    }, (expiresIn / 2) * 1000);
  } catch (err) {
    console.error("Token exchange failed:", err);
    res.status(500).send(`Token exchange failed: ${err}`);
  }
});


export default app;
