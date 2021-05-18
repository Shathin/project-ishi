import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';
import 'package:project_ishi/manage_patient/views/form_views/date_picker_field.dart';
import 'package:project_ishi/manage_patient/views/form_views/text_input_field.dart';

class ArrayTypeInput extends StatelessWidget {
  final void Function(int, String) onChangedCallback;
  final bool isEditable;
  final String label;
  final TemplateFieldArrayType arrayType;
  final List<String> values;

  ArrayTypeInput({
    required this.arrayType,
    required this.isEditable,
    required this.label,
    required this.onChangedCallback,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    switch (this.arrayType) {
      case TemplateFieldArrayType.Number:
      case TemplateFieldArrayType.String:
        for (int iter = 0; iter < this.values.length; iter++) {
          children.add(
            TextInputField(
              label: '',
              onChangedCallback: (String value) {
                onChangedCallback(iter, value);
              },
              controller: TextEditingController()..text = values[iter],
              isDense: true,
              isEditing: isEditable,
            ),
          );
        }
        if (this.isEditable)
          children.add(
            TextInputField(
              label: 'New',
              onChangedCallback: (String value) {
                onChangedCallback(this.values.length, value);
              },
              controller: TextEditingController(),
              isDense: true,
              isEditing: isEditable,
            ),
          );
        break;
      case TemplateFieldArrayType.Timestamp:
        // * Date => ISO String
        for (int iter = 0; iter < values.length; iter++) {
          DateTime? parsedDate = DateTime.tryParse(values[iter]);
          children.add(
            DatePickerField(
              onChangedCallback: (DateTime? dateTime) {
                if (dateTime != null)
                  onChangedCallback(iter, dateTime.toIso8601String());
              },
              label: '',
              controller: TextEditingController()
                ..text =
                    "${parsedDate?.day}/${parsedDate?.month}/${parsedDate?.year}",
              isDense: true,
              isEditing: isEditable,
            ),
          );
        }

        if (this.isEditable)
          children.add(
            DatePickerField(
              onChangedCallback: (DateTime? dateTime) {
                if (dateTime != null)
                  onChangedCallback(
                    this.values.length,
                    dateTime.toIso8601String(),
                  );
              },
              label: 'New',
              controller: TextEditingController(),
              isDense: true,
              isEditing: isEditable,
            ),
          );
        break;
    }

    return Container(
      child: Wrap(
        spacing: 4.0,
        runSpacing: 8.0,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.center,
        children: [
          Text(label),
          SizedBox(width: 8),
          ...children,
        ],
      ),
    );
  }
}
