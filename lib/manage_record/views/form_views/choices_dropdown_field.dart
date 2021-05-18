import 'package:flutter/material.dart';

class ChoicesDropdownField extends StatelessWidget {
  final List<String> choices;
  final void Function(String?) onChangedCallback;
  final String? value;
  final bool isEditing;
  final String label;

  ChoicesDropdownField({
    required this.choices,
    required this.onChangedCallback,
    required this.label,
    this.value,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(
          minWidth: 100.0,
          maxWidth: 256.0,
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(this.label),
            ),
            DropdownButton<String>(
              items: this.choices.map<DropdownMenuItem<String>>((choice) {
                return DropdownMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList(),
              value: this.value ?? this.choices[0],
              onChanged: isEditing ? onChangedCallback : null,
              hint: Text(this.label),
              disabledHint: Text(
                this.value ?? '',
              ),
            ),
          ],
        ),
      );
}
