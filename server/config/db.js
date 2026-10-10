const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      serverSelectionTimeoutMS: 15000,
      retryWrites: true,
      w: "majority",
      tls: true,
      authSource: "admin",
    });

    console.log(`MongoDB connected: ${conn.connection.host}`);
  } catch (error) {
    console.error("MongoDB connection failed:", error.message);
    console.error(
      "Check your Atlas network access, username/password, and TLS settings.",
    );
    process.exit(1);
  }
};

module.exports = connectDB;
