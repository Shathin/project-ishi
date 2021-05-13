final Map<String, Map<String, dynamic>> baseTemplate = {
  "patientType": {
    "name": "Patient Type",
    "category": "Patient Details",
    "type": "Choice",
    "choices": ["In-patient", "Out-patient"],
    "mandatory": false,
    "sequence": 1
  },
  "procedureName": {
    "name": "Procedure Name",
    "category": "Procedure Details",
    "type": "String",
    "mandatory": true,
    "sequence": 1
  },
  "procedureCode": {
    "name": "Procedure Code",
    "category": "Procedure Details",
    "type": "String",
    "mandatory": true,
    "sequence": 2
  },
  "dateOfProcedure": {
    "name": "Date of Procedure",
    "category": "Procedure Details",
    "type": "Timestamp",
    "mandatory": true,
    "sequence": 3
  },
  "billedAmount": {
    "name": "Billed Amount",
    "category": "Procedure Details",
    "type": "Money",
    "mandatory": true,
    "sequence": 4
  },
  "paidAmount": {
    "name": "Paid Amount",
    "category": "Procedure Details",
    "type": "Money",
    "mandatory": true,
    "sequence": 5
  },
  "feeWaived?": {
    "name": "Fee Waived?",
    "category": "Procedure Details",
    "type": "Choice",
    "choices": ["Yes", "No", "Partially"],
    "mandatory": true,
    "sequence": 6
  },
  "wardVisit": {
    "name": "Ward Visit",
    "category": "Procedure Details",
    "type": "Array",
    "arrayType": "Timestamp",
    "mandatory": false,
    "sequence": 7
  },
  "report": {
    "name": "Report",
    "category": "Procedure Details",
    "type": "Media",
    "mandatory": false,
    "sequence": 8
  },
  "consultationNote": {
    "name": "Consultation Note",
    "category": "Procedure Details",
    "type": "Large Text",
    "mandatory": false,
    "sequence": 9
  }
};
