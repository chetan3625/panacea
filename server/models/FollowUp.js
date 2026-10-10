const mongoose = require("mongoose");

const followUpSchema = new mongoose.Schema(
  {
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Patient",
      required: true,
      index: true,
    },
    date: { type: String, required: true },
    time: { type: String, default: "10:00 AM" },

    // Progression / Growth Status
    progressionStatus: {
      type: String,
      default: "Better (+40% Ameliorated)",
    },
    growthScore: {
      type: Number,
      default: 40, // Positive for Upgradation (+%), negative for Downgradation (-%)
    },

    // Remedy & Posology
    remedyPrescribed: { type: String, default: "Continue Current Remedy" },
    clinicalNotes: { type: String, default: "" },

    // Snapshot of Consolidated Case Papers Gathered
    gatheredCasePapersSummary: [
      {
        paperId: { type: mongoose.Schema.Types.ObjectId, ref: "CasePaper" },
        paperType: { type: String },
        summary: { type: String },
      },
    ],

    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("FollowUp", followUpSchema);
