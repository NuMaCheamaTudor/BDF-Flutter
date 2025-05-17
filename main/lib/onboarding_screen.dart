
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Bine ai venit!',
      'desc': 'Această aplicație te va ajuta să nu uiți pastilele.',
    },
    {
      'title': 'Notificări programate',
      'desc': 'Setează intervalele și durata tratamentului.',
    },
    {
      'title': 'Totul e sub control',
      'desc': 'Primești notificări chiar și când aplicația este închisă.',
    },
  ];

  void _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (_, index) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 24),
                Text(_pages[index]['title']!, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(_pages[index]['desc']!, textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        },
      ),
      bottomSheet: _currentPage == _pages.length - 1
          ? TextButton(
              onPressed: _finishOnboarding,
              child: Text("Începe!", style: TextStyle(fontSize: 18)),
              style: TextButton.styleFrom(padding: EdgeInsets.all(16)),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _controller.jumpToPage(_pages.length - 1),
                  child: const Text("Sari"),
                ),
                TextButton(
                  onPressed: () => _controller.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease),
                  child: const Text("Înainte"),
                ),
              ],
            ),
    );
  }
}
