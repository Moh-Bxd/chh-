import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async' show Future;
import 'package:syncfusion_flutter_charts/charts.dart';

import 'SalesData.dart';
import 'model.dart';

class Exercise2 extends StatefulWidget {
  const Exercise2({Key? key, this.data, this.stores})
      : super(key: key); // Corrected the key parameter

  final List<DataModel>? data;
  final List<String>? stores;

  @override
  State<Exercise2> createState() => _Exercise2State();
}

class _Exercise2State extends State<Exercise2> {
  List<SalesData> storeData = [];
  late List<String> uniqueStores = [];
  String extractMonthYear(DateTime date) {
    return '${date.month}-${date.year}';
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Earnings by Month")),
      body: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Goto exo @ !')),
            DropdownMenu(
              dropdownMenuEntries: widget.stores!
                  .map((e) => DropdownMenuEntry(label: e, value: e))
                  .toList(),
              onSelected: (value) {
                final data = widget.data!
                    .where((element) => element.store == value)
                    .toList();

                Map<String, double> earningsByMonthYear = {};
                for (var item in data) {
                  String monthYear = extractMonthYear(item.salesWeekly);
                  earningsByMonthYear[monthYear] =
                      (earningsByMonthYear[monthYear] ?? 0) + item.weeklySales;
                }

                // Create chart data
                List<SalesData> chartData = [];
                earningsByMonthYear.forEach((key, value) {
                  chartData.add(SalesData(monthYear: key, earnings: value));
                });

                setState(() {
                  storeData = chartData;
                });
              },
            ),
            Expanded(
              child: Container(
                  child: SfCartesianChart(
                zoomPanBehavior: ZoomPanBehavior(
                  enablePinching: true,
                  enablePanning: true,
                  enableDoubleTapZooming: true,
                  enableSelectionZooming: true,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                ),
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource: storeData,
                    xValueMapper: (SalesData sales, _) => sales.monthYear,
                    yValueMapper: (SalesData sales, _) => sales.earnings,
                    name: 'Earnings',
                  ),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
