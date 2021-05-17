import 'package:database_repo/patients_repo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'add_patient_dialog.dart';

class PatientCard extends StatelessWidget {
  final Patient patient;

  PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          print("CARD PRESSED!");
        }, // TODO : Implement on tap

        child: Container(
          padding: EdgeInsets.all(8.0),
          width: 400.0,
          child: Stack(
            children: [
              // ! Small piece of text showning the patient's ID
              Positioned(
                right: 0,
                top: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.user,
                      size: 10.0,
                      color: Colors.grey,
                    ),
                    SizedBox(
                      width: 4.0,
                    ),
                    Text(
                      patient.pid,
                      style: TextStyle(
                        fontSize: 10.0,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              // ! Text elements showing the patient's information
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${patient.name}"),
                          Text("Gender : ${patient.gender.enumToString()}"),
                          Text("Age: ${patient.age ?? 'N/A'}"),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            'Record count: ${patient.recordReferences.length}'),
                        SizedBox(height: 16.0),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AddPatientDialog(
                                blocContext: context,
                                patient: patient,
                              ),
                            );
                          },
                          icon: FaIcon(FontAwesomeIcons.edit),
                          tooltip: 'Edit',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
