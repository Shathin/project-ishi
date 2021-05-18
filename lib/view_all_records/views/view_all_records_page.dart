import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/view_all_records/views/search_bar.dart';
import 'package:project_ishi/view_all_records/bloc/records_bloc.dart';
import 'package:project_ishi/view_all_records/views/record_card.dart';

class ViewAllRecordsPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => ViewAllRecordsPage());

  bool sortByDateOfProcedure = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecordsBloc(
        recordsRepo: context.read<RecordsRepo>(),
        templateRepo: context.read<TemplateRepo>(),
      )..add(
          LoadAllRecordsEvent(
            sortByDateOfProcedure: sortByDateOfProcedure,
          ),
        ),
      child: Scaffold(
        body: BlocBuilder<RecordsBloc, RecordsState>(
          builder: (context, state) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ! Search bar and Sort By Date checkbox
                  SearchBar(),
                  Expanded(
                    child: state is LoadingRecordsState
                        ? Center(child: CircularProgressIndicator())
                        : (state as RecordsLoadedState).records == null
                            ? Center(
                                child: Text(
                                  'No records found! ☹',
                                  style: Theme.of(context).textTheme.headline1,
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  // childAspectRatio: 3,
                                  mainAxisExtent: 170.0,
                                ),
                                physics: BouncingScrollPhysics(),
                                itemCount: state.records == null
                                    ? 0
                                    : state.records?.length,
                                itemBuilder: (context, index) {
                                  Record? record = state.records?[index];
                                  if (record == null)
                                    return Container();
                                  else
                                    return RecordCard(record: record);
                                },
                              ),
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
