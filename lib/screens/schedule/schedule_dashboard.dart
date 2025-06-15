import 'package:flutter/material.dart';
import 'add_schedule_page.dart';
import 'view_schedule_page.dart';

class ScheduleDashboard extends StatelessWidget {
  const ScheduleDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Schedule Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: const Text("View Schedule"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewSchedulePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Schedule"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSchedulePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
