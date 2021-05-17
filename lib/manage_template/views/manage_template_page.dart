import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/manage_template/bloc/template_bloc.dart';
import 'package:project_ishi/manage_template/views/category_card.dart';

import 'manage_field_form.dart';

class ManageTemplatePage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ManageTemplatePage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TemplateBloc(
        templateRepo: context.read<TemplateRepo>(),
      )..add(LoadTemplateEvent()),
      child: BlocBuilder<TemplateBloc, TemplateState>(
        buildWhen: (previous, current) =>
            previous is ReorderTemplateFieldEvent ? false : true,
        builder: (context, state) => state is LoadingTemplateState
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ManageFieldForm(
                        blocContext: context,
                      ),
                    );
                  },
                  tooltip: "Create new field",
                  child: FaIcon(FontAwesomeIcons.plus),
                ),
                body: Container(
                  height: double.infinity,
                  width: double.infinity,
                  padding: EdgeInsets.all(32.0),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Manage Template',
                          style: Theme.of(context).textTheme.headline2,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Wrap(
                            children: [
                              CategoryCard(
                                fields: (state as TemplateLoadedState)
                                    .template
                                    .patientDetails,
                              ),
                              CategoryCard(
                                fields: (state as TemplateLoadedState)
                                    .template
                                    .procedureDetails,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
