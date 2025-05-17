import 'package:flutter/material.dart';
import 'package:main/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';
import 'theme/theme.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:main/home_screen.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder Pastile',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: ConcentricAnimationOnboarding(),
    );
  }
}

final pages = [
  const PageData(
    icon: Icons.medication_outlined,
    title: "Alege durata tratamentului",
    bgColor: Color(0xff3b1791),
    textColor: Colors.white,
  ),
  const PageData(
    icon: Icons.access_time,
    title: "Selectează ora și intervalul",
    bgColor: Color(0xfffab800),
    textColor: Color(0xff3b1790),
  ),
  const PageData(
    icon: Icons.notifications_active,
    title: "Primește notificări zilnice 💊",
    bgColor: Color(0xffffffff),
    textColor: Color(0xff3b1790),
  ),
];

class ConcentricAnimationOnboarding extends StatelessWidget {
  const ConcentricAnimationOnboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        radius: screenWidth * 0.1,
        nextButtonBuilder: (context) => Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Icon(
            Icons.navigate_next,
            size: screenWidth * 0.08,
          ),
        ),
        itemCount: pages.length,
        scaleFactor: 2,
        onFinish: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        },
        itemBuilder: (index) {
          final page = pages[index % pages.length];
          return SafeArea(
            child: _Page(page: page),
          );
        },
      ),
    );
  }
}

class PageData {
  final String? title;
  final IconData? icon;
  final Color bgColor;
  final Color textColor;

  const PageData({
    this.title,
    this.icon,
    this.bgColor = Colors.white,
    this.textColor = Colors.black,
  });
}

class _Page extends StatelessWidget {
  final PageData page;

  const _Page({Key? key, required this.page}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.all(16.0),
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: page.textColor),
          child: Icon(
            page.icon,
            size: screenHeight * 0.1,
            color: page.bgColor,
          ),
        ),
        Text(
          page.title ?? "",
          style: TextStyle(
              color: page.textColor,
              fontSize: screenHeight * 0.035,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
