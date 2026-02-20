import { getSpotifyLoginUrl, exchangeCodeForTokens, createSpotifyClient } from "../services/spotifyService.js";
import User from "../models/User.js";

export function login(req, res) {
  const url = getSpotifyLoginUrl();
  res.redirect(url);
}

export async function callback(req, res) {
  try {
    const code = req.query.code;
    if (!code) return res.status(400).send("Missing code");

    // Exchange code for tokens
    const { accessToken, refreshToken } = await exchangeCodeForTokens(code);

    // Get user info from Spotify
    const spotify = createSpotifyClient(accessToken, refreshToken);
    const spotifyUser = await spotify.getMe();

    const spotifyId = spotifyUser.body.id;
    const spotifyName = spotifyUser.body.display_name;
    const spotifyEmail = spotifyUser.body.email;

    //getting user's profile picture
    const spotifyImageUrl = spotifyUser.body.images?.[0]?.url ?? "";

    // Find or create user
    let user = await User.findOne({ spotify_user_id: spotifyId });
    console.log("Spotify user logged in:");
    console.log("   display_name:", spotifyName);
    console.log("   spotify_id:", spotifyId);
    console.log("   email:", spotifyEmail);

    if (!user) {
      console.log("New user! Creating account in MongoDB...");

      user = new User({
        username: spotifyId,
        email: spotifyEmail,
        name: spotifyName,
        spotify_user_id: spotifyId,
        spotify_access_token: accessToken,
        spotify_refresh_token: refreshToken,
        profile_photo_url: spotifyImageUrl
      });
      await user.save();
      console.log("New user saved to MongoDB!");
    } else {
      console.log("Existing user found! Updating tokens...");
      user.spotify_access_token = accessToken;
      user.spotify_refresh_token = refreshToken;
      user.profile_photo_url = spotifyImageUrl;
      await user.save();
      console.log("Tokens updated in MongoDB!");
    }

    // redirect to Flutter app
    const redirectUrl =
      `${process.env.FLUTTER_REDIRECT_URL}` +
      `?userId=${user._id}` +
      `&name=${encodeURIComponent(spotifyName)}`;
    res.redirect(redirectUrl);

  } catch (err) {
    console.error(err);
    res.status(500).send("Auth failed");
  }
}
