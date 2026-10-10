const mongoose = require("mongoose");

const medicineItemSchema = new mongoose.Schema(
  {
    name: { type: String, default: "" },
    potency: { type: String, default: "30C" },
    dosage: { type: String, default: "" },
  },
  { _id: false }
);

const casePaperSchema = new mongoose.Schema(
  {
    patient: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Patient",
      required: true,
      index: true,
    },
    paperType: {
      type: String,
      enum: [
        "Case Paper 1: Original Case Paper (Constitutional)",
        "Case Paper 2: Acute Case Paper",
        "Case Paper 3: Thyroid Case Paper",
      ],
      required: true,
    },
    caseId: { type: String, default: "" },
    date: { type: String, default: "" },
    time: { type: String, default: "" },

    // Frame 1: Demographics
    demographics: {
      maritalStatus: { type: String, default: "Single" },
      occupation: { type: String, default: "" },
      referredBy: { type: String, default: "Self / Direct" },
    },

    // Frame 2: Chief Complaints & Causation
    chiefComplaints: { type: String, default: "" },
    causation: { type: String, default: "" },
    historyOfMedicines: { type: String, default: "" },
    endocrinalInterventions: [{ type: String }],

    // Frame 3: Past History
    pastDiseases: [{ type: String }],

    // Frame 4: Family History & Miasm
    familyHistoryMatrix: { type: mongoose.Schema.Types.Mixed, default: {} },
    miasm: { type: String, default: "Psora" },

    // Frame 5: Physical Generals & Modalities
    physicalGenerals: {
      thermals: { type: String, default: "Ambi-thermal" },
      thirst: { type: String, default: "Normal" },
      thirstTemp: { type: String, default: "Normal" },
      sweatIntensity: { type: String, default: "Moderate" },
      bowelUrineTraits: [{ type: String }],
      dreamCategories: [{ type: String }],
      modalities: { type: mongoose.Schema.Types.Mixed, default: {} },
    },

    // Frame 6: Female History
    femaleHistory: {
      menarcheAge: { type: String, default: "" },
      isCycleRegular: { type: String, default: "Regular" },
      menstrualFlow: { type: String, default: "Normal" },
      mensesConcomitants: [{ type: String }],
      leucorrhoeaTags: [{ type: String }],
    },

    // Frame 7: Examination
    examination: {
      bp: { type: String, default: "" },
      pulse: { type: String, default: "" },
      weight: { type: String, default: "" },
      height: { type: String, default: "" },
      inspectionTags: [{ type: String }],
    },

    // Frame 8: Mentals & Prescription
    mentals: [{ type: String }],
    prescription: [medicineItemSchema],
    prescriptionNotes: { type: String, default: "" },

    // Case Paper 2: Acute Specific Details
    acuteDetails: {
      onsetSpeed: { type: String, default: "Sudden (Hours)" },
      excitingCause: { type: String, default: "Cold Draught / Wind" },
      notes: { type: String, default: "" },
    },

    // Case Paper 3: Thyroid Specific Details
    thyroidDetails: {
      diagnosis: { type: String, default: "Hypothyroidism" },
      onsetTrigger: { type: String, default: "Puberty / Hormonal Phase" },
      goitreLocation: { type: String, default: "Neck Swelling (Diffuse)" },
      goitreSensation: { type: String, default: "Constriction / Air Passing" },
      goitreModality: { type: String, default: "Swallowing Aggravation" },
      physiqueEmaciation: { type: String, default: "Myxoedema / Puffy Physique" },
      lab: {
        t3: { type: String, default: "" },
        t4: { type: String, default: "" },
        tsh: { type: String, default: "" },
        antiTpo: { type: String, default: "" },
      },
    },

    createdBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("CasePaper", casePaperSchema);
