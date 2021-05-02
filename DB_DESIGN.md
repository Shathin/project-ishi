# Database Design

Project Ishi uses **Sembast** as the database for storing the user's data. Sembast was chosen since the app is primarly shipped as a Windows application and hence an offline database is fast and cost-effective.

---

## Field Types

The fields in a _record_ (determined by the user's _template_) will be a type from the following list.

```json
[
  "String", // -> A piece of text
  "LargeText", // -> This is stored as a string but is added as a separate type to help the UI render a larger space for viewing and editing
  "Number", // -> Integer or Floating point number
  "Money", // -> This is stored as a number but is added as a separate type to help the UI show the required currency symbol
  "Choice", // Multiple Choice -> Choices are strings
  "Array", // -> List of user defined entries
  "Timestamp", // -> Date and Time
  "Media" // -> Contains the name (String) and the URL (String) to the media
]
```

## Database Schema

Following is the database schema to be followed for the project.
A base _template_ will be be provided to each new user upon which they can build their template by adding or remove fields.

```json
{
  "user": {
    "name": "String", // -> Name of the user
    "patients": ["References to `patients` documents"], // -> List of references to the user's patients
    "records": ["References to `records` documents"], // -> List of references to the patient records
  },
  // -> The user's custom template
  "template": {
    // -> Either `patientDetails` or `procedureDetails`
    "detailsType": {
      // -> Field name in camel case
      "fieldName": {
        "name": "Field Name (as the user inputs)",
        "type": "Type of the field", // -> One of the types in `fieldTypes`
        "values": [], // -> This field is relevant only when the `type` of this field is an `Choice`
        "arrayType": "String/Number/Timestamp", // -> This field is relevant when the `type` of this field is an `Array`
        "mandatory": "Boolean", // -> Few fields are marked mandatory by default by the application and hence can't be deleted by the user.
        "sequence": "Number" // -> Determines in which order does this field render on the UI
      }
    }
  },
  // The default template -> Will be persisted in case the user wants to reset all data
  "baseTemplate": {
    "patientDetails": {
      "patientType": {
        "name": "Patient Type",
        "type": "Choice",
        "values": ["In-patient", "Out-patient"],
        "mandatory": false,
        "sequence": 1
      }
    },
    "procedureDetails": {
      "procedureName": {
        "name": "Procedure Name",
        "type": "String",
        "mandatory": true,
        "sequence": 1
      },
      "procedureCode": {
        "name": "Procedure Code",
        "type": "String",
        "mandatory": true,
        "sequence": 2
      },
      "dateOfProcedure": {
        "name": "Date of Procedure",
        "type": "Timestamp",
        "mandatory": true,
        "sequence": 3
      },
      "billedAmount": {
        "name": "Billed Amount",
        "type": "Money",
        "mandatory": true,
        "sequence": 4
      },
      "paidAmount": {
        "name": "Paid Amount",
        "type": "Money",
        "mandatory": true,
        "sequence": 5
      },
      "feeWaived": {
        "name": "Fee Waived?",
        "type": "Choice",
        "values": ["Yes", "No", "Partially"],
        "mandatory": true,
        "sequence": 6
      },
      "wardVisit": {
        "name": "Ward Visit",
        "type": "Array",
        "arrayType": "Timestamp",
        "mandatory": false,
        "sequence": 7
      },
      "report": {
        "name": "Report",
        "type": "Media",
        "mandatory": false,
        "sequence": 8
      },
      "consultationNote": {
        "name": "Consultation Note",
        "type": "LargeText",
        "mandatory": false,
        "sequence": 9
      }
    }
  },
  // -> Patients Collections
  "patients": {
    "documentId": {
      "name": "String", // -> Name of the patient
      "age": "Number", // -> Age of the patient
      "gender": "Choice", // -> Male, female, other, N/A
      "records": ["References to `records` documents"] // -> List of references to this patient's records
    }
  },
  // -> Records Collections
  "records": {
    "documentId": {
      "pid": "Reference to `patients` document", // -> Determines to which patient does this record belong to
      // Record data according to the user's customized template is stored below
      "detailsType": {
        // -> Either `patientDetails` or `procedureDetails`
        "fieldName1": "value", // -> This is the format for field types `String`, `LargeText`, `Number`, `Money`, `Choice`, `Timestamp`
        // -> This is the format for the field type `Media`
        "fieldName2": {
          "mediaName": "Name of the media",
          "mediaUrl": "URL to the media"
        },
        // -> This is the format for the field type `Array`
        "fieldName3": ["value1", "value2"]
      }
    }
  }
}
```
