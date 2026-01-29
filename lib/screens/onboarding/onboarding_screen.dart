import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../splash_screen.dart';



class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int pageIndex = 0;

  Future<void> finishOnboarding() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool("onboarding_seen", true);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      {
        "image": "assets/onboarding/onboard_1.png",
        "title": "Explore Gwalior",
        "subtitle": "Find the best places, food, and hotels in Gwalior."
      },
      {
        "image": "assets/onboarding/onboard_2.png",
        "title": "Discover New Spots",
        "subtitle": "Get details, timings, ticket prices & more."
      },
      {
        "image": "assets/onboarding/onboard_3.png",
        "title": "Easy Navigation",
        "subtitle": "Use maps, transport guide & plan trips easily."
      }
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: finishOnboarding,
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => pageIndex = index);
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        pages[index]["image"],
                        height: 260,
                      ),
                      const SizedBox(height: 30),
                      Text(
                        pages[index]["title"],
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          pages[index]["subtitle"],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                    (index) => Container(
                  margin: const EdgeInsets.all(4),
                  width: pageIndex == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: pageIndex == index
                        ? const Color(0xFF1746A2)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: pageIndex == pages.length - 1
                    ? finishOnboarding
                    : () {
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1746A2),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  pageIndex == pages.length - 1
                      ? "Get Started"
                      : "Next",
                  style: const TextStyle(fontSize: 18,color: Colors.white, ),
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
