import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:database_repo/patients_repo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../manage_patient/bloc/manage_patient_bloc.dart';

class PatientCard extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  Gender gender = Gender.PreferNotToSay;
  String name = '';
  int? age;

  final Patient patient;

  PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    gender = patient.gender;
    name = patient.name;
    age = patient.age;

    nameController.text = name;
    genderController.text = gender.enumToString();
    ageController.text = age == null ? 'N/A' : age.toString();

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
                        value: patient.pid,
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
                          _buildGenderInputField(),
                          _buildRecordCountText(
                            value: patient.recordReferences.length.toString(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
        child: TextField(
          readOnly: true,
          controller: nameController,
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
      );

  Widget _buildAgeInputField() => Container(
        constraints: BoxConstraints(
          minWidth: 200.0,
          maxWidth: 200.0,
        ),
        child: TextField(
          readOnly: true,
          controller: ageController,
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
      );

  Widget _buildGenderInputField() => Container(
        constraints: BoxConstraints(
          minWidth: 200.0,
          maxWidth: 200.0,
        ),
        child: TextField(
          readOnly: true,
          controller: genderController,
          decoration: InputDecoration(
            labelText: "Patient's Gender",
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
      );
}
