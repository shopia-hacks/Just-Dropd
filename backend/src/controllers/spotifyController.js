import { createSpotifyClient } from "../services/spotifyService.js";

export async function getMe(req, res) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).send("Missing access token");
    }
    const accessToken = authHeader.replace("Bearer ", "");

    const spotify = createSpotifyClient(accessToken);
    const me = await spotify.getMe();

    res.json(me.body);
  } catch (err) {
    console.error(err);
    res.status(401).send("Not authenticated");
  }
}
