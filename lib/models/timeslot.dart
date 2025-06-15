class TimeSlot {
  final String id;
  final String ownerId;
  final DateTime date;
  final String startTime;
  final String endTime;
  bool isBooked;

  TimeSlot({
    required this.id,
    required this.ownerId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  void markAsBooked() {
    isBooked = true;
  }

  bool isAvailable() {
    return !isBooked;
  }

  bool conflictsWith(DateTime otherDate, String otherStart, String otherEnd) {
    if (date != otherDate) return false;

    final thisStart = _timeToDateTime(date, startTime);
    final thisEnd = _timeToDateTime(date, endTime);
    final otherStartDT = _timeToDateTime(otherDate, otherStart);
    final otherEndDT = _timeToDateTime(otherDate, otherEnd);

    return thisStart.isBefore(otherEndDT) && thisEnd.isAfter(otherStartDT);
  }

  static DateTime _timeToDateTime(DateTime date, String time) {
    // Expect time in "HH:mm" 24h format
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map, String id) {
    return TimeSlot(
      id: id,
      ownerId: map['ownerId'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      isBooked: map['isBooked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isBooked': isBooked,
    };
  }
}
