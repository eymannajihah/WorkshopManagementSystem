class Schedule {
  final String id;
  final String ownerId;
  final String foremanId;
  final DateTime date;
  final String startTime;
  final String endTime;

  Schedule({
    required this.id,
    required this.ownerId,
    required this.foremanId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  bool isOverlapping(Schedule other) {
    if (date != other.date) return false;

    // Convert startTime and endTime to comparable DateTime on the same date
    final thisStart = _timeToDateTime(date, startTime);
    final thisEnd = _timeToDateTime(date, endTime);
    final otherStart = _timeToDateTime(other.date, other.startTime);
    final otherEnd = _timeToDateTime(other.date, other.endTime);

    return thisStart.isBefore(otherEnd) && thisEnd.isAfter(otherStart);
  }

  bool isUpcoming() {
    final now = DateTime.now();

    final thisStart = _timeToDateTime(date, startTime);
    return thisStart.isAfter(now);
  }

  static DateTime _timeToDateTime(DateTime date, String time) {
    // Assume time is in "HH:mm" 24h format
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  factory Schedule.fromMap(Map<String, dynamic> map, String id) {
    return Schedule(
      id: id,
      ownerId: map['ownerId'] ?? '',
      foremanId: map['foremanId'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'foremanId': foremanId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
