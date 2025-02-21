// terms_of_use.dart
import 'package:flutter/material.dart';

import 'legal_page_template.dart';

class TermsOfUse extends StatelessWidget {
  final List<Map<String, dynamic>> sections = [
    {
      'title': '1. Acceptance of Terms',
      'content': [
        'By accessing or using Questra ("Service"), you:',
        '- Confirm you are at least 13 years old',
        '- Agree to be bound by these Terms',
        '- Acknowledge our Privacy Policy',
        '- Accept responsibility for all activities',
        'If disagreeing with terms, you must immediately cease use.',
      ]
    },
    {
      'title': '2. Account Responsibilities',
      'content': [
        'You are solely responsible for:',
        '- Maintaining account confidentiality',
        '- All activities under your account',
        '- Providing accurate information',
        '- Compliance with applicable laws',
        '- Any content you create/share',
        'Immediately notify us of unauthorized use.',
      ]
    },
    {
      'title': '3. Service Modifications',
      'content': [
        'We reserve the right to:',
        '- Modify or discontinue Service at any time',
        '- Change pricing structure',
        '- Limit/terminate free tier access',
        '- Update Terms without notice',
        'Continued use constitutes acceptance of changes.',
      ]
    },
    {
      'title': '4. User Content',
      'content': [
        'You retain ownership but grant us:',
        '- Worldwide, non-exclusive license',
        '- Right to use, copy, and display content',
        '- Right to analyze for service improvement',
        'Prohibited content includes:',
        '- Illegal or infringing material',
        '- Malware/spam',
        '- NSFW or harmful content',
      ]
    },
    {
      'title': '5. Limitation of Liability',
      'content': [
        'To the maximum extent permitted by law:',
        '- We exclude all warranties',
        '- Not liable for indirect damages',
        '- Not liable for data loss',
        '- Not liable for service interruptions',
        '- Not liable for third-party actions',
        'Total liability limited to fees paid.',
      ]
    },
    {
      'title': '6. Termination',
      'content': [
        'We may terminate access for:',
        '- Violations of these Terms',
        '- Security reasons',
        '- Inactive accounts (6+ months)',
        '- Any reason without notice',
        'Termination results in:',
        '- Loss of XP and virtual items',
        '- Account deletion',
        '- Forfeiture of subscriptions',
      ]
    },
  ];

  TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageTemplate(
      title: 'Terms of Use',
      sections: sections,
    );
  }
}
