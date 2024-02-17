class DataModel {
  final String store;
  final DateTime salesWeekly; // Assuming this is the sales date
  final double weeklySales; // Assuming this is the weekly sales amount

  DataModel({required this.store, required this.salesWeekly, required this.weeklySales});
}