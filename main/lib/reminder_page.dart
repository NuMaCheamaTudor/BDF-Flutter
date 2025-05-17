import 'package:flutter/material.dart';
import 'notification_service.dart';

class ReminderPage extends StatefulWidget {
  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  int _zile = 3;
  int _intervalOre = 6;
  TimeOfDay _oraStart = TimeOfDay(hour: 8, minute: 0);

  Future<void> _alegeOraStart(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _oraStart,
    );
    if (picked != null) {
      setState(() => _oraStart = picked);
    }
  }

  void _startReminder() async {
    final interval = Duration(hours: _intervalOre);
    final total = Duration(days: _zile);

    await NotificationService.scheduleRepeatedNotifications(
      interval: interval,
      totalDuration: total,
      startHour: _oraStart.hour,
      startMinute: _oraStart.minute,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Reminder setat: $_zile zile, la $_intervalOre ore, de la ${_oraStart.format(context)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tratament Pastile')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Câte zile durează tratamentul?", style: TextStyle(fontSize: 18)),
            Slider(
              value: _zile.toDouble(),
              min: 1,
              max: 14,
              divisions: 13,
              label: "$_zile zile",
              onChanged: (val) => setState(() => _zile = val.toInt()),
            ),
            const SizedBox(height: 24),
            Text("La câte ore să vină notificările?", style: TextStyle(fontSize: 18)),
            Slider(
              value: _intervalOre.toDouble(),
              min: 1,
              max: 24,
              divisions: 23,
              label: "$_intervalOre ore",
              onChanged: (val) => setState(() => _intervalOre = val.toInt()),
            ),
            const SizedBox(height: 24),
            Text("Ora de început: ${_oraStart.format(context)}", style: TextStyle(fontSize: 18)),
            TextButton(
              onPressed: () => _alegeOraStart(context),
              child: const Text("Schimbă ora de start"),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _startReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text("Start tratament 💊"),
            ),
          ],
        ),
      ),
    );
  }
}
