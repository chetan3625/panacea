const Patient = require("../models/Patient");

const createPatient = async (req, res) => {
  try {
    const patient = await Patient.create({
      ...req.body,
      createdBy: req.user.id,
    });

    return res.status(201).json({
      success: true,
      message: "Patient created successfully",
      patient,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Patient creation failed",
    });
  }
};

const getPatients = async (req, res) => {
  try {
    const patients = await Patient.find({ createdBy: req.user.id }).sort({
      createdAt: -1,
    });
    return res.status(200).json({ success: true, patients });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Failed to fetch patients",
    });
  }
};

const getPatientById = async (req, res) => {
  try {
    const patient = await Patient.findOne({
      _id: req.params.id,
      createdBy: req.user.id,
    });
    if (!patient) {
      return res
        .status(404)
        .json({ success: false, message: "Patient not found" });
    }

    return res.status(200).json({ success: true, patient });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Failed to fetch patient",
    });
  }
};

const updatePatient = async (req, res) => {
  try {
    const editableFields = [
      "name",
      "mobile",
      "age",
      "gender",
      "bloodGroup",
      "address",
      "complaints",
      "diagnosis",
      "advice",
      "followUpDate",
      "medicines",
      "casePapers",
    ];
    const updates = Object.fromEntries(
      Object.entries(req.body).filter(([key]) => editableFields.includes(key)),
    );
    const patient = await Patient.findOneAndUpdate(
      { _id: req.params.id, createdBy: req.user.id },
      updates,
      { new: true, runValidators: true },
    );

    if (!patient) {
      return res
        .status(404)
        .json({ success: false, message: "Patient not found" });
    }

    return res.status(200).json({
      success: true,
      message: "Patient updated successfully",
      patient,
    });
  } catch (error) {
    return res.status(error.name === "ValidationError" ? 400 : 500).json({
      success: false,
      message: error.message || "Patient update failed",
    });
  }
};

const deletePatient = async (req, res) => {
  try {
    const patient = await Patient.findOneAndDelete({
      _id: req.params.id,
      createdBy: req.user.id,
    });

    if (!patient) {
      return res
        .status(404)
        .json({ success: false, message: "Patient not found" });
    }

    return res
      .status(200)
      .json({ success: true, message: "Patient deleted successfully" });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Patient deletion failed",
    });
  }
};

module.exports = {
  createPatient,
  updatePatient,
  deletePatient,
  getPatients,
  getPatientById,
};
