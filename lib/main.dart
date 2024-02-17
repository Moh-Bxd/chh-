import 'package:chl2/ex2.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:async' show Future;
import 'package:syncfusion_flutter_charts/charts.dart';

import 'SalesData.dart';
import 'model.dart';

void main() {
  runApp( MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key); // Corrected the key parameter

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Set<String> uniqueStores = {};

  String extractMonthYear(DateTime date) {
    return '${date.month}-${date.year}';
  }

  Future<List<DataModel>> readCSV() async {
    try {
      String data = await rootBundle.loadString('assets/Walmart_sales.csv');
      List<List<dynamic>> rows = CsvToListConverter().convert(data);
      List<DataModel> dataList = [];
      for (int i = 1; i < rows.length; i++) {
        DateTime salesDate;

        try {
          List<String> dateParts = rows[i][1].toString().split('-');
          if (dateParts.length == 3) {
            // Convert to yyyy-MM-dd format
            String formattedDate =
                '${dateParts[2]}-${dateParts[1]}-${dateParts[0]}';
            salesDate = DateTime.parse(formattedDate);
          } else {
            throw Exception("Invalid date format");
          }
        } catch (e) {
          print('Invalid date format: ${rows[i][1]}');
          continue; // Skip this row if date format is invalid
        }

        // Parse numeric values as numbers
        String store = rows[i][0].toString();
        double weeklySales = double.parse(rows[i][2].toString());
        uniqueStores.add(store);

        dataList.add(DataModel(
            store: store, salesWeekly: salesDate, weeklySales: weeklySales));
      }

      print(dataList.length);
      print('object');

      return dataList;
    } catch (e) {
      // Print any error that occurs during CSV reading
      print('Error reading CSV: $e');
      return []; // Return an empty list to handle the error
    }
  }

  @override
  Widget build(BuildContext context) {
    List<DataModel> data = [];
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Earnings by Month")),
        body: SafeArea(
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  return ElevatedButton(onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Exercise2(data: data, stores: uniqueStores.toList()),
                  )), child: Text('Goto exo @ 2'));
                }
              ),
              Expanded(
                child: Container(
                  child: FutureBuilder<List<DataModel>>(
                    future: readCSV(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text("No data available"));
                      } else {
                        data.addAll(snapshot.data!);

                        // Group earnings by month and year
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

                        return SfCartesianChart(
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
                              dataSource: chartData,
                              xValueMapper: (SalesData sales, _) => sales.monthYear,
                              yValueMapper: (SalesData sales, _) => sales.earnings,
                              name: 'Earnings',
                            ),
                          ],
                        );
                      }
                    },
                  ),

                ),
              ),

            ],
          ),
        ),
      ),
        );
  }
}
