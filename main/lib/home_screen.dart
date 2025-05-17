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
      const SnackBar(content: Text('Ridică-ți capul și moralul 💊')),
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
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('Bring me up'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDashboardCard(
              context,
              icon: Icons.access_time,
              title: 'Ora de start',
              content: Text(
                '🕒 ${_oraStart.format(context)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              action: ElevatedButton(
                onPressed: () => pickStartTime(context),
                child: const Text('Selectează ora'),
              ),
            ),
            const SizedBox(height: 20),
            _buildDashboardCard(
              context,
              icon: Icons.calendar_today,
              title: 'Durata tratamentului',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_zile zile', style: const TextStyle(fontSize: 16)),
                  Slider(
                    min: 1,
                    max: 14,
                    divisions: 13,
                    label: '$_zile',
                    value: _zile.toDouble(),
                    onChanged: (val) => setState(() => _zile = val.toInt()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDashboardCard(
              context,
              icon: Icons.alarm,
              title: 'Interval notificări',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${_intervalOre.toInt()} ore', style: const TextStyle(fontSize: 16)),
                  Slider(
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: '${_intervalOre.toInt()}',
                    value: _intervalOre,
                    onChanged: (val) => setState(() => _intervalOre = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Pornește reminder-ul'),
              onPressed: programareNotificari,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(55),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget content,
    Widget? action,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: Colors.deepPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
