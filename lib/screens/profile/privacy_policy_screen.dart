import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            Text(
              "Privacy Policy",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Text(
              "Your privacy is important to us. This app does not collect any unnecessary personal information.",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),

            SizedBox(height: 20),

            Text(
              "Information We Collect",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "• Location (only for showing nearest places)\n"
                  "• Favourite places stored locally on your device\n"
                  "• App performance and analytics (anonymous)",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),

            SizedBox(height: 20),

            Text(
              "How We Use Information",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "• To show tourist places near you\n"
                  "• To improve app performance\n"
                  "• To enhance your browsing experience",
              style: TextStyle(fontSize: 16, height: 1.4),
            ),

            SizedBox(height: 20),

            Text(
              "Third-Party Services",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "We DO NOT share your personal data with anyone.",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 20),

            Text(
              "Contact Us",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "If you have questions, contact us at:\n"
                  "premsagar998186@gmail.com",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
