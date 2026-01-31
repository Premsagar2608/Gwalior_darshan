import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'Premsagar998186@gmail.com',
      query: 'subject=Support Needed&body=Hello, I need help regarding...',
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      throw "Could not open email app";
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '+919981863663',
    );

    if (!await launchUrl(phoneUri, mode: LaunchMode.externalApplication)) {
      throw "Could not open dialer";
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1746A2);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Contact Us",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: primaryBlue,
                  child: Icon(Icons.support_agent, color: Colors.white, size: 35),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Text(
                    "We're Here to Help You!",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // EMAIL (no email text shown)
            contactTile(
              icon: Icons.email,
              title: "Email Support",
              subtitle: "Contact us via email",
              trailing: ElevatedButton.icon(
                onPressed: _launchEmail,
                icon: const Icon(Icons.mail, size: 18),
                label: const Text("Email"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // PHONE (no number shown)
            contactTile(
              icon: Icons.phone,
              title: "Call Now",
              subtitle: "Talk to our support team",
              trailing: ElevatedButton.icon(
                onPressed: _launchPhone,
                icon: const Icon(Icons.call, size: 18),
                label: const Text("Call"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

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
    Widget? trailing,
  }) {
    const primaryBlue = Color(0xFF1746A2);

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
          Icon(icon, size: 30, color: primaryBlue),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 15, color: Colors.grey)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
