import 'package:database_repo/patients_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/manage_template/bloc/template_bloc.dart';
import '../bloc/patients_bloc.dart';

class AddPatientDialog extends StatefulWidget {
  BuildContext blocContext;
  Patient? patient;

  AddPatientDialog({this.patient, required this.blocContext});

  @override
  _AddPatientDialogState createState() => _AddPatientDialogState();
}

class _AddPatientDialogState extends State<AddPatientDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  Gender gender = Gender.PreferNotToSay;
  String? name;
  int? age;

  @override
  void initState() {
    if (widget.patient != null) {
      gender = widget.patient?.gender ?? gender;
      name = widget.patient?.name;
      age = widget.patient?.age;

      if (name != null) nameController.text = name ?? '';
      if (age != null) ageController.text = age.toString();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            widget.patient == null ? 'Add new patient' : 'Update patient',
          ),
          content: Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(8.0),
            width: 512.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildNameInputField(),
                const SizedBox(height: 32.0),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: _buildAgeInputField(),
                    ),
                    Expanded(
                      child: _buildGenderDropdown(),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameInputField() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 32.0),
              child: Text('Patient Name'),
            ),
            Expanded(
              child: TextField(
                controller: nameController,
                onChanged: (input) {
                  setState(() {
                    name = input;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Patient Name",
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

  Widget _buildAgeInputField() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 32.0),
              child: Text('Age'),
            ),
            Expanded(
              child: TextField(
                controller: ageController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[0-9]'),
                    replacementString: '0',
                  ),
                ],
                onChanged: (input) {
                  setState(() {
                    age = int.parse(input);
                  });
                },
                decoration: InputDecoration(
                  labelText: "Patient's Age",
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

  Widget _buildGenderDropdown() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('Gender'),
            ),
            DropdownButton<Gender>(
              items: Gender.values.map<DropdownMenuItem<Gender>>((gen) {
                return DropdownMenuItem<Gender>(
                  value: gen,
                  child: Text(
                    gen.enumToString(),
                  ),
                );
              }).toList(),
              value: gender,
              onChanged: (value) {
                setState(() {
                  gender = value ?? gender;
                });
              },
              hint: Text("Gender"),
            ),
          ],
        ),
      );

  final TextStyle buttonTextStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );

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

  Widget _buildSubmitButton() => ElevatedButton.icon(
        onPressed: name == null || (name?.isEmpty ?? true)
            ? null
            : () {
                if (widget.patient == null) {
                  // * Create new patient
                  Patient newPatient = Patient.create(
                    name: name ?? '',
                    age: age,
                    gender: gender,
                  );

                  widget.blocContext
                      .read<PatientsBloc>()
                      .add(CreateNewPatientEvent(patient: newPatient));
                } else {
                  // * Update patient
                  Patient updatedPatient = Patient(
                    name: name ?? '',
                    age: age,
                    gender: gender,
                    recordReferences: widget.patient?.recordReferences ?? [],
                    pid: widget.patient?.pid ?? '',
                  );

                  widget.blocContext.read<PatientsBloc>().add(
                        UpdatePatientEvent(
                          oldPatient: widget.patient ?? updatedPatient,
                          updatedPatient: updatedPatient,
                        ),
                      );
                }

                Navigator.of(context).pop();
              },
        label: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.patient == null ? "Create" : "Update",
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
}
