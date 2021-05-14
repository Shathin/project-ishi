import 'template_field_array_type.dart';
import 'template_field_category.dart';
import 'template_field_type.dart';

/// Class that represents a field description in a template
class TemplateField {
  /// Represents the field name in camelCase -> A field is accessed via this key in the database.
  /// This will be auto-generated by the class using the [fieldName] attribute
  final String fieldKey;

  /// Represents the name of the field
  final String fieldName;

  /// Represents the category to which the template field belongs to
  final TemplateFieldCategory category;

  /// Represents the type of the field
  final TemplateFieldType type;

  /// Represents the data type of the values stored for a field of type [TemplateFieldType.Array]
  final TemplateFieldArrayType? arrayType;

  /// Represents the list of choices available for a field of type [TemplateFieldType.Choice]
  final List<String>? choices;

  /// Determines if a field can be deleted
  /// Default to [false]
  final bool mandatory;

  /// Determines in which order does this field render on the UI
  final int sequence;

  /// Constructor to instantiate the [TemplateField] class
  TemplateField({
    required String fieldName,
    required this.category,
    required this.type,
    required this.sequence,
    this.mandatory = false,
    this.choices,
    this.arrayType,
  })  : this.fieldKey = generateFieldKey(fieldName),
        this.fieldName = fieldName;

  /// Method to convert the [TemplateField] object into a map
  Map<String, dynamic> objectToMap() {
    Map<String, dynamic> templateFieldMap = {
      "name": this.fieldName,
      "category": this.category.enumToString(),
      "type": this.type.enumToString(),
      "mandatory": this.mandatory,
      "sequence": this.sequence,
    };

    if (this.type == TemplateFieldType.Choice)
      templateFieldMap["choices"] = this.choices ?? [];
    else if (this.type == TemplateFieldType.Array)
      templateFieldMap["arrayType"] = this.arrayType?.enumToString();

    return templateFieldMap;
  }

  /// Method to convert a map containing a template's field into a [TemplateField] object
  static TemplateField mapToObject({
    required Map<String, dynamic> templateFieldMap,
  }) {
    TemplateFieldType templateFieldType =
        TemplateFieldTypeStringInterconversion.stringToEnum(
      templateFieldMap["type"],
    );

    return TemplateField(
      fieldName: templateFieldMap["name"],
      category: TemplateFieldCategoryStringInterconversion.stringToEnum(
        templateFieldMap["category"],
      ),
      type: templateFieldType,
      choices: templateFieldType == TemplateFieldType.Choice
          ? List<String>.from(templateFieldMap["choices"])
          : null,
      // Set [templateFieldArrayType] only if the field type is [TemplateFieldType.array]
      arrayType: templateFieldType == TemplateFieldType.Array
          ? TemplateFieldArrayTypeStringInterconversion.stringToEnum(
              templateFieldMap["arrayType"],
            )
          : null,
      mandatory: templateFieldMap["mandatory"] ?? false,
      sequence: templateFieldMap["sequence"],
    );
  }

  /// Method that returns a copy of the current [TemplateField] object with a specified fields replaced by the arguments passed to this method
  TemplateField copyWith({
    String? fieldName,
    TemplateFieldCategory? category,
    TemplateFieldType? type,
    TemplateFieldArrayType? arrayType,
    List<String>? choices,
    int? sequence,
  }) =>
      TemplateField(
        fieldName: fieldName ?? this.fieldName,
        category: category ?? this.category,
        type: type ?? this.type,
        // ! The [arrayType] is copied to the new [TemplateField] object only if the type of the field is [TemplateFieldType.Array]
        arrayType: type == null
            ? this.type == TemplateFieldType.Array
                ? (arrayType ?? this.arrayType)
                : null
            : type == TemplateFieldType.Array
                ? (arrayType ?? this.arrayType)
                : null,
        // ! The [choices] list is copied to the new [TemplateField] object only if the type of the field is [TemplateFieldType.Choice]
        choices: type == null
            ? this.type == TemplateFieldType.Choice
                ? (choices ?? this.choices)
                : null
            : type == TemplateFieldType.Choice
                ? (choices ?? this.choices)
                : null,
        sequence: sequence ?? this.sequence,
        mandatory: this.mandatory,
      );

  /// Method that generates the [fieldKey] based on the [fieldName].
  ///
  /// This method converts the [fieldName] from the user provided value to a camelCase version of that
  ///
  /// Code shamelessly taken from https://www.30secondsofcode.org/dart/s/to-camel-case
  static String generateFieldKey(String fieldName) {
    String titleCase = fieldName
        .replaceAllMapped(
          RegExp(
            r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+',
          ),
          (match) =>
              "${match[0]?[0].toUpperCase()}${match[0]?.substring(1).toLowerCase()}",
        )
        .replaceAll(
          RegExp(r'(_|-|\s)+'),
          '',
        );
    String camelCase = titleCase[0].toLowerCase() + titleCase.substring(1);
    return camelCase;
  }

  @override
  String toString() {
    String fieldToString = '';

    fieldToString += '\n';
    fieldToString += '\t';
    fieldToString += '${this.fieldKey}: {';

    fieldToString += '\n';
    fieldToString += '\t\t';
    fieldToString += 'Name: ${this.fieldName}';
    fieldToString += ',';

    fieldToString += '\n';
    fieldToString += '\t\t';
    fieldToString += 'Type: ${this.type.enumToString()}';
    fieldToString += ',';

    if (this.type == TemplateFieldType.Choice) {
      fieldToString += '\n';
      fieldToString += '\t\t';
      fieldToString += 'Choices: ${this.choices}';
      fieldToString += ',';
    } else if (this.type == TemplateFieldType.Array) {
      fieldToString += '\n';
      fieldToString += '\t\t';
      fieldToString += 'Array Type: ${this.arrayType?.enumToString()}';
      fieldToString += ',';
    }

    fieldToString += '\n';
    fieldToString += '\t\t';
    fieldToString += 'Mandatory: ${this.mandatory}';
    fieldToString += ',';

    fieldToString += '\n';
    fieldToString += '\t\t';
    fieldToString += 'Sequence: ${this.sequence}';
    fieldToString += ',';

    fieldToString += '\n';
    fieldToString += '\t';
    fieldToString += '}';

    return fieldToString;
  }
}
