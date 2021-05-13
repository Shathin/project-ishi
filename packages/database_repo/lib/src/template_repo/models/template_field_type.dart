/// Represents the type of the field
enum TemplateFieldType {
  /// A piece of text
  String,

  /// This is stored as a string but is added as a separate type to help the UI render a larger space for viewing and editing
  LargeText,

  /// Integer or Floating point number
  Number,

  /// This is stored as a number but is added as a separate type to help the UI show the required currency symbol
  Money,

  /// Multiple Choice -> Choices are strings
  Choice,

  /// List of user defined entries -> Entry types are defined in the [TemplateFieldArrayType] enum
  Array,

  /// Date and Time
  Timestamp,

  /// Contains the name (String) and the URL (String) to the media
  Media,
}

/// An extension that provides additional functionality to the [TemplateFieldType] enum
extension TemplateFieldTypeStringInterconversion on TemplateFieldType {
  /// Method that converts the string version of the enum to enum type
  ///
  /// This method performs exact string match! If no match is found then method defaults to returning [TemplateFieldType.String]
  static TemplateFieldType stringToEnum(String typeString) {
    switch (typeString) {
      case 'String':
        return TemplateFieldType.String;
      case 'Large Text':
        return TemplateFieldType.LargeText;
      case 'Number':
        return TemplateFieldType.Number;
      case 'Money':
        return TemplateFieldType.Money;
      case 'Choice':
        return TemplateFieldType.Choice;
      case 'Array':
        return TemplateFieldType.Array;
      case 'Timestamp':
        return TemplateFieldType.Timestamp;
      case 'Media':
        return TemplateFieldType.Media;
      default:
        return TemplateFieldType.String;
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
