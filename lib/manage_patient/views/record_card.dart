import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/manage_patient/bloc/manage_patient_bloc.dart';
import 'package:project_ishi/manage_patient/views/form_views/text_input_field.dart';

import 'form_views/array_type_input.dart';
import 'form_views/choices_dropdown_field.dart';
import 'form_views/date_picker_field.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class RecordCard extends StatefulWidget {
  final Record? record;
  final Template template;

  RecordCard({
    this.record,
    required this.template,
  });

  @override
  RecordCardState createState() => RecordCardState(
        record: record,
        template: template,
      );
}

class RecordCardState extends State<RecordCard> {
  final Template template;
  Record? record;

  RecordCardState({
    this.record,
    required this.template,
  });

  bool isEditing = false;
  bool updateRequired = false;

  final Map<String, dynamic> dataMap = {};

  List<String> patientFieldKeys = [];
  List<String> procedureFieldKeys = [];

  @override
  void initState() {
    if (this.record == null) {
      isEditing = true;
    }

    // * Process the template and the record
    <TemplateField>[
      ...this.template.patientDetails,
      ...this.template.procedureDetails
    ].forEach(
      (TemplateField field) {
        Map<String, dynamic> fieldMap = {};

        if (field.mandatory) {
          switch (field.fieldKey) {
            case "procedureName":
              fieldMap["value"] = record?.procedureName;
              break;
            case "procedureCode":
              fieldMap["value"] = record?.procedureCode;
              break;
            case "dateOfProcedure":
              fieldMap["value"] = record?.dateOfProcedure;
              break;
            case "billedAmount":
              fieldMap["value"] = record?.billedAmount;
              break;
            case "paidAmount":
              fieldMap["value"] = record?.paidAmount;
              break;
            case "feeWaived?":
              fieldMap["value"] = record?.feeWaived;
              break;
          }
        } else {
          fieldMap["value"] = record?.customFields[field.fieldKey];
        }

        fieldMap["type"] = field.type;
        if (field.type == TemplateFieldType.Choice) {
          fieldMap["choices"] = field.choices;
          if (fieldMap["value"] == null) {
            fieldMap["value"] = field.choices?[0];
          }
        } else if (field.type == TemplateFieldType.String ||
            field.type == TemplateFieldType.LargeText ||
            field.type == TemplateFieldType.Number ||
            field.type == TemplateFieldType.Money) {
          fieldMap["controller"] = TextEditingController();
          (fieldMap["controller"] as TextEditingController).text =
              fieldMap["value"]?.toString() ?? '';
        } else if (field.type == TemplateFieldType.Timestamp) {
          fieldMap["controller"] = TextEditingController();
          if (fieldMap["value"] == null) {
            fieldMap["value"] = DateTime.now();
          }
          (fieldMap["controller"] as TextEditingController).text =
              "${fieldMap["value"]?.day}/${fieldMap["value"]?.month}/${fieldMap["value"]?.year}";
        } else if (field.type == TemplateFieldType.Array) {
          fieldMap["arrayType"] = field.arrayType;
        }

        fieldMap["name"] = field.fieldName;
        fieldMap["mandatory"] = field.mandatory;

        dataMap[field.fieldKey] = fieldMap;

        switch (field.category) {
          case TemplateFieldCategory.PatientDetails:
            this.patientFieldKeys.add(field.fieldKey);
            break;
          case TemplateFieldCategory.ProcedureDetails:
            this.procedureFieldKeys.add(field.fieldKey);
            break;
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Container(
              constraints: BoxConstraints(
                minHeight: 256.0,
                maxHeight: double.infinity,
              ),
              child: Stack(
                children: [
                  if (record != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.fileAlt,
                            size: 10.0,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 4.0,
                          ),
                          Text(
                            record?.rid ?? '',
                            style: TextStyle(
                              fontSize: 10.0,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 30.0),
                      _buildCategoryContainer(
                        category: TemplateFieldCategory.PatientDetails,
                        fieldKeys: this.patientFieldKeys,
                      ),
                      SizedBox(height: 16.0),
                      _buildCategoryContainer(
                        category: TemplateFieldCategory.ProcedureDetails,
                        fieldKeys: this.procedureFieldKeys,
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeleteButton(),
            _buildEditButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteButton() => this.record == null
      ? Container()
      : Container(
          child: IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    duration: Duration(seconds: 15),
                    action: SnackBarAction(label: 'Close', onPressed: () {}),
                    content: Text(
                      "⚠ Warning! You're about to delete a record! If you're sure about this operation long press on the delete button to delete the record! ⚠",
                    ),
                  ),
                );
            },
            icon: GestureDetector(
              onLongPress: () {
                Patient oldPatient = (context.read<ManagePatientBloc>().state
                        as ManagePatientLoadedState)
                    .patient;

                // ! Writing this dummy object to work around wrong null safety detections
                Record nullSafetyRecord = Record(
                  dateOfProcedure: this.dataMap["dateOfProcedure"]["value"],
                  procedureCode: this.dataMap["procedureCode"]["value"],
                  procedureName: this.dataMap["procedureName"]["value"],
                  feeWaived: this.dataMap["feeWaived?"]["value"],
                  paidAmount: this.dataMap["paidAmount"]["value"],
                  billedAmount: this.dataMap["billedAmount"]["value"],
                  pid: '',
                  rid: '',
                );

                context.read<ManagePatientBloc>().add(
                      DeleteRecordEvent(
                        oldPatient: oldPatient,
                        deletedRecord: this.record ?? nullSafetyRecord,
                      ),
                    );
              },
              child: FaIcon(FontAwesomeIcons.trash),
            ),
            color: Colors.red,
            tooltip: 'Delete Patient',
          ),
        );

  Widget _buildEditButton() => Container(
        child: IconButton(
          onPressed: () {
            setState(() {
              isEditing = !isEditing;
              if (!isEditing && updateRequired) {
                updateRequired = false;

                Map<String, dynamic> customFields = {};
                [...template.patientDetails, ...template.procedureDetails]
                    .forEach((field) {
                  if (!field.mandatory) {
                    if (this.dataMap[field.fieldKey]["value"] != null)
                      customFields[field.fieldKey] =
                          this.dataMap[field.fieldKey]["value"];
                  }
                });

                Patient oldPatient = (context.read<ManagePatientBloc>().state
                        as ManagePatientLoadedState)
                    .patient;

                if (this.record == null) {
                  // * New record to be inserted
                  Record newRecord = Record.create(
                    pid: oldPatient.pid,
                    dateOfProcedure: this.dataMap["dateOfProcedure"]["value"],
                    procedureCode: this.dataMap["procedureCode"]["value"],
                    procedureName: this.dataMap["procedureName"]["value"],
                    feeWaived: this.dataMap["feeWaived?"]["value"],
                    paidAmount: double.parse(
                      this.dataMap["paidAmount"]["value"],
                    ),
                    billedAmount: double.parse(
                      this.dataMap["billedAmount"]["value"],
                    ),
                    customFields: customFields,
                  );

                  context.read<ManagePatientBloc>().add(
                        CreateNewRecordEvent(
                          oldPatient: oldPatient,
                          newRecord: newRecord,
                        ),
                      );
                } else {
                  // * Update record

                  // ! Writing this dummy object to work around wrong null safety detections
                  Record nullSafetyRecord = Record(
                    dateOfProcedure: this.dataMap["dateOfProcedure"]["value"],
                    procedureCode: this.dataMap["procedureCode"]["value"],
                    procedureName: this.dataMap["procedureName"]["value"],
                    feeWaived: this.dataMap["feeWaived?"]["value"],
                    paidAmount: this.dataMap["paidAmount"]["value"],
                    billedAmount: this.dataMap["billedAmount"]["value"],
                    pid: '',
                    rid: '',
                  );

                  Record? updatedRecord = this.record?.copyWith(
                        dateOfProcedure: this.dataMap["dateOfProcedure"]
                            ["value"],
                        procedureCode: this.dataMap["procedureCode"]["value"],
                        procedureName: this.dataMap["procedureName"]["value"],
                        feeWaived: this.dataMap["feeWaived?"]["value"],
                        paidAmount: this.dataMap["paidAmount"]["value"],
                        billedAmount: this.dataMap["billedAmount"]["value"],
                        customFields: customFields,
                      );

                  context.read<ManagePatientBloc>().add(
                        UpdateRecordEvent(
                          oldPatient: oldPatient,
                          oldRecord: this.record ?? nullSafetyRecord,
                          updatedRecord: updatedRecord ?? nullSafetyRecord,
                        ),
                      );
                }
              }
            });
          },
          icon: FaIcon(
            isEditing ? FontAwesomeIcons.check : FontAwesomeIcons.edit,
          ),
          tooltip: isEditing ? 'Update' : 'Edit',
        ),
      );

  Widget _buildInfoText({required String value, required IconData icon}) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 10.0,
            color: Colors.grey,
          ),
          SizedBox(
            width: 4.0,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10.0,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      );

  void onChangedCallback(String key, String value) {
    setState(() {
      this.dataMap[key]["value"] = value;
      this.updateRequired = true;
    });
  }

  Widget _buildCategoryContainer({
    required TemplateFieldCategory category,
    required List<String> fieldKeys,
  }) =>
      Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[700] ?? Colors.grey,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: Stack(
          children: [
            Positioned(
              top: 15,
              left: 15,
              child: _buildInfoText(
                value: category.enumToString(),
                icon: FontAwesomeIcons.info,
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 26.0, horizontal: 26.0),
              margin: EdgeInsets.all(16.0),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Wrap(
                  runSpacing: 16.0,
                  spacing: 16.0,
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: fieldKeys.map<Widget>(
                    (key) {
                      TemplateFieldType fieldType = this.dataMap[key]["type"];

                      switch (fieldType) {
                        case TemplateFieldType.String:
                          return TextInputField(
                            label: this.dataMap[key]["name"],
                            onChangedCallback: (String value) =>
                                onChangedCallback(key, value),
                            controller: this.dataMap[key]["controller"],
                            isEditing: isEditing,
                            isMandatory: this.dataMap[key]["mandatory"],
                          );
                        case TemplateFieldType.LargeText:
                          return TextInputField(
                            label: this.dataMap[key]["name"],
                            onChangedCallback: (String value) =>
                                onChangedCallback(key, value),
                            controller: this.dataMap[key]["controller"],
                            isEditing: isEditing,
                            isLargeText: true,
                            isMandatory: this.dataMap[key]["mandatory"],
                          );
                        case TemplateFieldType.Number:
                          return TextInputField(
                            label: this.dataMap[key]["name"],
                            onChangedCallback: (String value) =>
                                onChangedCallback(key, value),
                            controller: this.dataMap[key]["controller"],
                            isEditing: isEditing,
                            isNumberOnly: true,
                            isMandatory: this.dataMap[key]["mandatory"],
                          );
                        case TemplateFieldType.Money:
                          return TextInputField(
                            label: this.dataMap[key]["name"],
                            onChangedCallback: (String value) =>
                                onChangedCallback(key, value),
                            controller: this.dataMap[key]["controller"],
                            isEditing: isEditing,
                            isNumberOnly: true,
                            isMoney: true,
                            isMandatory: this.dataMap[key]["mandatory"],
                          );
                        case TemplateFieldType.Choice:
                          return ChoicesDropdownField(
                            choices: this.dataMap[key]["choices"],
                            label: this.dataMap[key]["name"],
                            isEditing: isEditing,
                            onChangedCallback: (String? value) => setState(() {
                              this.dataMap[key]["value"] = value;
                              this.updateRequired = true;
                            }),
                            value: this.dataMap[key]["value"],
                          );
                        case TemplateFieldType.Array:
                          return ArrayTypeInput(
                            arrayType: this.dataMap[key]["arrayType"],
                            isEditable: isEditing,
                            label: this.dataMap[key]["name"],
                            onChangedCallback: (index, value) {
                              int valuesLength = 0;
                              List<String> values;
                              if (this.dataMap[key]["value"] == null) {
                                int valuesLength = 0;
                                values = [];
                              } else {
                                valuesLength =
                                    (this.dataMap[key]["value"] as List).length;
                                values = List.from(
                                  this.dataMap[key]["value"],
                                );
                              }

                              if (index == valuesLength) {
                                // * Index == length of array => new value
                                setState(() {
                                  values.add(value);
                                  this.dataMap[key]["value"] = values;
                                  this.updateRequired = true;
                                });
                              } else if (index < valuesLength) {
                                // * Index < length of array => update existing value
                                setState(() {
                                  values.removeAt(index);
                                  values.insert(index, value);
                                  this.dataMap[key]["value"] = values;
                                  this.updateRequired = true;
                                });
                              } else {
                                // * Not supposed to happen! Something went wrong
                              }
                            },
                            values: List.from(this.dataMap[key]["value"] ?? []),
                          );
                        case TemplateFieldType.Timestamp:
                          return DatePickerField(
                            controller: this.dataMap[key]["controller"],
                            label: this.dataMap[key]["name"],
                            isEditing: isEditing,
                            isMandatory: this.dataMap[key]["mandatory"],
                            onChangedCallback: (date) {
                              if (date != null)
                                setState(() {
                                  this.dataMap[key]["value"] = date;
                                  (this.dataMap[key]["controller"]
                                              as TextEditingController)
                                          .text =
                                      "${date.day}/${date.month}/${date.year}";
                                  this.updateRequired = true;
                                });
                            },
                          );
                        // TODO :  Implement!
                        case TemplateFieldType.Media:
                          return Container();
                      }
                    },
                  ).toList(),
                ),
              ),
            ),
          ],
        ),
      );
}
