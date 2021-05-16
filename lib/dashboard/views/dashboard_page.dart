import 'package:database_repo/records_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_ishi/dashboard/bloc/dashboard_bloc.dart';
import 'package:project_ishi/utils/visualization/custom_donut_chart.dart';

class DashboardPage extends StatelessWidget {
  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => DashboardPage());

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardBloc(
        recordsRepo: context.read<RecordsRepo>(),
      )..add(LoadDashboardEvent()),
      child: Scaffold(
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is LoadingDashboardState)
              return Center(child: CircularProgressIndicator());
            else {
              Map<String, Map<String, dynamic>?> data =
                  (state as DashboardLoadedState).data;

              Map<String, dynamic>? percentFeeWaived = data["percentFeeWaived"];

              if (percentFeeWaived != null) {
                percentFeeWaived = Map.fromIterable(
                  percentFeeWaived.keys.where(
                    (key) => ["Yes", "No", "Partially"].contains(key),
                  ),
                  key: (key) => key,
                  value: (key) => percentFeeWaived?[key],
                );
              }

              Map<String, dynamic>? amountTotal = data["amountTotal"];

              if (amountTotal != null) {
                amountTotal = Map.fromIterable(
                  amountTotal.keys.where(
                    (key) => [
                      "percentageUnpaid",
                      "percentagePaid",
                    ].contains(key),
                  ),
                  key: (key) => key == "percentageUnpaid"
                      ? "Unpaid Amount"
                      : "Paid Amount",
                  value: (key) => amountTotal?[key],
                );
              }

              return Container(
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
                        'Dashboard',
                        style: Theme.of(context).textTheme.headline2,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Container(
                            width: double.infinity,
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runAlignment: WrapAlignment.center,
                              spacing: 32.0,
                              runSpacing: 32.0,
                              children: <Widget>[
                                if (percentFeeWaived != null)
                                  CustomDonuChart(
                                    donutChartHeading: 'Percent Fee Waived',
                                    dataMap: percentFeeWaived,
                                    height: 512,
                                    width: 512,
                                    colors: [
                                      Colors.red[900] ?? Colors.red,
                                      Colors.green[700] ?? Colors.green,
                                      Colors.yellow[800] ?? Colors.yellow,
                                    ],
                                  ),
                                if (amountTotal != null)
                                  CustomDonuChart(
                                    donutChartHeading:
                                        'Percent Paid vs Unpaid Amount',
                                    dataMap: amountTotal,
                                    height: 512,
                                    width: 512,
                                    colors: [
                                      Colors.red[900] ?? Colors.red,
                                      Colors.green[700] ?? Colors.green,
                                    ],
                                  ),
                                if (data["amountTotal"] != null)
                                  Container(
                                    alignment: Alignment.center,
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      runAlignment: WrapAlignment.center,
                                      spacing: 32.0,
                                      runSpacing: 32.0,
                                      children: [
                                        ...<dynamic>[
                                          "totalBilled",
                                          "totalPaid",
                                          "totalUnpaidAmount",
                                        ].map(
                                          (key) => Card(
                                            child: Padding(
                                              padding: EdgeInsets.all(16.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    key == "totalBilled"
                                                        ? "Total Billed Amount"
                                                        : key == "totalPaid"
                                                            ? "Total Paid Amount"
                                                            : "Total Unpaid Amount",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                  SizedBox(
                                                    width: 24.0,
                                                  ),
                                                  Text(
                                                    "₹ ${data["amountTotal"]?[key]}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
