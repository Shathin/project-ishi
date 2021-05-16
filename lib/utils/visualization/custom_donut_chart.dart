import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'indicator.dart';

class CustomDonuChart extends StatefulWidget {
  final Map<String, dynamic> dataMap;
  final String donutChartHeading;
  final double height;
  final double width;
  final double focusedRadius;
  final double unfocusedRadius;
  final double focusedChartTitleFontSize;
  final double unfocusedChartFontSize;
  final double focusedLegendTextFontSize;
  final double unfocusedLegendTextFontSize;
  final List<Color> colors;

  CustomDonuChart({
    required this.dataMap,
    required this.colors,
    required this.donutChartHeading,
    this.height = 512,
    this.width = 512,
    this.focusedRadius = 120.0,
    this.unfocusedRadius = 100.0,
    this.focusedChartTitleFontSize = 25.0,
    this.unfocusedChartFontSize = 18.0,
    this.focusedLegendTextFontSize = 20,
    this.unfocusedLegendTextFontSize = 16,
  }) : assert(
          dataMap.keys.length <= colors.length,
          'The number of entries in the [dataMap] argument and the [colors] argument must match',
        );

  @override
  State<StatefulWidget> createState() => _CustomDonuChartState();
}

class _CustomDonuChartState extends State<CustomDonuChart> {
  int touchedIndex = -1;
  final double titlePositionPercentageOffset = 0.7;

  /// Handles the touch reponse of the pie chart
  void pieChartTouchResponse(PieTouchResponse pieTouchResponse) {
    setState(() {
      final desiredTouch = pieTouchResponse.touchInput is! PointerExitEvent &&
          pieTouchResponse.touchInput is! PointerUpEvent;
      if (desiredTouch && pieTouchResponse.touchedSection != null) {
        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
      } else {
        touchedIndex = -1;
      }
    });
  }

  /// Handles the generation of the sections of the pie chart
  List<PieChartSectionData> generateSections() {
    List<PieChartSectionData> sections = [];

    Iterable keys = widget.dataMap.keys;

    for (int iter = 0; iter < keys.length; iter++) {
      final isTouched = iter == touchedIndex;
      final fontSize = isTouched
          ? widget.focusedChartTitleFontSize
          : widget.unfocusedChartFontSize;
      final radius = isTouched ? widget.focusedRadius : widget.unfocusedRadius;
      final TextStyle chartTitleStyle = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

      sections.add(
        PieChartSectionData(
          color: widget.colors[iter],
          value: widget.dataMap[keys.elementAt(iter)],
          title: ((widget.dataMap[keys.elementAt(iter)] as double) * 100)
                  .ceil()
                  .toString() +
              " %",
          radius: radius,
          titleStyle: chartTitleStyle,
          titlePositionPercentageOffset: titlePositionPercentageOffset,
        ),
      );
    }

    return sections;
  }

  /// Handles building the legend for the pie chart
  Widget buildIndicators() {
    final Color focusedFontColor =
        Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black;
    final Color unfocusedFontColor = Colors.grey;

    List<Widget> children = [];

    Iterable keys = widget.dataMap.keys;

    for (int iter = 0; iter < keys.length; iter++) {
      children.add(
        Indicator(
          color: widget.colors[iter],
          text: keys.elementAt(iter),
          isSquare: true,
          size: touchedIndex == iter
              ? widget.focusedLegendTextFontSize
              : widget.unfocusedLegendTextFontSize,
          textColor:
              touchedIndex == iter ? focusedFontColor : unfocusedFontColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  /// Handles building the pie chart
  Widget buildPieChart() => PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: pieChartTouchResponse,
            enabled: true,
          ),
          borderData: FlBorderData(
            show: false,
          ),
          sectionsSpace: 4,
          centerSpaceRadius: 64,
          sections: generateSections(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              flex: 1,
              child: Text(
                widget.donutChartHeading,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Flexible(
              flex: 6,
              child: buildPieChart(),
            ),
            // SizedBox(height: 16.0),
            Flexible(
              flex: 1,
              child: buildIndicators(),
            ),
          ],
        ),
      ),
    );
  }
}
