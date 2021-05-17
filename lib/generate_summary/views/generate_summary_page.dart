import 'dart:io';

import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';
import 'package:database_repo/utils.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/generate_summary/cubit/generate_summary_cubit.dart';

class GenerateSummaryPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => GenerateSummary());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepositoryProvider(
        create: (context) => SpreadsheetGenerator(
          templateRepo: context.read<TemplateRepo>(),
          recordsRepo: context.read<RecordsRepo>(),
          patientsRepo: context.read<PatientsRepo>(),
        ),
        child: GenerateSummary(),
      ),
    );
  }
}

class GenerateSummary extends StatefulWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => GenerateSummary());

  @override
  _GenerateSummaryState createState() => _GenerateSummaryState();
}

class _GenerateSummaryState extends State<GenerateSummary> {
  /* 
  *  fieldKey : {
  *    fieldName: "Field Name",
  *    selected: bool,
  *  }
  */
  final Map<String, Map<String, dynamic>> selectedFields = {};

  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();

  DateTime? start, end;

  bool isDataLoaded = false;

  @override
  void initState() {
    // * Read template from the database a prepare the [selectedField] map
    context.read<TemplateRepo>().readTemplate().then((template) {
      [...template.patientDetails, ...template.procedureDetails]
          .forEach((field) {
        selectedFields[field.fieldKey] = {
          "fieldName": field.fieldName,
          "type": field.type.enumToString(),
          "selected": false,
        };
      });

      setState(() {
        isDataLoaded = true;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isDataLoaded
        ? BlocProvider(
            create: (_) => GenerateSummaryCubit(),
            child: BlocConsumer<GenerateSummaryCubit, GenerateSummaryState>(
              listenWhen: (previous, current) => previous.status ==
                          GenerateSummaryStatus.genInProgress &&
                      (current.status == GenerateSummaryStatus.genComplete ||
                          current.status == GenerateSummaryStatus.genFailed)
                  ? true
                  : false,
              listener: (context, state) {
                if (state.status == GenerateSummaryStatus.genComplete)
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          "✔ Your spreadsheet has been successfully generated!",
                        ),
                      ),
                    );
                else {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          "❌ Spreadsheet generation has failed! Make sure that you have records to use for the spreadsheet! ",
                        ),
                      ),
                    );
                }
              },
              builder: (context, state) =>
                  state.status == GenerateSummaryStatus.genInProgress
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 32.0),
                              Text(
                                'Please wait while the spreadsheet is being generated!',
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'Please do not navigate away from the page! ⚠',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          ),
                        )
                      : _buildGenerateSummaryForm(context),
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget _buildDateSearch() {
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

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.0, bottom: 32.0),
            child: Text(
              'Select Date Range',
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Row(
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
        ],
      ),
    );
  }

  Widget _buiildFieldSelection() {
    return Container(
      child: Wrap(
        alignment: WrapAlignment.center,
        runSpacing: 8.0,
        spacing: 8.0,
        children: selectedFields.keys
            .map<Widget>(
              (fieldKey) => ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 512.0),
                child: SizedBox(
                  width: 256.0,
                  child: CheckboxListTile(
                    title: Text(
                      selectedFields[fieldKey]?["fieldName"],
                    ),
                    activeColor: Colors.green[700],
                    subtitle: Text(
                      selectedFields[fieldKey]?["type"],
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    value: selectedFields[fieldKey]?["selected"],
                    onChanged: (value) {
                      setState(() {
                        selectedFields[fieldKey]?["selected"] =
                            !selectedFields[fieldKey]?["selected"];
                      });
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        List<String> fields = [];
        for (String fieldKey in selectedFields.keys) {
          if (selectedFields[fieldKey]?["selected"]) fields.add(fieldKey);
        }

        context.read<GenerateSummaryCubit>().operationGenSummary();

        bool success = await context
            .read<SpreadsheetGenerator>()
            .generateSpreadsheetForDateRange(
              fieldNames: fields,
              start: start,
              end: end,
            );
        if (success)
          context.read<GenerateSummaryCubit>().operationGenSummaryComplete();
        else
          context.read<GenerateSummaryCubit>().operationGenSummaryFailed();
      },
      label: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Generate Spreadsheet',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
      icon: FaIcon(FontAwesomeIcons.fileExcel),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) => Colors.green,
        ),
      ),
    );
  }

  Widget _buildGenerateSummaryForm(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      padding: EdgeInsets.all(32.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Generate Summary',
            style: Theme.of(context).textTheme.headline2,
          ),
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ! Choose Fields
                  Card(
                    child: _buiildFieldSelection(),
                  ),
                  // ! Date Picker
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildDateSearch(),
                    ),
                  ),
                  // ! Submit Button
                  _buildSubmitButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
