import 'package:database_repo/patients_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/view_all_patients/views/patient_card.dart';
import 'package:project_ishi/view_all_patients/views/search_bar.dart';
import '../bloc/patients_bloc.dart';

class ViewAllPatientsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ViewAllPatientsPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientsBloc(
        patientsRepo: context.read<PatientsRepo>(),
      )..add(LoadAllPatientsEvent()),
      child: Scaffold(
        body: BlocBuilder<PatientsBloc, PatientsState>(
          builder: (context, state) {
            return Container(
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
                    // : Center(
                    //     child: Text(
                    //       'View All Patients\nFound ${state.patients?.length} patients',
                    //       style: Theme.of(context).textTheme.headline1,
                    //     ),
                    //   ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
