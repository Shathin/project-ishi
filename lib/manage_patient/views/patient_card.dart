import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:database_repo/patients_repo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../bloc/manage_patient_bloc.dart';

class PatientCard extends StatefulWidget {
  final Patient patient;

  PatientCard({required this.patient});

  @override
  _PatientCardState createState() => _PatientCardState();
}

class _PatientCardState extends State<PatientCard> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  Gender gender = Gender.PreferNotToSay;
  String name = '';
  int? age;

  bool isEditing = false;
  bool updateRequired = false;

  @override
  void initState() {
    gender = widget.patient.gender;
    name = widget.patient.name;
    age = widget.patient.age;

    nameController.text = name;
    ageController.text = age == null ? 'N/A' : age.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildInfoText(
                        value: widget.patient.pid,
                        icon: FontAwesomeIcons.user,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _buildInfoText(
                        value: 'Patient Information',
                        icon: FontAwesomeIcons.infoCircle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0),
                      child: Wrap(
                        runSpacing: 16.0,
                        spacing: 32.0,
                        runAlignment: WrapAlignment.center,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildNameInputField(),
                          _buildAgeInputField(),
                          _buildGenderDropdown(),
                          _buildRecordCountText(
                            value: widget.patient.recordReferences.length
                                .toString(),
                          ),
                        ],
                      ),
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
      ),
    );
  }

  Widget _buildDeleteButton() => Container(
        child: IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 15),
                  action: SnackBarAction(
                    label: 'Close',
                    onPressed: () {},
                  ),
                  content: Text(
                    "⚠ Warning! You're about to delete a patient and all their associated records! If you're sure about this operation long press on the delete button to delete the patient! ⚠",
                  ),
                ),
              );
          },
          icon: GestureDetector(
            onLongPress: () {
              context.read<ManagePatientBloc>().add(
                    DeletePatientEvent(
                      deletedPatient: widget.patient,
                      deletedRecords: (context.read<ManagePatientBloc>().state
                              as ManagePatientLoadedState)
                          .records,
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

              if (isEditing) {
                // * The button is currently "Update" (switched from "Edit")
                ageController.text = age == null ? '' : age.toString();
              } else {
                // * The button is currently "Edit" (switched from "Update")
                ageController.text = age == null ? 'N/A' : age.toString();

                // ! Perform update action if required
                if (updateRequired) {
                  Patient updatedPatient = widget.patient.copyWith(
                    name: name,
                    age: age,
                    gender: gender,
                  );

                  // * Perform update call
                  context.read<ManagePatientBloc>().add(
                        UpdatePatientEvent(
                          oldRecords: (context.read<ManagePatientBloc>().state
                                  as ManagePatientLoadedState)
                              .records, // Fetch the records from the state
                          oldPatient: widget.patient,
                          updatedPatient: updatedPatient,
                        ),
                      );

                  updateRequired = false;
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

  Widget _buildRecordCountText({
    required String value,
  }) =>
      Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Record Count:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8.0),
            Text(value),
          ],
        ),
      );

  Widget _buildNameInputField() => Container(
        constraints: BoxConstraints(
          minWidth: 200.0,
          maxWidth: 256.0,
        ),
        child:
            /*Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 32.0),
              child: Text('Patient Name'),
            ),
            Expanded(
              child:*/
            TextField(
          enabled: isEditing,
          controller: nameController,
          onChanged: (input) {
            setState(() {
              updateRequired = true;
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
        //     ),
        //   ],
        // ),
      );

  Widget _buildAgeInputField() => Container(
        constraints: BoxConstraints(
          minWidth: 200.0,
          maxWidth: 200.0,
        ),
        child:
            /* Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 32.0),
              child: Text('Age'),
            ),
            Expanded(
              child: */
            TextField(
          enabled: isEditing,
          controller: ageController,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(
              RegExp(r'[0-9]'),
              replacementString: '0',
            ),
          ],
          onChanged: (input) {
            setState(() {
              updateRequired = true;
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
        //     ),
        //   ],
        // ),
      );

  Widget _buildGenderDropdown() => Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
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
              onChanged: isEditing
                  ? (value) {
                      setState(() {
                        updateRequired = true;
                        gender = value ?? gender;
                      });
                    }
                  : null,
              hint: Text("Gender"),
              disabledHint: Text(gender.enumToString()),
            ),
          ],
        ),
      );
}
