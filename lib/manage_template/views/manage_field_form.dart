import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';

// ! Third party libraries
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/manage_template/bloc/template_bloc.dart';

class ManageFieldForm extends StatefulWidget {
  final TemplateField? templateField;
  final BuildContext blocContext;

  ManageFieldForm({
    this.templateField,
    required this.blocContext,
  });

  @override
  _ManageFieldFormState createState() => _ManageFieldFormState();
}

class _ManageFieldFormState extends State<ManageFieldForm> {
  TemplateFieldCategory category = TemplateFieldCategory.PatientDetails;
  TemplateFieldType type = TemplateFieldType.String;
  TemplateFieldArrayType? arrayType;
  String? fieldName;
  List<String>? choices;
  int? sequence;

  final TextEditingController fieldNameController = TextEditingController();
  final TextEditingController choicesController = TextEditingController();

  @override
  void initState() {
    if (widget.templateField != null) {
      category = widget.templateField?.category ?? category;
      type = widget.templateField?.type ?? type;
      fieldName = widget.templateField?.fieldName;
      sequence = widget.templateField?.sequence;

      if (widget.templateField?.type == TemplateFieldType.Choice)
        choices = widget.templateField?.choices;
      else if (widget.templateField?.type == TemplateFieldType.Array)
        arrayType = widget.templateField?.arrayType;

      if (fieldName != null) fieldNameController.text = fieldName ?? '';
      if (choices != null) choicesController.text = choices?.join(',') ?? '';
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (sequence == null)
      sequence =
          (widget.blocContext.read<TemplateBloc>().state as TemplateLoadedState)
                  .template
                  .patientDetails
                  .length +
              1;
    return Center(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: AlertDialog(
          actions: [
            _buildCancelButton(),
            _buildSubmitButton(),
          ],
          actionsPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          title: Text(
            widget.templateField == null ? "Create New Field" : "Edit Field",
          ),
          content: Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(8.0),
            width: 512.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldCategoryInput(),
                    _buildFieldTypeInput(),
                  ],
                ),
                const SizedBox(height: 16.0),
                _buildFieldNameInput(),
                if (type == TemplateFieldType.Choice) ...[
                  const SizedBox(height: 16.0),
                  _buildChoicesInput(),
                ],
                if (type == TemplateFieldType.Array) ...[
                  const SizedBox(height: 16.0),
                  _buildArrayTypeInput(),
                ],
                const SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final TextStyle buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  /// Cancel action button
  Widget _buildCancelButton() => ElevatedButton.icon(
        onPressed: () async {
          Navigator.of(context).pop();
        },
        label: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Cancel',
            style: buttonTextStyle,
          ),
        ),
        icon: FaIcon(FontAwesomeIcons.times),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => Colors.red,
          ),
        ),
      );

  // TODO : Required much more stringent test on the 'choices' input field
  bool isFormValid() {
    if (fieldName?.isEmpty ?? true) return false;

    if (type == TemplateFieldType.Choice &&
        (choices == null || choicesController.text.length == 0)) return false;
    if (type == TemplateFieldType.Array && arrayType == null) return false;

    return true;
  }

  /// Submit action button
  Widget _buildSubmitButton() => ElevatedButton.icon(
        onPressed: isFormValid()
            ? () async {
                Navigator.of(context).pop();
                TemplateField field =
                    TemplateField.mapToObject(templateFieldMap: {
                  "category": category.enumToString(),
                  "name": fieldName,
                  "type": type.enumToString(),
                  "sequence": sequence,
                  "choices": choices,
                  "arrayType": arrayType?.enumToString(),
                });
                if (widget.templateField == null) {
                  // * Create New Field
                  widget.blocContext.read<TemplateBloc>().add(
                        CreateNewTemplateFieldEvent(newField: field),
                      );
                } else {
                  // * Update new Field
                  widget.blocContext
                      .read<TemplateBloc>()
                      .add(UpdateTemplateFieldEvent(
                        oldField: widget.templateField ??
                            field, // Unnecessary null check because it can't seem to detect the above [if] condition
                        updatedField: field,
                      ));
                }
              }
            : null,
        label: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.templateField == null ? "Create" : "Update",
            style: buttonTextStyle,
          ),
        ),
        icon: FaIcon(FontAwesomeIcons.check),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) => Colors.green,
          ),
        ),
      );

  /// Dropdown input field for field's category
  Widget _buildFieldCategoryInput() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Category'),
            ),
            DropdownButton<TemplateFieldCategory>(
              items: TemplateFieldCategory.values
                  .map<DropdownMenuItem<TemplateFieldCategory>>((category) {
                return DropdownMenuItem<TemplateFieldCategory>(
                  value: category,
                  child: Text(
                    category.enumToString(),
                  ),
                );
              }).toList(),
              value: category,
              onChanged: (value) {
                setState(() {
                  category = value ?? category;

                  //* Compute largest sequence number
                  Template template = (widget.blocContext
                          .read<TemplateBloc>()
                          .state as TemplateLoadedState)
                      .template;
                  if (category == TemplateFieldCategory.PatientDetails) {
                    sequence = template.patientDetails.length + 1;
                  } else {
                    sequence = template.procedureDetails.length + 1;
                  }
                });
              },
              hint: Text("Category"),
            ),
          ],
        ),
      );

  /// Input widget for entering field name
  Widget _buildFieldNameInput() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 32.0),
              child: Text('Field Name'),
            ),
            Expanded(
              child: TextField(
                controller: fieldNameController,
                onChanged: (input) {
                  setState(() {
                    fieldName = input;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Field Name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  filled: true,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildFieldTypeInput() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Field Type'),
            ),
            DropdownButton<TemplateFieldType>(
              items: TemplateFieldType.values
                  .map<DropdownMenuItem<TemplateFieldType>>((fieldType) {
                return DropdownMenuItem<TemplateFieldType>(
                  value: fieldType,
                  child: Text(
                    fieldType.enumToString(),
                  ),
                );
              }).toList(),
              value: type,
              onChanged: (value) {
                setState(() {
                  type = value ?? type;
                });
              },
              hint: Text("Field Type"),
            ),
          ],
        ),
      );

  /// Represents the input field to get the
  Widget _buildChoicesInput() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 60.0),
              child: Text('Choices'),
            ),
            Expanded(
              child: TextField(
                controller: choicesController,
                onChanged: (input) {
                  setState(() {
                    choices = List<String>.from(input.split(','));
                  });
                },
                decoration: InputDecoration(
                  labelText: "Choices",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  filled: true,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildArrayTypeInput() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Field Type'),
            ),
            DropdownButton<TemplateFieldArrayType>(
              items: TemplateFieldArrayType.values
                  .map<DropdownMenuItem<TemplateFieldArrayType>>((arrayType) {
                return DropdownMenuItem<TemplateFieldArrayType>(
                  value: arrayType,
                  child: Text(
                    arrayType.enumToString(),
                  ),
                );
              }).toList(),
              value: arrayType,
              onChanged: (value) {
                setState(() {
                  arrayType = value;
                });
              },
              hint: Text("Array Type"),
            ),
          ],
        ),
      );
}
