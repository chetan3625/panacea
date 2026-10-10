const FollowUp = require("../models/FollowUp");
const CasePaper = require("../models/CasePaper");
const Patient = require("../models/Patient");

// @desc    Log a new Consolidated Follow-Up Visit
// @route   POST /api/follow-ups
// @access  Private
const createFollowUp = async (req, res) => {
  try {
    const { patientId, progressionStatus, remedyPrescribed, clinicalNotes, date, time } = req.body;

    if (!patientId) {
      return res.status(400).json({
        success: false,
        message: "patientId is required",
      });
    }

    const patient = await Patient.findById(patientId);
    if (!patient) {
      return res.status(404).json({
        success: false,
        message: "Patient not found",
      });
    }

    // 1. Automatically Gather all existing Case Papers for this patient
    const existingCasePapers = await CasePaper.find({ patient: patientId });
    const gatheredSummary = existingCasePapers.map((cp) => ({
      paperId: cp._id,
      paperType: cp.paperType,
      summary: `Complaints: ${cp.chiefComplaints || "N/A"} | Miasm: ${cp.miasm || "N/A"}`,
    }));

    // 2. Compute Growth / Upgradation Score
    let growthScore = 40;
    if (progressionStatus) {
      if (progressionStatus.includes("70%")) growthScore = 70;
      else if (progressionStatus.includes("40%")) growthScore = 40;
      else if (progressionStatus.includes("0%") || progressionStatus.includes("Unchanged")) growthScore = 0;
      else if (progressionStatus.includes("-20%") || progressionStatus.includes("Worse")) growthScore = -20;
    }

    const now = new Date();
    const dateStr = date || `${now.getDate()}/${now.getMonth() + 1}/${now.getFullYear()}`;
    const timeStr = time || `${now.getHours()}:${String(now.getMinutes()).padStart(2, "0")}`;

    const followUp = await FollowUp.create({
      patient: patientId,
      date: dateStr,
      time: timeStr,
      progressionStatus: progressionStatus || "Better (+40% Ameliorated)",
      growthScore,
      remedyPrescribed: remedyPrescribed || "Continue Current Remedy",
      clinicalNotes: clinicalNotes || "",
      gatheredCasePapersSummary: gatheredSummary,
      createdBy: req.user.id,
    });

    return res.status(201).json({
      success: true,
      message: "Consolidated Follow-Up logged successfully",
      followUp,
    });
  } catch (error) {
    console.error("Create FollowUp Error:", error);
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to log Follow-Up Visit",
    });
  }
};

// @desc    Get all Follow-Up Visits for a Patient
// @route   GET /api/follow-ups/patient/:patientId
// @access  Private
const getPatientFollowUps = async (req, res) => {
  try {
    const { patientId } = req.params;
    const followUps = await FollowUp.find({ patient: patientId }).sort({
      createdAt: -1,
    });

    return res.status(200).json({
      success: true,
      count: followUps.length,
      followUps,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch Follow-Up Visits",
    });
  }
};

// @desc    Get single Follow-Up Record
// @route   GET /api/follow-ups/:id
// @access  Private
const getFollowUpById = async (req, res) => {
  try {
    const followUp = await FollowUp.findById(req.params.id).populate("patient");
    if (!followUp) {
      return res.status(404).json({
        success: false,
        message: "Follow-Up record not found",
      });
    }

    return res.status(200).json({
      success: true,
      followUp,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch Follow-Up record",
    });
  }
};

// @desc    Update a Follow-Up Visit
// @route   PUT /api/follow-ups/:id
// @access  Private
const updateFollowUp = async (req, res) => {
  try {
    const followUp = await FollowUp.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    );

    if (!followUp) {
      return res.status(404).json({
        success: false,
        message: "Follow-Up record not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Follow-Up record updated successfully",
      followUp,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to update Follow-Up record",
    });
  }
};

// @desc    Delete a Follow-Up Visit
// @route   DELETE /api/follow-ups/:id
// @access  Private
const deleteFollowUp = async (req, res) => {
  try {
    const followUp = await FollowUp.findByIdAndDelete(req.params.id);

    if (!followUp) {
      return res.status(404).json({
        success: false,
        message: "Follow-Up record not found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Follow-Up record deleted successfully",
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to delete Follow-Up record",
    });
  }
};

// @desc    Get "Where Is My Train" Train Track Timeline & Growth Chart Series Data
// @route   GET /api/follow-ups/patient/:patientId/timeline
// @access  Private
const getPatientTimelineAndAnalytics = async (req, res) => {
  try {
    const { patientId } = req.params;

    // Fetch both Case Papers and FollowUps
    const casePapers = await CasePaper.find({ patient: patientId }).sort({ createdAt: 1 });
    const followUps = await FollowUp.find({ patient: patientId }).sort({ createdAt: 1 });

    const timeline = [];

    // Map Case Papers as Baseline Station Nodes
    casePapers.forEach((cp) => {
      timeline.push({
        id: cp._id,
        type: "casePaper",
        title: cp.paperType,
        date: cp.date || cp.createdAt.toLocaleDateString(),
        time: cp.time || "Intake",
        status: "Baseline Intake",
        growthScore: 0,
        remedy: cp.prescription && cp.prescription.length > 0
          ? `${cp.prescription[0].name} ${cp.prescription[0].potency}`
          : "Remedy Prescribed",
        details: cp,
      });
    });

    // Map FollowUps as Progression Station Nodes
    followUps.forEach((fu) => {
      timeline.push({
        id: fu._id,
        type: "followUp",
        title: "Follow-Up Visit",
        date: fu.date,
        time: fu.time,
        status: fu.progressionStatus,
        growthScore: fu.growthScore,
        remedy: fu.remedyPrescribed,
        details: fu,
      });
    });

    // Sort combined timeline by date/createdAt
    timeline.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());

    // Compute Overall Health Growth Metric
    const latestScore = timeline.length > 0 ? (timeline[0].growthScore || 0) : 0;

    return res.status(200).json({
      success: true,
      timeline,
      analytics: {
        totalVisits: timeline.length,
        casePaperCount: casePapers.length,
        followUpCount: followUps.length,
        currentGrowthScore: latestScore,
        trendStatus: latestScore >= 0 ? "Upgradation" : "Downgradation",
      },
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: error.message || "Failed to fetch timeline analytics",
    });
  }
};

module.exports = {
  createFollowUp,
  getPatientFollowUps,
  getFollowUpById,
  updateFollowUp,
  deleteFollowUp,
  getPatientTimelineAndAnalytics,
};
