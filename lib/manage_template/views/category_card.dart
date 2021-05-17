import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/manage_template/bloc/template_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'manage_field_form.dart';

class CategoryCard extends StatefulWidget {
  List<TemplateField> fields;

  CategoryCard({required this.fields});

  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 512.0,
        height: 512.0,
        padding: EdgeInsets.all(16.0),
        child: ReorderableListView.builder(
          onReorder: reorderFields,
          itemBuilder: (context, index) => ListTile(
            key: Key('$index'),
            title: Text(widget.fields[index].fieldName),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.edit),
                  onPressed: widget.fields[index].mandatory
                      ? null
                      : () => showDialog(
                            context: context,
                            builder: (_) => ManageFieldForm(
                              blocContext: context,
                              templateField: widget.fields[index],
                            ),
                          ),
                  mouseCursor: widget.fields[index].mandatory
                      ? SystemMouseCursors.forbidden
                      : SystemMouseCursors.click,
                  tooltip: widget.fields[index].mandatory
                      ? "Mandatory field! Editing not allowed"
                      : "Edit field",
                ),
                SizedBox(width: 16.0),
                IconButton(
                  icon: FaIcon(FontAwesomeIcons.trash),
                  onPressed: widget.fields[index].mandatory
                      ? null
                      : () {
                          context.read<TemplateBloc>().add(
                                DeleteTemplateFieldEvent(
                                    deletedField: widget.fields[index]),
                              );
                        },
                  mouseCursor: widget.fields[index].mandatory
                      ? SystemMouseCursors.forbidden
                      : SystemMouseCursors.click,
                  tooltip: widget.fields[index].mandatory
                      ? "Mandatory field! Deleting not allowed"
                      : "Delete field",
                ),
              ],
            ),
            subtitle: Text(
              widget.fields[index].type.enumToString() +
                  " " +
                  (widget.fields[index].type == TemplateFieldType.Choice
                      ? widget.fields[index].choices.toString()
                      : widget.fields[index].type == TemplateFieldType.Array
                          ? "[${widget.fields[index].arrayType?.enumToString()}]"
                          : ""),
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
                fontSize: 12.0,
              ),
            ),
          ),
          itemCount: widget.fields.length,
          physics: BouncingScrollPhysics(),
        ),
      ),
    );
  }

  /// The method called by [ReorderableListView] when the user drags an item on the list and reorders it
  void reorderFields(int oldIndex, int newIndex) {
    TemplateField selectedOldField = widget.fields[oldIndex];
    TemplateField? selectedUpdatedField;

    // * While moving an item from position x (at index x-1) to position y (index y-1) the oldIndex will be x-1 and the newIndex will be y
    // * Hence separate handling is required
    if (oldIndex < newIndex) {
      // ! Field was moved down the list!
      for (int iter = oldIndex; iter < newIndex; iter++) {
        final TemplateField fieldAtIter = widget.fields[iter];
        TemplateField? updatedField;

        // * The item that was selected for reorder is at [oldIndex]
        if (iter == oldIndex) {
          updatedField = selectedOldField.copyWith(
            sequence: newIndex,
          );
          selectedUpdatedField = updatedField.copyWith();
        } else
          updatedField = fieldAtIter.copyWith(
            sequence: fieldAtIter.sequence - 1,
          );

        widget.fields.remove(widget.fields[iter]);
        widget.fields.insert(iter, updatedField);
      }
    } else if (oldIndex > newIndex) {
      for (int iter = newIndex; iter <= oldIndex; iter++) {
        final TemplateField fieldAtIter = widget.fields[iter];
        TemplateField? updatedField;

        // * The item that was selected for reorder is at [oldIndex]
        if (iter == oldIndex) {
          updatedField = selectedOldField.copyWith(
            sequence: newIndex + 1,
          );
          selectedUpdatedField = updatedField.copyWith();
        } else
          updatedField = fieldAtIter.copyWith(
            sequence: fieldAtIter.sequence + 1,
          );

        widget.fields.remove(widget.fields[iter]);
        widget.fields.insert(iter, updatedField);
      }
    }

    if (selectedUpdatedField != null) {
      // * Fetch current [Template] object
      Template currentTemplate =
          (context.read<TemplateBloc>().state as TemplateLoadedState).template;

      // * Locally updated [Template] to avoid reloading the template from the DB
      Template updatedTemplate =
          widget.fields[0].category == TemplateFieldCategory.PatientDetails
              ? currentTemplate.copyWith(
                  patientDetails: widget.fields,
                )
              : currentTemplate.copyWith(
                  procedureDetails: widget.fields,
                );

      // * Add the [ReorderTemplateFieldEvent] to request DB operation
      context.read<TemplateBloc>().add(
            ReorderTemplateFieldEvent(
              oldField: selectedOldField,
              updatedField: selectedUpdatedField,
              updatedTemplate: updatedTemplate,
            ),
          );

      setState(() {
        widget.fields.sort(
            (fieldA, fieldB) => fieldA.sequence.compareTo(fieldB.sequence));
      });
    }
  }
}
