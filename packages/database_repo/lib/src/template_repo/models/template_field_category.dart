/// Represents the category to which a template field belongs to
enum TemplateFieldCategory {
  /// Represents the Patient Details category
  PatientDetails,

  /// Represents the Procedure Details category
  ProcedureDetails,
}

/// An extension that provides additional functionality to the [TemplateFieldType] enum
extension TemplateFieldCategoryStringInterconversion on TemplateFieldCategory {
  /// Method that converts the string version of the enum to enum type
  ///
  /// This method performs exact string match! If no match is found then method defaults to returning [TemplateFieldCategory.PatientDetails]
  static TemplateFieldCategory stringToEnum(String typeString) {
    switch (typeString) {
      case 'Procedure Details':
        return TemplateFieldCategory.ProcedureDetails;
      case 'Patient Details':
      default:
        return TemplateFieldCategory.PatientDetails;
    }
  }

  /// Method that converts the enum type to a string
  String enumToString() => this
      .toString()
      .split('.')
      .last
      .split(RegExp(r"(?<=[a-z])(?=[A-Z])"))
      .join(" ");
}
