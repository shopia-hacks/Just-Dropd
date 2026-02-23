// controllers/countdownsController.js
import Countdown from "../models/Countdown.js";

// add a new countdown for a user
export async function createCountdown(req, res) {
  try {
    const { userId, spotify_album_id, is_main, clock_style } = req.body;

    // if this is being set as the main countdown, unset any existing main
    if (is_main) {
      await Countdown.updateMany({ userId, is_main: true }, { is_main: false });
    }

    const countdown = new Countdown({ userId, spotify_album_id, is_main, clock_style });
    await countdown.save();
    res.status(201).json(countdown);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// get all countdowns for a user
export async function getCountdownsByUser(req, res) {
  try {
    const countdowns = await Countdown.find({ userId: req.params.userId })
      .sort({ is_main: -1, createdAt: -1 });  // main first, then newest
    res.json(countdowns);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// get the main (pinned) countdown for a user
export async function getMainCountdown(req, res) {
  try {
    const countdown = await Countdown.findOne({
      userId: req.params.userId,
      is_main: true
    });
    if (!countdown) return res.status(404).send("No main countdown set");
    res.json(countdown);
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// set a different countdown as main
export async function setMainCountdown(req, res) {
  try {
    const { userId } = req.body;

    // unset existing main for this user
    await Countdown.updateMany({ userId, is_main: true }, { is_main: false });

    const countdown = await Countdown.findByIdAndUpdate(
      req.params.id,
      { is_main: true },
      { new: true }
    );
    if (!countdown) return res.status(404).send("Countdown not found");
    res.json(countdown);
  } catch (err) {
    res.status(400).send(err.message);
  }
}

// delete a countdown
export async function deleteCountdown(req, res) {
  try {
    const countdown = await Countdown.findByIdAndDelete(req.params.id);
    if (!countdown) return res.status(404).send("Countdown not found");
    res.json({ message: "Countdown deleted" });
  } catch (err) {
    res.status(500).send(err.message);
  }
}

// get countdowns for a user's friend group (for the countdown feed)
export async function getFriendsCountdowns(req, res) {
  try {
    const { userIds } = req.body;  // array of friend userIds
    const countdowns = await Countdown.find({ userId: { $in: userIds } })
      .populate("userId", "username name profile_photo_url")
      .sort({ createdAt: 1 });  // frontend sorts by release date using Spotify data
    res.json(countdowns);
  } catch (err) {
    res.status(500).send(err.message);
  }
}