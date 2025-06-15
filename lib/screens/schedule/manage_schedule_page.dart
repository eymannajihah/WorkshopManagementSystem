import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';

class ManageSchedulePage extends StatelessWidget {
  const ManageSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final schedules = scheduleProvider.schedules;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Schedules')),
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          final schedule = schedules[index];
          return ListTile(
            title: Text('Foreman ID: ${schedule.foremanId}'),
            subtitle: Text(
              '${schedule.date.toLocal().toString().split(' ')[0]} | ${schedule.startTime} - ${schedule.endTime}',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                scheduleProvider.deleteSchedule(schedule.id);
              },
            ),
          );
        },
      ),
    );
  }
}
