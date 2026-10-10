const express = require("express");
const router = express.Router();
const protect = require("../middleware/authMiddleware");
const {
  createCasePaper,
  getPatientCasePapers,
  getCasePaperById,
  updateCasePaper,
  deleteCasePaper,
} = require("../controllers/casePaperController");

// All routes require authentication
router.use(protect);

router.post("/", createCasePaper);
router.get("/patient/:patientId", getPatientCasePapers);
router.get("/:id", getCasePaperById);
router.put("/:id", updateCasePaper);
router.delete("/:id", deleteCasePaper);

module.exports = router;
