const path = require("path");
require("dotenv").config({ path: path.join(__dirname, ".env") });
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");
const patientRoutes = require("./routes/patientRoutes");

const app = express();

connectDB();

app.use(
  cors({
    origin: true,
    credentials: true,
  }),
);
app.use(express.json({ limit: "5mb" }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan("dev"));

app.get("/api/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Panacea API is running",
    timestamp: new Date().toISOString(),
  });
});

app.use("/api/auth", authRoutes);
app.use("/api/patients", patientRoutes);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: err.message || "Internal Server Error",
  });
});

const PORT = process.env.PORT || 5000;

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Panacea API listening on port ${PORT}`);
});
