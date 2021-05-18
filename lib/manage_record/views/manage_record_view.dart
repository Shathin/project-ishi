import 'package:database_repo/patients_repo.dart';
import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/manage_record/bloc/manage_record_bloc.dart';
import 'package:project_ishi/manage_record/views/patient_card.dart';
import 'package:project_ishi/manage_record/views/record_card.dart';
import 'package:project_ishi/view_all_records/bloc/records_bloc.dart';

class ManageRecordView extends StatefulWidget {
  final String rid;
  final String pid;
  BuildContext parentBlocContext;

  ManageRecordView({
    required this.rid,
    required this.pid,
    required this.parentBlocContext,
  });

  @override
  _ManageRecordViewState createState() => _ManageRecordViewState();
}

class _ManageRecordViewState extends State<ManageRecordView> {
  Template? template;

  @override
  void initState() {
    context.read<TemplateRepo>().readTemplate().then((template) {
      setState(() {
        this.template = template;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ManageRecordBloc(
        patientsRepo: context.read<PatientsRepo>(),
        recordsRepo: context.read<RecordsRepo>(),
      )..add(
          LoadManageRecordEvent(pid: widget.pid, rid: widget.rid),
        ),
      child: Scaffold(
        backgroundColor: Colors.transparent.withOpacity(0.5),
        body: Card(
          margin: EdgeInsets.all(32.0),
          child: BlocBuilder<ManageRecordBloc, ManageRecordState>(
            builder: (context, state) {
              if (state is LoadingManageRecordState) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is ManageRecordLoadedState) {
                if (this.template != null) {
                  return Container(
                    height: double.infinity,
                    width: double.infinity,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
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
                                child: SingleChildScrollView(
                                  physics: BouncingScrollPhysics(),
                                  child: RecordCard(
                                    record: state.record,
                                    template: this.template ?? Template.empty(),
                                    parentBlocContext: widget.parentBlocContext,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              } else if (state is ManageRecordsErrorState) {
                return Container();
              } else {
                // * ManageRecordDeletedState
                Navigator.of(context).pop();
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
            widget.parentBlocContext
                .read<RecordsBloc>()
                .add(LoadAllRecordsEvent());
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
