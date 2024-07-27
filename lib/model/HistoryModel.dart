class HistoryModel {
  final DateTime date;
  final String origin;
  final String destination;
  final Duration duration;
  final double cost;

  HistoryModel({
    required this.date,
    required this.origin,
    required this.destination,
    required this.duration,
    required this.cost,
  });
}
