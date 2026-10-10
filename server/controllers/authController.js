const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

const generateToken = (id) =>
  jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: "7d" });

const registerUser = async (req, res) => {
  try {
    const { name, mobile, password, role } = req.body;

    if (!name || !mobile || !password) {
      return res.status(400).json({
        success: false,
        message: "Name, mobile and password are required",
      });
    }

    const existingUser = await User.findOne({ mobile });
    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "User already exists with this mobile number",
      });
    }

    const hashedPassword = await bcrypt.hash(password, 10);
    const user = await User.create({
      name,
      mobile,
      password: hashedPassword,
      role: role || "staff",
    });

    return res.status(201).json({
      success: true,
      message: "User registered successfully",
      token: generateToken(user._id),
      user: {
        id: user._id,
        name: user.name,
        mobile: user.mobile,
        role: user.role,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Registration failed",
    });
  }
};

const loginUser = async (req, res) => {
  try {
    const { mobile, password } = req.body;

    if (!mobile || !password) {
      return res.status(400).json({
        success: false,
        message: "Mobile and password are required",
      });
    }

    const user = await User.findOne({ mobile });
    if (!user) {
      return res.status(401).json({
        success: false,
        message: "Invalid mobile number or password",
      });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: "Invalid mobile number or password",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Login successful",
      token: generateToken(user._id),
      user: {
        id: user._id,
        name: user.name,
        mobile: user.mobile,
        role: user.role,
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Login failed",
    });
  }
};

const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    return res.status(200).json({ success: true, user });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Could not fetch profile",
    });
  }
};

module.exports = { registerUser, loginUser, getMe };
