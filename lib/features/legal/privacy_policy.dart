import 'legal_page_template.dart';
import 'package:questra_app/imports.dart';

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> sections = [
      {
        'title': AppLocalizations.of(context).information_we_collect_title,
        'content': [
          AppLocalizations.of(context).information_we_collect_content_1,
          AppLocalizations.of(context).information_we_collect_content_2,
          AppLocalizations.of(context).information_we_collect_content_3,
          AppLocalizations.of(context).information_we_collect_content_4,
          AppLocalizations.of(context).information_we_collect_content_5,
          AppLocalizations.of(context).information_we_collect_content_6,
          AppLocalizations.of(context).information_we_collect_content_7,
          AppLocalizations.of(context).information_we_collect_content_8,
        ],
      },
      {
        'title': AppLocalizations.of(context).use_of_information_title,
        'content': [
          AppLocalizations.of(context).use_of_information_content_1,
          AppLocalizations.of(context).use_of_information_content_2,
          AppLocalizations.of(context).use_of_information_content_3,
          AppLocalizations.of(context).use_of_information_content_4,
          AppLocalizations.of(context).use_of_information_content_5,
          AppLocalizations.of(context).use_of_information_content_6,
          AppLocalizations.of(context).use_of_information_content_7,
          AppLocalizations.of(context).use_of_information_content_8,
        ],
      },
      {
        'title': AppLocalizations.of(context).data_sharing_title,
        'content': [
          AppLocalizations.of(context).data_sharing_content_1,
          AppLocalizations.of(context).data_sharing_content_2,
          AppLocalizations.of(context).data_sharing_content_3,
          AppLocalizations.of(context).data_sharing_content_4,
          AppLocalizations.of(context).data_sharing_content_5,
          AppLocalizations.of(context).data_sharing_content_6,
        ],
      },
      {
        'title': AppLocalizations.of(context).data_security_title,
        'content': [
          AppLocalizations.of(context).data_security_content_1,
          AppLocalizations.of(context).data_security_content_2,
          AppLocalizations.of(context).data_security_content_3,
          AppLocalizations.of(context).data_security_content_4,
          AppLocalizations.of(context).data_security_content_5,
          AppLocalizations.of(context).data_security_content_6,
        ],
      },
      {
        'title': AppLocalizations.of(context).your_rights_title,
        'content': [
          AppLocalizations.of(context).your_rights_content_1,
          AppLocalizations.of(context).your_rights_content_2,
          AppLocalizations.of(context).your_rights_content_3,
          AppLocalizations.of(context).your_rights_content_4,
          AppLocalizations.of(context).your_rights_content_5,
          AppLocalizations.of(context).your_rights_content_6,
          AppLocalizations.of(context).your_rights_content_7,
          AppLocalizations.of(context).your_rights_content_8,
        ],
      },
      {
        'title': AppLocalizations.of(context).policy_changes_title,
        'content': [
          AppLocalizations.of(context).policy_changes_content_1,
          AppLocalizations.of(context).policy_changes_content_2,
          AppLocalizations.of(context).policy_changes_content_3,
          AppLocalizations.of(context).policy_changes_content_4,
          AppLocalizations.of(context).policy_changes_content_5,
        ],
      },
    ];
    return LegalPageTemplate(
      title: AppLocalizations.of(context).privacy_policy_title,
      sections: sections,
    );
  }
}
