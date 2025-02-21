// privacy_policy.dart
import 'package:flutter/material.dart';
import 'legal_page_template.dart';

class PrivacyPolicy extends StatelessWidget {
  final List<Map<String, dynamic>> sections = [
    {
      'title': '1. Information We Collect',
      'content': [
        'We may collect the following personal information:',
        '- Email address',
        '- Name and account credentials',
        '- Birth date and gender',
        '- Activity level and fitness goals',
        '- Geolocation data (when required for features)',
        '- User-generated content including quest photos',
        '- Device information and usage statistics',
      ]
    },
    {
      'title': '2. Use of Information',
      'content': [
        'Collected data is used to:',
        '- Provide and maintain the Service',
        '- Improve AI models and personalization',
        '- Develop new features and functionality',
        '- Deliver targeted advertisements',
        '- Conduct research and analysis',
        '- Prevent fraud and ensure security',
        'We do not sell your personal data to third parties.',
      ]
    },
    {
      'title': '3. Data Sharing',
      'content': [
        'We may share information with:',
        '- Service providers and contractors',
        '- Legal authorities when required',
        '- Business partners (anonymous aggregate only)',
        '- Successors in case of merger/acquisition',
        'Third parties are contractually bound to protect your data.',
      ]
    },
    {
      'title': '4. Data Security',
      'content': [
        'Security measures include:',
        '- AES-256 encryption at rest and in transit',
        '- Regular security audits',
        '- Access controls and 2FA',
        '- Anonymization where possible',
        'While we implement industry standards, no system is 100% secure.',
      ]
    },
    {
      'title': '5. Your Rights',
      'content': [
        'You have the right to:',
        '- Access your personal data',
        '- Request data deletion',
        '- Update/correct inaccuracies',
        '- Opt-out of data collection',
        '- Export your data',
        '- Withdraw consent',
        'Submit requests to: privacy@devaven.com',
      ]
    },
    {
      'title': '6. Policy Changes',
      'content': [
        'We may update this policy:',
        '- Changes effective immediately upon posting',
        '- No obligation to notify users individually',
        '- Continued use constitutes acceptance',
        '- Historical versions available on request',
      ]
    },
  ];

  PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageTemplate(
      title: 'Privacy Policy',
      sections: sections,
    );
  }
}
