import app from "./app.js";
// import connectDB from "./config/db.js";

import dotenv from "dotenv";
import connectDB from "./config/db.js";
dotenv.config();

connectDB();

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
  console.log('Spotify Login at http://127.0.0.1:3000/login')
});
