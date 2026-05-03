import SpotifyWebApi from "spotify-web-api-node";

export function createSpotifyClient(accessToken, refreshToken) {
  const spotify = new SpotifyWebApi({
    clientId: process.env.SPOTIFY_CLIENT_ID,
    clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
    redirectUri: process.env.SPOTIFY_REDIRECT_URI,
  });

  if (accessToken) spotify.setAccessToken(accessToken);
  if (refreshToken) spotify.setRefreshToken(refreshToken);

  return spotify;
}

export function getSpotifyLoginUrl() {
  console.log("SPOTIFY_CLIENT_ID:", process.env.SPOTIFY_CLIENT_ID);
  console.log("SPOTIFY_REDIRECT_URI:", process.env.SPOTIFY_REDIRECT_URI);


  const spotify = createSpotifyClient();

  const scopes = [
    "user-read-private",
    "user-read-email",
    "playlist-read-private",
    "playlist-modify-public",
    "playlist-modify-private"
  ];

  return spotify.createAuthorizeURL(scopes, "state123");
}

export async function exchangeCodeForTokens(code) {
  const spotify = createSpotifyClient();
  const data = await spotify.authorizationCodeGrant(code);
  return {
    accessToken: data.body.access_token,
    refreshToken: data.body.refresh_token,
    expiresIn: data.body.expires_in
  };
}

export async function refreshAccessToken(refreshToken) {
  const spotifyApi = new SpotifyWebApi({
    clientId: process.env.SPOTIFY_CLIENT_ID,
    clientSecret: process.env.SPOTIFY_CLIENT_SECRET,
    redirectUri: process.env.SPOTIFY_REDIRECT_URI,
  });

  spotifyApi.setRefreshToken(refreshToken);

  const data = await spotifyApi.refreshAccessToken();
  return {
    accessToken: data.body.access_token,
    // spotify sometimes returns a new refresh token, sometimes not
    refreshToken: data.body.refresh_token,
    expiresIn: data.body.expires_in,
  };
}
