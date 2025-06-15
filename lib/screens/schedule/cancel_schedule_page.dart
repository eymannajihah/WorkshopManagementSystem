import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class CancelSchedulePage extends StatelessWidget {
  final Schedule schedule;
  const CancelSchedulePage({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancel Schedule')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Cancel This Schedule'),
          onPressed: () {
            Provider.of<ScheduleProvider>(
              context,
              listen: false,
            ).deleteSchedule(schedule.id);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
