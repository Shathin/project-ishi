/// Represents the type of values stored in a [TemplateFieldType.Array] field
enum TemplateFieldArrayType {
  /// A piece of text
  String,

  /// Integer or Floating point number
  Number,

  /// Date and Time
  Timestamp,
}

/// An extension that provides additional functionality to the [TemplateFieldType] enum
extension TemplateFieldArrayTypeToStringInterconversion
    on TemplateFieldArrayType {
  /// Method that converts the string version of the enum to enum type
  ///
  /// This method performs exact string match! If no match is found then method defaults to returning [TemplateFieldArrayType.String]
  static TemplateFieldArrayType stringToEnum(String typeString) {
    switch (typeString) {
      case 'String':
        return TemplateFieldArrayType.String;
      case 'Number':
        return TemplateFieldArrayType.Number;
      case 'Timestamp':
        return TemplateFieldArrayType.Timestamp;
      default:
        return TemplateFieldArrayType.String;
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
