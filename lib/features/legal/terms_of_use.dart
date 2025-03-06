import 'package:flutter/material.dart';
import 'package:questra_app/generated/app_localizations.dart';

import 'legal_page_template.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalPageTemplate(
      title: AppLocalizations.of(context).terms_of_use_title,
      sections: [
        {
          'title': AppLocalizations.of(context).terms_acceptance_title,
          'content': [
            AppLocalizations.of(context).terms_acceptance_content_1,
            AppLocalizations.of(context).terms_acceptance_content_2,
            AppLocalizations.of(context).terms_acceptance_content_3,
            AppLocalizations.of(context).terms_acceptance_content_4,
            AppLocalizations.of(context).terms_acceptance_content_5,
            AppLocalizations.of(context).terms_acceptance_content_6,
          ],
        },
        {
          'title': AppLocalizations.of(context).account_responsibilities_title,
          'content': [
            AppLocalizations.of(context).account_responsibilities_content_1,
            AppLocalizations.of(context).account_responsibilities_content_2,
            AppLocalizations.of(context).account_responsibilities_content_3,
            AppLocalizations.of(context).account_responsibilities_content_4,
            AppLocalizations.of(context).account_responsibilities_content_5,
            AppLocalizations.of(context).account_responsibilities_content_6,
            AppLocalizations.of(context).account_responsibilities_content_7,
          ],
        },
        {
          'title': AppLocalizations.of(context).service_modifications_title,
          'content': [
            AppLocalizations.of(context).service_modifications_content_1,
            AppLocalizations.of(context).service_modifications_content_2,
            AppLocalizations.of(context).service_modifications_content_3,
            AppLocalizations.of(context).service_modifications_content_4,
            AppLocalizations.of(context).service_modifications_content_5,
            AppLocalizations.of(context).service_modifications_content_6,
          ],
        },
        {
          'title': AppLocalizations.of(context).user_content_title,
          'content': [
            AppLocalizations.of(context).user_content_content_1,
            AppLocalizations.of(context).user_content_content_2,
            AppLocalizations.of(context).user_content_content_3,
            AppLocalizations.of(context).user_content_content_4,
            AppLocalizations.of(context).user_content_content_5,
            AppLocalizations.of(context).user_content_content_6,
            AppLocalizations.of(context).user_content_content_7,
            AppLocalizations.of(context).user_content_content_8,
          ],
        },
        {
          'title': AppLocalizations.of(context).limitation_of_liability_title,
          'content': [
            AppLocalizations.of(context).limitation_of_liability_content_1,
            AppLocalizations.of(context).limitation_of_liability_content_2,
            AppLocalizations.of(context).limitation_of_liability_content_3,
            AppLocalizations.of(context).limitation_of_liability_content_4,
            AppLocalizations.of(context).limitation_of_liability_content_5,
            AppLocalizations.of(context).limitation_of_liability_content_6,
            AppLocalizations.of(context).limitation_of_liability_content_7,
          ],
        },
        {
          'title': AppLocalizations.of(context).termination_title,
          'content': [
            AppLocalizations.of(context).termination_content_1,
            AppLocalizations.of(context).termination_content_2,
            AppLocalizations.of(context).termination_content_3,
            AppLocalizations.of(context).termination_content_4,
            AppLocalizations.of(context).termination_content_5,
            AppLocalizations.of(context).termination_content_6,
            AppLocalizations.of(context).termination_content_7,
            AppLocalizations.of(context).termination_content_8,
            AppLocalizations.of(context).termination_content_9,
          ],
        },
      ],
    );
  }
}
