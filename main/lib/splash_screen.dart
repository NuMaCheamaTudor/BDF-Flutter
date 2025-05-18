import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:main/main.dart';
import 'package:main/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart';
import 'main_screen.dart';
import 'onboarding.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _startDelay();
  }

  void _startDelay() {
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _showButton = true;
      });
    });
  }

  Future<void> _navigateNext() async {
  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => ConcentricAnimationOnboarding(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: SvgPicture.string(
                    paymentProcessIllistration,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              ErrorInfo(
                title: "Hello and Welcome",
                description:
                    "We're setting things up for you. This will only take a moment.",
                button: _showButton
                    ? ElevatedButton(
                        onPressed: _navigateNext,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("CONTINUE"),
                      )
                    : const CircularProgressIndicator.adaptive(),
                press: _navigateNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorInfo extends StatelessWidget {
  const ErrorInfo({
    super.key,
    required this.title,
    required this.description,
    this.button,
    this.btnText,
    required this.press,
  });

  final String title;
  final String description;
  final Widget? button;
  final String? btnText;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            button ??
                ElevatedButton(
                  onPressed: press,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  child: Text(btnText ?? "RETRY"),
                ),
          ],
        ),
      ),
    );
  }
}

// SVG ilustrativ
const paymentProcessIllistration = '''
<svg width="100" height="100" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2L2 7h20L12 2z" fill="#E5E5E5"/>
  <path d="M2 7v13h20V7" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';
