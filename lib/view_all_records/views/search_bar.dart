import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/view_all_records/bloc/records_bloc.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  Template? template;

  final TextEditingController stringSearchController = TextEditingController();
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  final FocusNode stringSearchFocusNode = FocusNode();

  DateTime? start, end;

  TemplateField? searchField;

  @override
  void initState() {
    context.read<TemplateRepo>().readTemplate().then((value) {
      setState(() {
        template = value;
        searchField = template?.procedureDetails[0];
      });
    });
    super.initState();
  }

  Widget _buildSearchTypeDropdown() {
    return DropdownButton<TemplateField>(
      items: [
        ...template?.patientDetails ?? <TemplateField>[],
        ...template?.procedureDetails ?? <TemplateField>[],
      ]
          .map<DropdownMenuItem<TemplateField>>(
            (TemplateField field) => DropdownMenuItem<TemplateField>(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    field.fieldName,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    '(${field.type.enumToString()})',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              value: field,
            ),
          )
          .toList(),
      value: searchField,
      onChanged: (field) {
        setState(() {
          searchField = field ?? searchField;
          stringSearchController.clear();
          context.read<RecordsBloc>().add(LoadAllRecordsEvent());
        });
      },
    );
  }

  Widget _buildStringSearch({
    bool isNumberOnly = false,
    required TemplateField? searchField,
  }) {
    if (searchField == null) return Container();
    return TextField(
      controller: stringSearchController,
      inputFormatters: isNumberOnly
          ? <TextInputFormatter>[
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9]'),
                replacementString: '0',
              ),
            ]
          : [],
      autofocus: true,
      focusNode: stringSearchFocusNode,
      onChanged: (searchString) {
        searchString.isEmpty
            ? context.read<RecordsBloc>().add(
                  LoadAllRecordsEvent(
                    sortByDateOfProcedure: true,
                  ),
                )
            : context.read<RecordsBloc>().add(
                  LoadRecordsByKeyValue(
                    fieldKey: searchField.fieldKey,
                    fieldType: searchField.type,
                    fieldValue: stringSearchController.text,
                    sortByDateOfProcedure: true,
                  ),
                );
      },
      keyboardType: isNumberOnly ? TextInputType.number : null,
      decoration: InputDecoration(
        icon: FaIcon(FontAwesomeIcons.search),
        labelText: 'Search records by ${searchField.fieldName}',
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
    );
  }

  Widget _buildDateSearch({bool onlyStartDate = false}) {
    final double textFieldWidth = 180.0;
    final InputDecoration textFieldDecoration = InputDecoration(
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

    if (start != null)
      startController.text = "${start?.day}/${start?.month}/${start?.year}";

    if (end != null)
      endController.text = "${end?.day}/${end?.month}/${end?.year}";

    if (searchField == null) return Container();
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Choose Start Date: '),
          SizedBox(width: 16.0),
          InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1997),
                lastDate: DateTime(2100),
              ).then((date) {
                setState(() {
                  start = date;

                  if (onlyStartDate) {
                    context.read<RecordsBloc>().add(
                          LoadRecordsByKeyValue(
                            fieldKey: searchField?.fieldKey ?? '',
                            fieldType: searchField?.type ??
                                TemplateFieldType.Timestamp,
                            fieldValue: start,
                            sortByDateOfProcedure: true,
                          ),
                        );
                  } else {
                    if (start != null &&
                        end != null &&
                        searchField?.fieldKey == "dateOfProcedure") {
                      context
                          .read<RecordsBloc>()
                          .add(LoadRecordsBetweenDateRange(
                            start: start ?? DateTime.now(),
                            end: end ?? DateTime.now(),
                            sortByDateOfProcedure: true,
                          ));
                    }
                  }
                });
              });
            },
            child: Container(
              width: textFieldWidth,
              child: TextField(
                controller: startController,
                enabled: false,
                decoration: textFieldDecoration,
              ),
            ),
          ),
          SizedBox(width: 36.0),
          Text('Choose End Date: '),
          SizedBox(width: 16.0),
          InkWell(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1997),
                lastDate: DateTime(2100),
              ).then((date) {
                setState(() {
                  end = date;

                  if (start != null &&
                      end != null &&
                      searchField?.fieldKey == "dateOfProcedure") {
                    context.read<RecordsBloc>().add(LoadRecordsBetweenDateRange(
                          start: start ?? DateTime.now(),
                          end: end ?? DateTime.now(),
                          sortByDateOfProcedure: true,
                        ));
                  }
                });
              });
            },
            child: Container(
              width: textFieldWidth,
              child: TextField(
                controller: endController,
                enabled: false,
                decoration: textFieldDecoration,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget searchBox;
    switch (searchField?.type) {
      case TemplateFieldType.String:
      case TemplateFieldType.LargeText:
      case TemplateFieldType.Choice:
        searchBox = _buildStringSearch(
          searchField: this.searchField,
        );
        break;
      case TemplateFieldType.Number:
      case TemplateFieldType.Money:
        searchBox = _buildStringSearch(
          searchField: this.searchField,
          isNumberOnly: true,
        );
        break;
      case TemplateFieldType.Timestamp:
        if (searchField?.fieldKey == "dateOfProcedure")
          searchBox = _buildDateSearch();
        else
          searchBox = _buildDateSearch(onlyStartDate: true);
        break;
      case TemplateFieldType.Array:
      case TemplateFieldType.Media:
        searchBox = Container(
          child: Text(
            "We're sorry! ☹ Searching for this field has not been implemented yet!",
          ),
        );
        break;
      default:
        searchBox = Container();
    }

    return template == null
        ? Container()
        : Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              top: 36.0,
              bottom: 16,
              left: 24.0,
              right: 24.0,
            ),
            alignment: Alignment.center,
            child: Row(
              children: <Widget>[
                Text('Search by: '),
                SizedBox(width: 8.0),
                _buildSearchTypeDropdown(),
                SizedBox(width: 32.0),
                Expanded(child: searchBox),
              ],
            ),
          );
  }
}
