import 'package:flutter/material.dart';
import 'notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TimeOfDay _oraStart = TimeOfDay.now();
  int _zile = 1;
  double _intervalOre = 6;

  Future<void> pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _oraStart,
    );

    if (picked != null) {
      setState(() {
        _oraStart = picked;
      });
    }
  }

  Future<void> programareNotificari() async {
    final interval = Duration(hours: _intervalOre.toInt());
    final total = Duration(days: _zile);
    await NotificationService.scheduleRepeatedNotifications(
      interval: interval,
      totalDuration: total,
      startHour: _oraStart.hour,
      startMinute: _oraStart.minute,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ridica-ti capul si moralul')),
    );
  }

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bring me up'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ora de start: ${_oraStart.format(context)}', style: Theme.of(context).textTheme.titleMedium),
            ElevatedButton(
              onPressed: () => pickStartTime(context),
              child: const Text('Selectează ora de start'),
            ),
            const SizedBox(height: 20),
            Text('Durata tratamentului (zile): $_zile', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              min: 1,
              max: 14,
              divisions: 13,
              label: _zile.toString(),
              value: _zile.toDouble(),
              onChanged: (val) {
                setState(() {
                  _zile = val.toInt();
                });
              },
            ),
            const SizedBox(height: 20),
            Text('Interval între notificări: ${_intervalOre.toInt()} ore', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              min: 1,
              max: 24,
              divisions: 23,
              label: _intervalOre.toStringAsFixed(0),
              value: _intervalOre,
              onChanged: (val) {
                setState(() {
                  _intervalOre = val;
                });
              },
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Pornește reminder-ul'),
              onPressed: programareNotificari,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
