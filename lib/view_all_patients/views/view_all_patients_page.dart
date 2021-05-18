import 'package:database_repo/patients_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/view_all_patients/views/patient_card.dart';
import 'package:project_ishi/view_all_patients/views/search_bar.dart';
import '../bloc/patients_bloc.dart';
import 'add_patient_dialog.dart';

class ViewAllPatientsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ViewAllPatientsPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientsBloc(
        patientsRepo: context.read<PatientsRepo>(),
      )..add(LoadAllPatientsEvent()),
      child: BlocBuilder<PatientsBloc, PatientsState>(
        builder: (context, state) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              heroTag: 'view_all_patients',
              onPressed: state is LoadingPatientsState
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (_) => AddPatientDialog(
                          blocContext: context,
                        ),
                      );
                    },
              mouseCursor: state is LoadingPatientsState
                  ? SystemMouseCursors.forbidden
                  : SystemMouseCursors.click,
              child: FaIcon(FontAwesomeIcons.plus),
              tooltip: 'Add new patient',
              isExtended: true,
            ),
            body: Container(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SearchBar(),
                  Expanded(
                    child: state is LoadingPatientsState
                        ? Center(child: CircularProgressIndicator())
                        : (state as PatientsLoadedState).patients == null
                            ? Center(
                                child: Text(
                                  'No patients found! ☹',
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              )
                            : SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Wrap(
                                  children: state.patients
                                          ?.map<Widget>(
                                            (patient) => PatientCard(
                                              patient: patient,
                                            ),
                                          )
                                          .toList() ??
                                      [],
                                ),
                              ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
