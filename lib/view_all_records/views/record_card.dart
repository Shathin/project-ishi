import 'package:database_repo/records_repo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:project_ishi/manage_record/manage_record.dart';

class RecordCard extends StatelessWidget {
  final Record record;

  RecordCard({required this.record});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              reverseTransitionDuration: Duration(milliseconds: 250),
              transitionDuration: Duration(milliseconds: 250),
              barrierDismissible: true,
              pageBuilder: (BuildContext buildContext, _, __) =>
                  ManageRecordView(
                pid: record.pid,
                rid: record.rid,
                parentBlocContext: context,
              ),
              transitionsBuilder:
                  (___, Animation<double> animation, ____, Widget child) {
                return FadeTransition(
                  opacity: animation,
                  child: FadeTransition(
                    opacity:
                        Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                    // turns:
                    //     Tween<double>(begin: 0.5, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(8.0),
          width: 512.0,
          child: Stack(
            children: [
              // ! Small piece of text showning the patient's ID
              _buildIDText(),
              // ! Small piece of text showning the patient's ID
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  record.feeWaived == "Partially"
                      ? "⚠"
                      : record.feeWaived == "No"
                          ? record.billedAmount - record.paidAmount != 0
                              ? "❌"
                              : "✔"
                          : "✔",
                ),
              ),
              // ! Text elements showing the record information
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20.0,
                  horizontal: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Procedure Code: ${record.procedureCode}"),
                          Text(
                            "Procedure Name: ${record.procedureName.substring(0, 12)}" +
                                (record.procedureName.length > 15 ? "..." : ""),
                          ),
                          Text(
                            "Date of Procedure: ${record.dateOfProcedure.day}-${record.dateOfProcedure.month}-${record.dateOfProcedure.year}",
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Fee Waived?: ${record.feeWaived}",
                          ),
                          Text(
                              "Billed Amount: ₹ ${record.billedAmount.toInt()}"),
                          if (record.feeWaived != "Yes")
                            Text(
                                "Paid Amount  : ₹ ${record.paidAmount.toInt()}"),
                          Text(
                            "Difference: ₹ ${(record.billedAmount - record.paidAmount).toInt()}",
                          )
                        ],
                      ),
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

  Widget _buildIDText() => Positioned(
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
              record.pid,
              style: TextStyle(
                fontSize: 10.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              width: 16.0,
            ),
            FaIcon(
              FontAwesomeIcons.fileAlt,
              size: 10.0,
              color: Colors.grey,
            ),
            SizedBox(
              width: 4.0,
            ),
            Text(
              record.rid,
              style: TextStyle(
                fontSize: 10.0,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
}
