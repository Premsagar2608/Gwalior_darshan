import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // 🔗 Function to launch Email
  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'Premsagar998186@gmail.com',
      query: 'subject=Support Needed&body=Hello, I need help regarding...',
    );

    if (!await launchUrl(emailUri)) {
      throw "Could not open email app";
    }
  }

  // 🔗 Function to launch Phone Dialer
  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+919981863663',
    );

    if (!await launchUrl(phoneUri)) {
      throw "Could not open dialer";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Us",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1746A2),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HEADER
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFF1746A2),
                  child: const Icon(Icons.support_agent, color: Colors.white, size: 35),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    "We're Here to Help You!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // EMAIL (Clickable)
            GestureDetector(
              onTap: _launchEmail,
              child: contactTile(
                icon: Icons.email,
                title: "Email Support",
                subtitle: "Premsagar998186@gmail.com",
              ),
            ),

            const SizedBox(height: 10),

            // PHONE (Clickable)
            GestureDetector(
              onTap: _launchPhone,
              child: contactTile(
                icon: Icons.phone,
                title: "Phone Support",
                subtitle: "+91 9981863663",
              ),
            ),

            const SizedBox(height: 10),

            // ADDRESS
            contactTile(
              icon: Icons.location_on,
              title: "Office Address",
              subtitle: "Gwalior, Madhya Pradesh, India",
            ),

            const SizedBox(height: 30),

            const Text(
              "We usually respond within 24 hours.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget contactTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Color(0xFF1746A2)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(fontSize: 15, color: Colors.grey)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
