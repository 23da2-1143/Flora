import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import '../../models/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    final languages = ['English (US)', 'French (FR)', 'Spanish (ES)', 'German (DE)'];
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Select Language',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: languages.map((lang) {
              final isSelected = settings.language == lang;
              return ListTile(
                title: Text(
                  lang,
                  style: GoogleFonts.lato(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.gold : null,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.gold) : null,
                onTap: () {
                  settings.setLanguage(lang);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showDocumentSheet(BuildContext context, String title, String textContent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          textContent,
                          style: GoogleFonts.lato(fontSize: 14, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: Text(
              'Push Notifications',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            value: settings.notificationsEnabled,
            activeThumbColor: AppColors.gold,
            onChanged: settings.toggleNotifications,
          ),
          const Divider(),
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            value: settings.isDarkMode,
            activeThumbColor: AppColors.gold,
            onChanged: settings.toggleDarkMode,
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Language',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settings.language,
                  style: GoogleFonts.lato(color: AppColors.lightGray, fontSize: 14),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightGray),
              ],
            ),
            onTap: () => _showLanguageDialog(context, settings),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Privacy Policy',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightGray),
            onTap: () => _showDocumentSheet(
              context,
              'Privacy Policy',
              _privacyPolicyContent,
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(
              'Terms of Service',
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.lightGray),
            onTap: () => _showDocumentSheet(
              context,
              'Terms of Service',
              _termsOfServiceContent,
            ),
          ),
        ],
      ),
    );
  }

  // ─── DOCUMENT MOCK CONTENTS ────────────────────────────────────────

  static const String _privacyPolicyContent = '''
Last Updated: May 20, 2026

Welcome to Flora & Fern. Your privacy is of the utmost importance to us. This Privacy Policy details how we collect, use, and safeguard your personal information when you use our mobile application.

1. Information Collection
We collect account information, including your full name, phone number, email address, physical delivery addresses, and payment preferences. This data is collected to facilitate secure transactions, authenticated account access, and prompt delivery services.

2. Database and Security
All information is processed and securely stored within Firebase Authentication and Google Cloud Firestore. We utilize strict Firestore Security Rules to prevent unauthorized read or write access to user details, wishlists, carts, and order details.

3. Analytics and Cookies
Our app optimizes real-time data flow to offer tailored product recommendations and browsing histories. No sensitive credit card details are stored directly on our servers.

4. Your Rights
You hold full rights to view, update, or completely delete your customer profile and account details from our database at any time.

For inquiries, contact us at support@floraandfern.com.
''';

  static const String _termsOfServiceContent = '''
Last Updated: May 20, 2026

Please read these Terms of Service ("Terms") carefully before using the Flora & Fern mobile application.

1. Agreement to Terms
By accessing or using our services, you agree to be bound by these Terms. If you disagree with any portion of the terms, you may not access our app.

2. Accounts
When creating an account, you must provide accurate, current, and complete information. You are solely responsible for safeguarding your password and account credentials.

3. Purchasing and Orders
We reserve the right to refuse or cancel any order for stock availability, description discrepancies, or suspected transaction issues. All shipping estimates (default Rs 10.00) are subject to local carrier logistics.

4. Intellectual Property
All original fashion templates, luxury styling, imagery, icons, custom source code, and design systems inside the Flora & Fern application are the exclusive property of Flora & Fern.

5. Limitation of Liability
Flora & Fern shall not be liable for any indirect, incidental, or consequential damages resulting from your use or inability to use our e-commerce platform.

For inquiries, contact us at support@floraandfern.com.
''';
}
