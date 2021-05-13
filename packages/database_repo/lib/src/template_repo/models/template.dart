import '../../../template_repo.dart';
import 'template_field.dart';

/// Class represents the user defined template based on which the records are constructed
class Template {
  final List<TemplateField> patientDetails;
  final List<TemplateField> procedureDetails;

  Template._({required this.patientDetails, required this.procedureDetails});

  /// Method to convert the [Template] object into a Map
  Map<String, Map<String, dynamic>> objectToMap() {
    Map<String, Map<String, dynamic>> templateMap =
        <String, Map<String, dynamic>>{};

    [...patientDetails, ...procedureDetails].forEach((field) {
      templateMap[field.fieldKey] = field.objectToMap();
    });

    return templateMap;
  }

  /// Method to convert a map containing the template into a [Template] object
  ///
  /// The [patientDetails] and the [procedureDetails] lists are sorted before the object is instantiated
  static Template mapToObject({required Map<String, dynamic> templateMap}) {
    final List<TemplateField> patientDetails = [];
    final List<TemplateField> procedureDetails = [];

    templateMap.forEach((fieldKey, templateFieldMap) {
      final TemplateField templateField =
          TemplateField.mapToObject(templateFieldMap: templateFieldMap);

      if (templateField.category == TemplateFieldCategory.PatientDetails)
        patientDetails.add(templateField);
      else
        procedureDetails.add(templateField);
    });

    patientDetails
        .sort((fieldA, fieldB) => fieldA.sequence.compareTo(fieldB.sequence));
    procedureDetails
        .sort((fieldA, fieldB) => fieldA.sequence.compareTo(fieldB.sequence));

    return Template._(
      patientDetails: patientDetails,
      procedureDetails: procedureDetails,
    );
  }

  @override
  String toString() =>
      'Patient Details -> ${this.patientDetails}\nProcedure Details -> ${this.procedureDetails}';
}
