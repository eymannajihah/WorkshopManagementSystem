import 'package:flutter/material.dart';
import '../models/schedule.dart';

class ScheduleProvider with ChangeNotifier {
  List<Schedule> _schedules = [];

  List<Schedule> get schedules => List.unmodifiable(_schedules);

  void addSchedule(Schedule schedule) {
    _schedules.add(schedule);
    notifyListeners();
  }

  void updateSchedule(String id, Schedule updatedSchedule) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index != -1) {
      _schedules[index] = updatedSchedule;
      notifyListeners();
    }
  }

  void deleteSchedule(String id) {
    _schedules.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  Schedule? getById(String id) {
    try {
      return _schedules.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  void loadSchedules(List<Schedule> initialData) {
    _schedules = List.from(initialData);
    notifyListeners();
  }
}
