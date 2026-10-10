const CasePaper = require("../models/CasePaper");
const Patient = require("../models/Patient");

// @desc    Create a new Case Paper (Type 1, 2, or 3)
// @route   POST /api/case-papers
// @access  Private
const createCasePaper = async (req, res) => {
  try {
    const { patientId, paperType, ...caseData } = req.body;

    if (!patientId || !paperType) {
      return res.status(400).json({
        success: false,
        message: "patientId and paperType are required",
      });
    }

    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: "Patient not found",
      });
    }

    const currentDate = new Date().toLocaleDateString('en-GB', {
      day: '2-digit',
      month: 'short',
      year: 'numeric'
    });
    const currentTime = new Date().toLocaleTimeString('en-US', {
      hour: '2-digit',
      minute: '2-digit',
      hour12: true
    });

    const casePaper = await CasePaper.create({
      patient: patientId,
      paperType,
      date: caseData.date || currentDate,
      time: caseData.time || currentTime,
      ...caseData,
      createdBy: req.user.id,
    });

    // Update caseId field to document _id
    casePaper.caseId = casePaper._id.toString();
    await casePaper.save();

    // Push snapshot reference to Patient document casePapers array
    patient.casePapers.push({
      paperType: paperType.includes("1")
        ? "1"
        : paperType.includes("2")
        ? "2"
        : "3",
      caseId: casePaper._id.toString(),
      data: {
        date: casePaper.date,
        time: casePaper.time,
        paperType: casePaper.paperType,
        chiefComplaint: casePaper.chiefComplaints || "Intake Completed",
        remedy: casePaper.prescription && casePaper.prescription.length > 0
          ? `${casePaper.prescription[0].name} ${casePaper.prescription[0].potency}`
          : "Remedy Pending",
      },
    });
    await patient.save();

    return res.status(201).json({
      success: true,
      message: "Case Paper created successfully",
      casePaper,
    });
  } catch (error) {
    console.error("Create CasePaper Error:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to create Case Paper",
    });
  }
};

// @desc    Get all Case Papers for a Patient
// @route   GET /api/case-papers/patient/:patientId
// @access  Private
const getPatientCasePapers = async (req, res) => {
  try {
    const { patientId } = req.params;
    const casePapers = await CasePaper.find({ patient: patientId }).sort({
      createdAt: -1,
    });

    return res.status(200).json({
      success: true,
      count: casePapers.length,
      casePapers,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch Case Papers",
    });
  }
};

// @desc    Get single Case Paper by ID
// @route   GET /api/case-papers/:id
// @access  Private
const getCasePaperById = async (req, res) => {
  try {
    const casePaper = await CasePaper.findById(req.params.id);
    if (!casePaper) {
      return res.status(404).json({
        success: false,
        message: "Case Paper not found",
      });
    }

    return res.status(200).json({
      success: true,
      casePaper,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch Case Paper",
    });
  }
};

// @desc    Update a Case Paper
// @route   PUT /api/case-papers/:id
// @access  Private
const updateCasePaper = async (req, res) => {
  try {
    const casePaper = await CasePaper.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!casePaper) {
      return res.status(404).json({
        success: false,
        message: "Case Paper not found",
      });
    }

    // Update snapshot in Patient document casePapers array
    await Patient.updateOne(
      { _id: casePaper.patient, "casePapers.caseId": casePaper._id.toString() },
      {
        $set: {
          "casePapers.$.paperType": casePaper.paperType.includes("1")
            ? "1"
            : casePaper.paperType.includes("2")
            ? "2"
            : "3",
          "casePapers.$.data": {
            date: casePaper.date || new Date().toLocaleDateString(),
            time: casePaper.time || "",
            paperType: casePaper.paperType,
            chiefComplaint: casePaper.chiefComplaints || "Intake Updated",
            remedy: casePaper.prescription && casePaper.prescription.length > 0
              ? `${casePaper.prescription[0].name} ${casePaper.prescription[0].potency}`
              : "Remedy Pending",
          },
        },
      }
    );

    return res.status(200).json({
      success: true,
      message: "Case Paper updated successfully",
      casePaper,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to update Case Paper",
    });
  }
};

// @desc    Delete a Case Paper
// @route   DELETE /api/case-papers/:id
// @access  Private
const deleteCasePaper = async (req, res) => {
  try {
    const casePaper = await CasePaper.findByIdAndDelete(req.params.id);

    if (!casePaper) {
      return res.status(404).json({
        success: false,
        message: "Case Paper not found",
      });
    }

    // Pull snapshot reference from Patient document casePapers array
    await Patient.findByIdAndUpdate(casePaper.patient, {
      $pull: { casePapers: { caseId: casePaper._id.toString() } },
    });

    return res.status(200).json({
      success: true,
      message: "Case Paper deleted successfully",
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to delete Case Paper",
    });
  }
};

module.exports = {
  createCasePaper,
  getPatientCasePapers,
  getCasePaperById,
  updateCasePaper,
  deleteCasePaper,
};
