
import 'package:flutter/material.dart';
import 'package:main/main.dart';
import 'onboarding.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/pills.png', height: 200),
              const Text(
                "Bine ai venit!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Această aplicație te ajută să-ți amintești să iei pastilele la timp.\nConfigurează-ți tratamentul și gata!",
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => ConcentricAnimationOnboarding()),
                  );
                },
                child: const Text("Să începem 💊"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
