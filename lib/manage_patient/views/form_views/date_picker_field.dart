import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DatePickerField extends StatelessWidget {
  final void Function(DateTime?) onChangedCallback;
  final String label;
  final TextEditingController controller;
  late final InputDecoration decoration;
  final bool isEditing;
  final bool isDense;
  final bool isMandatory;

  DatePickerField({
    required this.onChangedCallback,
    required this.label,
    required this.controller,
    this.isEditing = false,
    this.isDense = false,
    this.isMandatory = false,
    InputDecoration? decoration,
  }) : this.decoration = decoration ??
            InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 16.0,
              ),
              filled: true,
            );

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: this.isEditing
            ? () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1997),
                  lastDate: DateTime(2100),
                ).then(this.onChangedCallback);
              }
            : null,
        child: Container(
          constraints: BoxConstraints(
            minWidth: 100.0,
            maxWidth: this.isDense ? 128 : 256.0,
          ),
          child: TextFormField(
            validator: this.isMandatory
                ? (value) => value != null && !value.isEmpty && value.length > 0
                    ? null
                    : 'This field is required!'
                : null,
            controller: this.controller,
            enabled: false,
            decoration: this.decoration.copyWith(
                  icon: this.isDense
                      ? null
                      : FaIcon(
                          FontAwesomeIcons.calendar,
                          size: 16.0,
                        ),
                  labelText: this.label,
                ),
          ),
        ),
      );
}
