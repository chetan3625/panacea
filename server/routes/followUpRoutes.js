const express = require("express");
const router = express.Router();
const protect = require("../middleware/authMiddleware");
const {
  createFollowUp,
  getPatientFollowUps,
  getFollowUpById,
  updateFollowUp,
  deleteFollowUp,
  getPatientTimelineAndAnalytics,
} = require("../controllers/followUpController");

// All routes require authentication
router.use(protect);

router.post("/", createFollowUp);
router.get("/patient/:patientId", getPatientFollowUps);
router.get("/patient/:patientId/timeline", getPatientTimelineAndAnalytics);
router.get("/:id", getFollowUpById);
router.put("/:id", updateFollowUp);
router.delete("/:id", deleteFollowUp);

module.exports = router;
