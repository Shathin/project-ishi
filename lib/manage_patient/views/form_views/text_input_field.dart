import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TextInputField extends StatelessWidget {
  final String label;
  final Function(String) onChangedCallback;
  final bool isNumberOnly;
  final bool isMoney;
  final bool isLargeText;
  final bool isEditing;
  final TextEditingController controller;
  late final InputDecoration decoration;
  final bool isDense;
  final bool isMandatory;

  TextInputField({
    required this.label,
    required this.onChangedCallback,
    required this.controller,
    this.isLargeText = false,
    this.isMoney = false,
    this.isNumberOnly = false,
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
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: isLargeText
            ? 256.0
            : this.isDense
                ? 100
                : 100.0,
        maxWidth: isLargeText
            ? 512
            : this.isDense
                ? 128
                : 256.0,
      ),
      child: TextFormField(
        validator: this.isMandatory
            ? (value) => value != null && !value.isEmpty && value.length > 0
                ? null
                : 'This field is required!'
            : null,
        maxLines: isLargeText ? 8 : 2,
        minLines: 1,
        enabled: this.isEditing,
        // TODO : Write a proper input formatter for number & money type fields
        controller: this.controller,
        onChanged: onChangedCallback,
        decoration: this.decoration.copyWith(
              icon: this.isDense
                  ? null
                  : isMoney
                      ? FaIcon(
                          FontAwesomeIcons.rupeeSign,
                          size: 16.0,
                          color: Colors.green[500],
                        )
                      : FaIcon(
                          FontAwesomeIcons.keyboard,
                          size: 16.0,
                        ),
              labelText: label,
            ),
      ),
    );
  }
}
