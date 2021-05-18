import 'package:database_repo/records_repo.dart';
import 'package:database_repo/template_repo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/manage_patient/views/record_card.dart';

class RecordCardList extends StatefulWidget {
  final List<Record> records;

  RecordCardList({required this.records});

  @override
  _RecordCardListState createState() => _RecordCardListState();
}

class _RecordCardListState extends State<RecordCardList> {
  final List<Record?> records = [];
  Template? template;
  @override
  void initState() {
    setState(() {
      records.addAll(widget.records);
    });

    context.read<TemplateRepo>().readTemplate().then((template) {
      setState(() {
        this.template = template;
      });
    });
    super.initState();
  }

  final ScrollController _scrollController = ScrollController();
  bool addedNewItem = false;

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      scrollDirection: Axis.vertical,
      controller: _scrollController,
      itemBuilder: (context, index) => RecordCard(
        record: records[index] ?? null,
        template: this.template ?? Template.empty(),
      ),
      itemCount: records.length,
    );

    if (_scrollController.hasClients && addedNewItem) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
    return Container(
      height: double.infinity,
      width: double.infinity,
      // color: Colors.red,
      child: this.template == null
          ? CircularProgressIndicator()
          : Stack(
              children: <Widget>[
                listView,
                // ! Records List View
                // AnimatedList(
                //   key: _recordsListKey,
                //   itemBuilder: (context, index, animation) => RecordCard(
                //     record: records[index],
                //     template: this.template ?? Template.empty(),
                //   ),
                //   initialItemCount: records.length,
                // ),

                // ! Add new record button
                Positioned(
                  child: FloatingActionButton(
                    heroTag: '_buildAddNewRecordButton',
                    onPressed: () {
                      setState(() {
                        records.add(null);
                        addedNewItem = true;
                      });
                    },
                    child: FaIcon(FontAwesomeIcons.plus),
                    tooltip: 'Create new record',
                  ),
                  bottom: 16,
                  right: 0,
                ),
              ],
            ),
    );
  }
}
