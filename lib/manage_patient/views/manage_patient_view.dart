import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/manage_patient/bloc/manage_patient_bloc.dart';
import 'package:project_ishi/manage_patient/views/patient_card.dart';
import 'package:project_ishi/manage_patient/views/record_card_list.dart';
import 'package:project_ishi/view_all_patients/bloc/patients_bloc.dart';

class ManagePatientView extends StatelessWidget {
  final String pid;

  final BuildContext parentBlocContext;

  bool requireParentRebuild = false;

  ManagePatientView({
    required this.pid,
    required this.parentBlocContext,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManagePatientBloc(
        patientsRepo: context.read<PatientsRepo>(),
        recordsRepo: context.read<RecordsRepo>(),
      )..add(
          LoadManagePatientEvent(pid: this.pid),
        ),
      child: Scaffold(
        backgroundColor: Colors.transparent.withOpacity(0.5),
        body: Card(
          margin: EdgeInsets.all(32.0),
          child: BlocConsumer<ManagePatientBloc, ManagePatientState>(
            // listenWhen: (previous, current) => previous is ManagePatientLoadedState && (current is ManagePatientLoadedState || current is ManageP),
            listener: (context, state) {
              if (state is ManagePatientsErrorState) {
                print(state.message);
              }
            },
            builder: (context, state) {
              if (state is LoadingManagePatientState) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ManagePatientLoadedState) {
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // _buildBody(context, state),
                      _buildCloseButton(context),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            PatientCard(patient: state.patient),
                            Divider(),
                            SizedBox(height: 4.0),
                            Expanded(
                              child: RecordCardList(records: state.records),
                            ),
                          ],
                        ),
                      ),
                      // Container(),
                    ],
                  ),
                );
              } else if (state is ManagePatientsErrorState) {
              } else if (state is PatientDeletedState) {
                Navigator.of(context).pop();
                parentBlocContext
                    .read<PatientsBloc>()
                    .add(LoadAllPatientsEvent());
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

  /// A button on the top right of the modal that is used for closing the modal
  Widget _buildCloseButton(BuildContext context) => Positioned(
        child: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
            parentBlocContext.read<PatientsBloc>().add(LoadAllPatientsEvent());
          },
          icon: FaIcon(
            FontAwesomeIcons.times,
            color: Colors.red,
            size: 12.0,
          ),
          tooltip: 'Close',
        ),
        top: 0,
        right: 0,
      );
}
