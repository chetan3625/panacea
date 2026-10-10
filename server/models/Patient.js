const mongoose = require("mongoose");

const medicineSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    potency: { type: String, default: "30C" },
    dosage: { type: String, default: "" },
  },
  { _id: false },
);

const casePaperSchema = new mongoose.Schema(
  {
    paperType: { type: String, enum: ["1", "2", "3"], required: true },
    caseId: { type: String, default: "" },
    data: { type: mongoose.Schema.Types.Mixed, default: {} },
  },
  { timestamps: true },
);

const patientSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    mobile: { type: String, required: true, trim: true },
    age: { type: String, default: "" },
    gender: { type: String, default: "" },
    bloodGroup: { type: String, default: "" },
    address: { type: String, default: "" },
    complaints: { type: String, default: "" },
    diagnosis: { type: String, default: "" },
    advice: { type: String, default: "" },
    followUpDate: { type: Date, default: null },
    medicines: [medicineSchema],
    casePapers: [casePaperSchema],
    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: false,
    },
  },
  { timestamps: true },
);

module.exports = mongoose.model("Patient", patientSchema);
