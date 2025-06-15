import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../providers/schedule_provider.dart';
import 'package:uuid/uuid.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _foremanIdController = TextEditingController();
  DateTime? _selectedDate;
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void dispose() {
    _foremanIdController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  bool _isValidTimeFormat(String time) {
    final timeRegExp = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    return timeRegExp.hasMatch(time);
  }

  bool _isEndTimeAfterStartTime(String start, String end) {
    final startParts = start.split(':');
    final endParts = end.split(':');
    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    return endMinutes > startMinutes;
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final startTime = _startTimeController.text.trim();
      final endTime = _endTimeController.text.trim();

      if (!_isValidTimeFormat(startTime)) {
        _showError("Start Time must be in HH:mm format.");
        return;
      }

      if (!_isValidTimeFormat(endTime)) {
        _showError("End Time must be in HH:mm format.");
        return;
      }

      if (!_isEndTimeAfterStartTime(startTime, endTime)) {
        _showError("End Time must be after Start Time.");
        return;
      }

      final newSchedule = Schedule(
        id: const Uuid().v4(),
        ownerId: 'owner001',
        foremanId: _foremanIdController.text.trim(),
        date: _selectedDate!,
        startTime: startTime,
        endTime: endTime,
      );

      Provider.of<ScheduleProvider>(
        context,
        listen: false,
      ).addSchedule(newSchedule);

      Navigator.pop(context);
    } else if (_selectedDate == null) {
      _showError("Please select a date.");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Schedule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _foremanIdController,
                decoration: const InputDecoration(labelText: 'Foreman ID'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDate == null
                          ? 'No date selected'
                          : 'Selected date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                    ),
                  ),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              TextFormField(
                controller: _startTimeController,
                decoration: const InputDecoration(
                  labelText: 'Start Time (e.g., 09:00)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!_isValidTimeFormat(value.trim()))
                    return 'Invalid time format';
                  return null;
                },
              ),
              TextFormField(
                controller: _endTimeController,
                decoration: const InputDecoration(
                  labelText: 'End Time (e.g., 17:00)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (!_isValidTimeFormat(value.trim()))
                    return 'Invalid time format';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
