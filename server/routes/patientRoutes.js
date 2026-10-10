const express = require("express");
const {
  createPatient,
  updatePatient,
  deletePatient,
  getPatients,
  getPatientById,
} = require("../controllers/patientController");
const protect = require("../middleware/authMiddleware");

const router = express.Router();

router.route("/").get(protect, getPatients).post(protect, createPatient);
router
  .route("/:id")
  .get(protect, getPatientById)
  .put(protect, updatePatient)
  .delete(protect, deletePatient);

module.exports = router;
