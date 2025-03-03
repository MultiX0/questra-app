import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Questra'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Questra!'**
  String get welcomeMessage;

  /// No description provided for @firstPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Level Up Your Life!'**
  String get firstPageTitle;

  /// No description provided for @firstPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Embark on your personalized\nquest journey now'**
  String get firstPageSubtitle;

  /// No description provided for @firstPageButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Level up!'**
  String get firstPageButtonTitle;

  /// No description provided for @firstPageTermsPart1.
  ///
  /// In en, this message translates to:
  /// **'By clicking the login button, you agree to '**
  String get firstPageTermsPart1;

  /// No description provided for @firstPageTermsPart2.
  ///
  /// In en, this message translates to:
  /// **'Terms '**
  String get firstPageTermsPart2;

  /// No description provided for @firstPageTermsPart3.
  ///
  /// In en, this message translates to:
  /// **'and '**
  String get firstPageTermsPart3;

  /// No description provided for @firstPageTermsPart4.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get firstPageTermsPart4;

  /// No description provided for @terms_acceptance_title.
  ///
  /// In en, this message translates to:
  /// **'1. Acceptance of Terms'**
  String get terms_acceptance_title;

  /// No description provided for @terms_acceptance_content_1.
  ///
  /// In en, this message translates to:
  /// **'By accessing or using Questra (\"Service\"), you:'**
  String get terms_acceptance_content_1;

  /// No description provided for @terms_acceptance_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Confirm you are at least 13 years old'**
  String get terms_acceptance_content_2;

  /// No description provided for @terms_acceptance_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Agree to be bound by these Terms'**
  String get terms_acceptance_content_3;

  /// No description provided for @terms_acceptance_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Acknowledge our Privacy Policy'**
  String get terms_acceptance_content_4;

  /// No description provided for @terms_acceptance_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Accept responsibility for all activities'**
  String get terms_acceptance_content_5;

  /// No description provided for @terms_acceptance_content_6.
  ///
  /// In en, this message translates to:
  /// **'If disagreeing with terms, you must immediately cease use.'**
  String get terms_acceptance_content_6;

  /// No description provided for @terms_of_use_title.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get terms_of_use_title;

  /// No description provided for @account_responsibilities_title.
  ///
  /// In en, this message translates to:
  /// **'2. Account Responsibilities'**
  String get account_responsibilities_title;

  /// No description provided for @account_responsibilities_content_1.
  ///
  /// In en, this message translates to:
  /// **'You are solely responsible for:'**
  String get account_responsibilities_content_1;

  /// No description provided for @account_responsibilities_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Maintaining account confidentiality'**
  String get account_responsibilities_content_2;

  /// No description provided for @account_responsibilities_content_3.
  ///
  /// In en, this message translates to:
  /// **'- All activities under your account'**
  String get account_responsibilities_content_3;

  /// No description provided for @account_responsibilities_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Providing accurate information'**
  String get account_responsibilities_content_4;

  /// No description provided for @account_responsibilities_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Compliance with applicable laws'**
  String get account_responsibilities_content_5;

  /// No description provided for @account_responsibilities_content_6.
  ///
  /// In en, this message translates to:
  /// **'- Any content you create/share'**
  String get account_responsibilities_content_6;

  /// No description provided for @account_responsibilities_content_7.
  ///
  /// In en, this message translates to:
  /// **'Immediately notify us of unauthorized use.'**
  String get account_responsibilities_content_7;

  /// No description provided for @service_modifications_title.
  ///
  /// In en, this message translates to:
  /// **'3. Service Modifications'**
  String get service_modifications_title;

  /// No description provided for @service_modifications_content_1.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to:'**
  String get service_modifications_content_1;

  /// No description provided for @service_modifications_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Modify or discontinue Service at any time'**
  String get service_modifications_content_2;

  /// No description provided for @service_modifications_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Change pricing structure'**
  String get service_modifications_content_3;

  /// No description provided for @service_modifications_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Limit/terminate free tier access'**
  String get service_modifications_content_4;

  /// No description provided for @service_modifications_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Update Terms without notice'**
  String get service_modifications_content_5;

  /// No description provided for @service_modifications_content_6.
  ///
  /// In en, this message translates to:
  /// **'Continued use constitutes acceptance of changes.'**
  String get service_modifications_content_6;

  /// No description provided for @user_content_title.
  ///
  /// In en, this message translates to:
  /// **'4. User Content'**
  String get user_content_title;

  /// No description provided for @user_content_content_1.
  ///
  /// In en, this message translates to:
  /// **'You retain ownership but grant us:'**
  String get user_content_content_1;

  /// No description provided for @user_content_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Worldwide, non-exclusive license'**
  String get user_content_content_2;

  /// No description provided for @user_content_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Right to use, copy, and display content'**
  String get user_content_content_3;

  /// No description provided for @user_content_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Right to analyze for service improvement'**
  String get user_content_content_4;

  /// No description provided for @user_content_content_5.
  ///
  /// In en, this message translates to:
  /// **'Prohibited content includes:'**
  String get user_content_content_5;

  /// No description provided for @user_content_content_6.
  ///
  /// In en, this message translates to:
  /// **'- Illegal or infringing material'**
  String get user_content_content_6;

  /// No description provided for @user_content_content_7.
  ///
  /// In en, this message translates to:
  /// **'- Malware/spam'**
  String get user_content_content_7;

  /// No description provided for @user_content_content_8.
  ///
  /// In en, this message translates to:
  /// **'- NSFW or harmful content'**
  String get user_content_content_8;

  /// No description provided for @limitation_of_liability_title.
  ///
  /// In en, this message translates to:
  /// **'5. Limitation of Liability'**
  String get limitation_of_liability_title;

  /// No description provided for @limitation_of_liability_content_1.
  ///
  /// In en, this message translates to:
  /// **'To the maximum extent permitted by law:'**
  String get limitation_of_liability_content_1;

  /// No description provided for @limitation_of_liability_content_2.
  ///
  /// In en, this message translates to:
  /// **'- We exclude all warranties'**
  String get limitation_of_liability_content_2;

  /// No description provided for @limitation_of_liability_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Not liable for indirect damages'**
  String get limitation_of_liability_content_3;

  /// No description provided for @limitation_of_liability_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Not liable for data loss'**
  String get limitation_of_liability_content_4;

  /// No description provided for @limitation_of_liability_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Not liable for service interruptions'**
  String get limitation_of_liability_content_5;

  /// No description provided for @limitation_of_liability_content_6.
  ///
  /// In en, this message translates to:
  /// **'- Not liable for third-party actions'**
  String get limitation_of_liability_content_6;

  /// No description provided for @limitation_of_liability_content_7.
  ///
  /// In en, this message translates to:
  /// **'Total liability limited to fees paid.'**
  String get limitation_of_liability_content_7;

  /// No description provided for @termination_title.
  ///
  /// In en, this message translates to:
  /// **'6. Termination'**
  String get termination_title;

  /// No description provided for @termination_content_1.
  ///
  /// In en, this message translates to:
  /// **'We may terminate access for:'**
  String get termination_content_1;

  /// No description provided for @termination_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Violations of these Terms'**
  String get termination_content_2;

  /// No description provided for @termination_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Security reasons'**
  String get termination_content_3;

  /// No description provided for @termination_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Inactive accounts (6+ months)'**
  String get termination_content_4;

  /// No description provided for @termination_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Any reason without notice'**
  String get termination_content_5;

  /// No description provided for @termination_content_6.
  ///
  /// In en, this message translates to:
  /// **'Termination results in:'**
  String get termination_content_6;

  /// No description provided for @termination_content_7.
  ///
  /// In en, this message translates to:
  /// **'- Loss of XP and virtual items'**
  String get termination_content_7;

  /// No description provided for @termination_content_8.
  ///
  /// In en, this message translates to:
  /// **'- Account deletion'**
  String get termination_content_8;

  /// No description provided for @termination_content_9.
  ///
  /// In en, this message translates to:
  /// **'- Forfeiture of subscriptions'**
  String get termination_content_9;

  /// No description provided for @privacy_policy_title.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy_title;

  /// No description provided for @information_we_collect_title.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get information_we_collect_title;

  /// No description provided for @information_we_collect_content_1.
  ///
  /// In en, this message translates to:
  /// **'We may collect the following personal information:'**
  String get information_we_collect_content_1;

  /// No description provided for @information_we_collect_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Email address'**
  String get information_we_collect_content_2;

  /// No description provided for @information_we_collect_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Name and account credentials'**
  String get information_we_collect_content_3;

  /// No description provided for @information_we_collect_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Birth date and gender'**
  String get information_we_collect_content_4;

  /// No description provided for @information_we_collect_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Activity level and fitness goals'**
  String get information_we_collect_content_5;

  /// No description provided for @information_we_collect_content_6.
  ///
  /// In en, this message translates to:
  /// **'- Geolocation data (when required for features)'**
  String get information_we_collect_content_6;

  /// No description provided for @information_we_collect_content_7.
  ///
  /// In en, this message translates to:
  /// **'- User-generated content including quest photos'**
  String get information_we_collect_content_7;

  /// No description provided for @information_we_collect_content_8.
  ///
  /// In en, this message translates to:
  /// **'- Device information and usage statistics'**
  String get information_we_collect_content_8;

  /// No description provided for @use_of_information_title.
  ///
  /// In en, this message translates to:
  /// **'2. Use of Information'**
  String get use_of_information_title;

  /// No description provided for @use_of_information_content_1.
  ///
  /// In en, this message translates to:
  /// **'Collected data is used to:'**
  String get use_of_information_content_1;

  /// No description provided for @use_of_information_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Provide and maintain the Service'**
  String get use_of_information_content_2;

  /// No description provided for @use_of_information_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Improve AI models and personalization'**
  String get use_of_information_content_3;

  /// No description provided for @use_of_information_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Develop new features and functionality'**
  String get use_of_information_content_4;

  /// No description provided for @use_of_information_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Deliver targeted advertisements'**
  String get use_of_information_content_5;

  /// No description provided for @use_of_information_content_6.
  ///
  /// In en, this message translates to:
  /// **'- Conduct research and analysis'**
  String get use_of_information_content_6;

  /// No description provided for @use_of_information_content_7.
  ///
  /// In en, this message translates to:
  /// **'- Prevent fraud and ensure security'**
  String get use_of_information_content_7;

  /// No description provided for @use_of_information_content_8.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your personal data to third parties.'**
  String get use_of_information_content_8;

  /// No description provided for @data_sharing_title.
  ///
  /// In en, this message translates to:
  /// **'3. Data Sharing'**
  String get data_sharing_title;

  /// No description provided for @data_sharing_content_1.
  ///
  /// In en, this message translates to:
  /// **'We may share information with:'**
  String get data_sharing_content_1;

  /// No description provided for @data_sharing_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Service providers and contractors'**
  String get data_sharing_content_2;

  /// No description provided for @data_sharing_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Legal authorities when required'**
  String get data_sharing_content_3;

  /// No description provided for @data_sharing_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Business partners (anonymous aggregate only)'**
  String get data_sharing_content_4;

  /// No description provided for @data_sharing_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Successors in case of merger/acquisition'**
  String get data_sharing_content_5;

  /// No description provided for @data_sharing_content_6.
  ///
  /// In en, this message translates to:
  /// **'Third parties are contractually bound to protect your data.'**
  String get data_sharing_content_6;

  /// No description provided for @data_security_title.
  ///
  /// In en, this message translates to:
  /// **'4. Data Security'**
  String get data_security_title;

  /// No description provided for @data_security_content_1.
  ///
  /// In en, this message translates to:
  /// **'Security measures include:'**
  String get data_security_content_1;

  /// No description provided for @data_security_content_2.
  ///
  /// In en, this message translates to:
  /// **'- AES-256 encryption at rest and in transit'**
  String get data_security_content_2;

  /// No description provided for @data_security_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Regular security audits'**
  String get data_security_content_3;

  /// No description provided for @data_security_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Access controls and 2FA'**
  String get data_security_content_4;

  /// No description provided for @data_security_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Anonymization where possible'**
  String get data_security_content_5;

  /// No description provided for @data_security_content_6.
  ///
  /// In en, this message translates to:
  /// **'While we implement industry standards, no system is 100% secure.'**
  String get data_security_content_6;

  /// No description provided for @your_rights_title.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get your_rights_title;

  /// No description provided for @your_rights_content_1.
  ///
  /// In en, this message translates to:
  /// **'You have the right to:'**
  String get your_rights_content_1;

  /// No description provided for @your_rights_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Access your personal data'**
  String get your_rights_content_2;

  /// No description provided for @your_rights_content_3.
  ///
  /// In en, this message translates to:
  /// **'- Request data deletion'**
  String get your_rights_content_3;

  /// No description provided for @your_rights_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Update/correct inaccuracies'**
  String get your_rights_content_4;

  /// No description provided for @your_rights_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Opt-out of data collection'**
  String get your_rights_content_5;

  /// No description provided for @your_rights_content_6.
  ///
  /// In en, this message translates to:
  /// **'- Export your data'**
  String get your_rights_content_6;

  /// No description provided for @your_rights_content_7.
  ///
  /// In en, this message translates to:
  /// **'- Withdraw consent'**
  String get your_rights_content_7;

  /// No description provided for @your_rights_content_8.
  ///
  /// In en, this message translates to:
  /// **'Submit requests to: privacy@devaven.com'**
  String get your_rights_content_8;

  /// No description provided for @policy_changes_title.
  ///
  /// In en, this message translates to:
  /// **'6. Policy Changes'**
  String get policy_changes_title;

  /// No description provided for @policy_changes_content_1.
  ///
  /// In en, this message translates to:
  /// **'We may update this policy:'**
  String get policy_changes_content_1;

  /// No description provided for @policy_changes_content_2.
  ///
  /// In en, this message translates to:
  /// **'- Changes effective immediately upon posting'**
  String get policy_changes_content_2;

  /// No description provided for @policy_changes_content_3.
  ///
  /// In en, this message translates to:
  /// **'- No obligation to notify users individually'**
  String get policy_changes_content_3;

  /// No description provided for @policy_changes_content_4.
  ///
  /// In en, this message translates to:
  /// **'- Continued use constitutes acceptance'**
  String get policy_changes_content_4;

  /// No description provided for @policy_changes_content_5.
  ///
  /// In en, this message translates to:
  /// **'- Historical versions available on request'**
  String get policy_changes_content_5;

  /// No description provided for @legal_copyright.
  ///
  /// In en, this message translates to:
  /// **'Questra. All rights reserved.'**
  String get legal_copyright;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @last_updated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: '**
  String get last_updated;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get full_name;

  /// No description provided for @player_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Player name ...'**
  String get player_name_hint;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @player_username_hint.
  ///
  /// In en, this message translates to:
  /// **'Player username (unique) e.g: multix...'**
  String get player_username_hint;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @player_birthday_hint.
  ///
  /// In en, this message translates to:
  /// **'Player Birthday ...'**
  String get player_birthday_hint;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @player_gender_hint.
  ///
  /// In en, this message translates to:
  /// **'Player Gender ...'**
  String get player_gender_hint;

  /// No description provided for @fitness_activity.
  ///
  /// In en, this message translates to:
  /// **'Fitness/Activity'**
  String get fitness_activity;

  /// No description provided for @general_fitness_activity_hint.
  ///
  /// In en, this message translates to:
  /// **'General fitness/activity level'**
  String get general_fitness_activity_hint;

  /// No description provided for @select_gender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get select_gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @select_fitness_activity_level.
  ///
  /// In en, this message translates to:
  /// **'Select fitness/activity level'**
  String get select_fitness_activity_level;

  /// No description provided for @sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get sedentary;

  /// No description provided for @lightly_active.
  ///
  /// In en, this message translates to:
  /// **'Lightly active'**
  String get lightly_active;

  /// No description provided for @moderately_active.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get moderately_active;

  /// No description provided for @very_active.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get very_active;

  /// No description provided for @athletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get athletic;

  /// No description provided for @please_enter_valid_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid name'**
  String get please_enter_valid_name;

  /// No description provided for @name_should_be_more_than_4_characters.
  ///
  /// In en, this message translates to:
  /// **'The name should contain at least 4 characters'**
  String get name_should_be_more_than_4_characters;

  /// No description provided for @enter_valid_username.
  ///
  /// In en, this message translates to:
  /// **'Enter valid username please'**
  String get enter_valid_username;

  /// No description provided for @username_should_be_more_than_4_characters.
  ///
  /// In en, this message translates to:
  /// **'The username should contain at least 4 characters'**
  String get username_should_be_more_than_4_characters;

  /// No description provided for @please_enter_birth_date.
  ///
  /// In en, this message translates to:
  /// **'Please enter your birth date'**
  String get please_enter_birth_date;

  /// No description provided for @please_select_gender.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get please_select_gender;

  /// No description provided for @please_select_fitness_activity_level.
  ///
  /// In en, this message translates to:
  /// **'Please select your fitness/activity level'**
  String get please_select_fitness_activity_level;

  /// No description provided for @the_username_is_taken.
  ///
  /// In en, this message translates to:
  /// **'The username ({username}) is already taken'**
  String the_username_is_taken(Object username);

  /// No description provided for @please_fill_all_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all the fields!'**
  String get please_fill_all_fields;

  /// No description provided for @on_boarding_title.
  ///
  /// In en, this message translates to:
  /// **'Be a player now!'**
  String get on_boarding_title;

  /// No description provided for @on_boarding_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the adventure! Share your details to get personalized quests and start leveling up!'**
  String get on_boarding_subtitle;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @social_interactions.
  ///
  /// In en, this message translates to:
  /// **'Social Interactions'**
  String get social_interactions;

  /// No description provided for @select_social_interactions.
  ///
  /// In en, this message translates to:
  /// **'Select social interactions'**
  String get select_social_interactions;

  /// No description provided for @gamified_social_challenges.
  ///
  /// In en, this message translates to:
  /// **'Solo Explorer'**
  String get gamified_social_challenges;

  /// No description provided for @story_driven_social_quests.
  ///
  /// In en, this message translates to:
  /// **'Friendly Collaborator'**
  String get story_driven_social_quests;

  /// No description provided for @community_based_engagement.
  ///
  /// In en, this message translates to:
  /// **'Friendly Collaborator'**
  String get community_based_engagement;

  /// No description provided for @simulated_social_scenarios.
  ///
  /// In en, this message translates to:
  /// **'Competitive Challenger'**
  String get simulated_social_scenarios;

  /// No description provided for @virtual_collaboration.
  ///
  /// In en, this message translates to:
  /// **'Casual Engager'**
  String get virtual_collaboration;

  /// No description provided for @interactive_forums_or_chatrooms.
  ///
  /// In en, this message translates to:
  /// **'Silent Observer'**
  String get interactive_forums_or_chatrooms;

  /// No description provided for @acts_of_kindness.
  ///
  /// In en, this message translates to:
  /// **'Troll Master'**
  String get acts_of_kindness;

  /// No description provided for @real_world_social_prompts.
  ///
  /// In en, this message translates to:
  /// **'Real-World Social Prompts'**
  String get real_world_social_prompts;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @select_availability_per_day.
  ///
  /// In en, this message translates to:
  /// **'Select availability per day'**
  String get select_availability_per_day;

  /// No description provided for @more_than_1_hour.
  ///
  /// In en, this message translates to:
  /// **'More than 1 hour'**
  String get more_than_1_hour;

  /// No description provided for @less_than_1_hour.
  ///
  /// In en, this message translates to:
  /// **'Less than 1 hour'**
  String get less_than_1_hour;

  /// No description provided for @exactly_1_hour.
  ///
  /// In en, this message translates to:
  /// **'Exactly 1 hour'**
  String get exactly_1_hour;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @select_quests_difficulty.
  ///
  /// In en, this message translates to:
  /// **'Select quests difficulty'**
  String get select_quests_difficulty;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @please_select_your_social_interactions.
  ///
  /// In en, this message translates to:
  /// **'Please select your social interactions'**
  String get please_select_your_social_interactions;

  /// No description provided for @please_select_your_availability.
  ///
  /// In en, this message translates to:
  /// **'Please select your availability'**
  String get please_select_your_availability;

  /// No description provided for @please_select_your_difficulty.
  ///
  /// In en, this message translates to:
  /// **'Please select your difficulty'**
  String get please_select_your_difficulty;

  /// No description provided for @social_interactions_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g (Cooperative)'**
  String get social_interactions_hint;

  /// No description provided for @availability_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g (1 hour per day)'**
  String get availability_hint;

  /// No description provided for @difficulty_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g (Medium)'**
  String get difficulty_hint;

  /// No description provided for @social_interactions_label.
  ///
  /// In en, this message translates to:
  /// **'social interactions'**
  String get social_interactions_label;

  /// No description provided for @availability_label.
  ///
  /// In en, this message translates to:
  /// **'availability'**
  String get availability_label;

  /// No description provided for @difficulty_label.
  ///
  /// In en, this message translates to:
  /// **'difficulty'**
  String get difficulty_label;

  /// No description provided for @next_button.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next_button;

  /// No description provided for @report_quest.
  ///
  /// In en, this message translates to:
  /// **'Report a Quest'**
  String get report_quest;

  /// No description provided for @submitted_at.
  ///
  /// In en, this message translates to:
  /// **'submitted at {date}'**
  String submitted_at(Object date);

  /// No description provided for @nothing_here.
  ///
  /// In en, this message translates to:
  /// **'NOTHING HERE!'**
  String get nothing_here;

  /// No description provided for @no_mission_completed.
  ///
  /// In en, this message translates to:
  /// **'This player has not completed the mission even once yet.'**
  String get no_mission_completed;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'refresh'**
  String get refresh;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'report'**
  String get report;

  /// No description provided for @confirm_report.
  ///
  /// In en, this message translates to:
  /// **'Confirm Report'**
  String get confirm_report;

  /// No description provided for @report_confirmation_message.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to report this player? Reports should only be submitted for valid reasons. False reports may lead to penalties.'**
  String get report_confirmation_message;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm_and_report.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Report'**
  String get confirm_and_report;

  /// No description provided for @show_menu.
  ///
  /// In en, this message translates to:
  /// **'Show menu'**
  String get show_menu;

  /// No description provided for @false_completion_claim.
  ///
  /// In en, this message translates to:
  /// **'False completion claim'**
  String get false_completion_claim;

  /// No description provided for @unrelated_proof_image.
  ///
  /// In en, this message translates to:
  /// **'Unrelated proof image'**
  String get unrelated_proof_image;

  /// No description provided for @cheating_or_unfair_play.
  ///
  /// In en, this message translates to:
  /// **'Cheating or unfair play'**
  String get cheating_or_unfair_play;

  /// No description provided for @inappropriate_content.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get inappropriate_content;

  /// No description provided for @spam_or_fake_quest.
  ///
  /// In en, this message translates to:
  /// **'Spam or fake quest'**
  String get spam_or_fake_quest;

  /// No description provided for @harassment_or_abuse.
  ///
  /// In en, this message translates to:
  /// **'Harassment or abuse'**
  String get harassment_or_abuse;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @feedback_hint.
  ///
  /// In en, this message translates to:
  /// **'hint: Your feedback helps the system to understand more about your needs to make better quests for you.'**
  String get feedback_hint;

  /// No description provided for @please_fill_the_feedback_type.
  ///
  /// In en, this message translates to:
  /// **'Please fill the feedback type'**
  String get please_fill_the_feedback_type;

  /// No description provided for @please_fill_the_feedback_field.
  ///
  /// In en, this message translates to:
  /// **'Please fill the feedback field'**
  String get please_fill_the_feedback_field;

  /// No description provided for @select_feedback_type.
  ///
  /// In en, this message translates to:
  /// **'Select feedback type'**
  String get select_feedback_type;

  /// No description provided for @please_enter_your_feedback_here.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback here ...'**
  String get please_enter_your_feedback_here;

  /// No description provided for @difficulty_level.
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficulty_level;

  /// No description provided for @relevance.
  ///
  /// In en, this message translates to:
  /// **'Relevance'**
  String get relevance;

  /// No description provided for @time_required.
  ///
  /// In en, this message translates to:
  /// **'Time Required'**
  String get time_required;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @clarity.
  ///
  /// In en, this message translates to:
  /// **'Clarity'**
  String get clarity;

  /// No description provided for @engagement.
  ///
  /// In en, this message translates to:
  /// **'Engagement'**
  String get engagement;

  /// No description provided for @other_suggestions.
  ///
  /// In en, this message translates to:
  /// **'Other Suggestions'**
  String get other_suggestions;

  /// No description provided for @christianity.
  ///
  /// In en, this message translates to:
  /// **'Christianity'**
  String get christianity;

  /// No description provided for @islam.
  ///
  /// In en, this message translates to:
  /// **'Islam'**
  String get islam;

  /// No description provided for @hinduism.
  ///
  /// In en, this message translates to:
  /// **'Hinduism'**
  String get hinduism;

  /// No description provided for @buddhism.
  ///
  /// In en, this message translates to:
  /// **'Buddhism'**
  String get buddhism;

  /// No description provided for @judaism.
  ///
  /// In en, this message translates to:
  /// **'Judaism'**
  String get judaism;

  /// No description provided for @atheist.
  ///
  /// In en, this message translates to:
  /// **'Atheist'**
  String get atheist;

  /// No description provided for @choose_your_religion.
  ///
  /// In en, this message translates to:
  /// **'Choose your religion'**
  String get choose_your_religion;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get done;

  /// No description provided for @it_seems_we_facing_an_error_please_try_again.
  ///
  /// In en, this message translates to:
  /// **'it seems we facing an error please try again'**
  String get it_seems_we_facing_an_error_please_try_again;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @settings_up.
  ///
  /// In en, this message translates to:
  /// **'We prepare '**
  String get settings_up;

  /// No description provided for @your.
  ///
  /// In en, this message translates to:
  /// **'your '**
  String get your;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'account'**
  String get account;

  /// No description provided for @your_goals.
  ///
  /// In en, this message translates to:
  /// **''**
  String get your_goals;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @enter_your_goals.
  ///
  /// In en, this message translates to:
  /// **'enter your goals (very importnant)'**
  String get enter_your_goals;

  /// No description provided for @goals_alert.
  ///
  /// In en, this message translates to:
  /// **'add at least 4 clear goals with specific content, (you can edit or add new goals later)'**
  String get goals_alert;

  /// No description provided for @quest_types.
  ///
  /// In en, this message translates to:
  /// **'Quest types'**
  String get quest_types;

  /// No description provided for @you_need_to_select_5_to_8_quest_types.
  ///
  /// In en, this message translates to:
  /// **'You need to select 5 to 8 quest types'**
  String get you_need_to_select_5_to_8_quest_types;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @marketplace_title.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace_title;

  /// No description provided for @marketplace_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover exclusive items, power-ups, and gear to level up your journey. Spend your coins and enhance your adventure!'**
  String get marketplace_subtitle;

  /// No description provided for @active_title.
  ///
  /// In en, this message translates to:
  /// **'Active Title'**
  String get active_title;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @quest_title.
  ///
  /// In en, this message translates to:
  /// **'Quest Title'**
  String get quest_title;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @quest.
  ///
  /// In en, this message translates to:
  /// **'Quest'**
  String get quest;

  /// No description provided for @custom_quest.
  ///
  /// In en, this message translates to:
  /// **'Custom Quest'**
  String get custom_quest;

  /// No description provided for @custom_quest_empty.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any custom quests right now. Would you like to add a new quest?'**
  String get custom_quest_empty;

  /// No description provided for @add_quest.
  ///
  /// In en, this message translates to:
  /// **'add quests'**
  String get add_quest;

  /// No description provided for @custom_quest_requirements.
  ///
  /// In en, this message translates to:
  /// **'You need to reach level 5 to be able to create your own quests.'**
  String get custom_quest_requirements;

  /// No description provided for @custom_quest_level_locked.
  ///
  /// In en, this message translates to:
  /// **'Locked (opens at LVL 5)'**
  String get custom_quest_level_locked;

  /// No description provided for @quests_archive.
  ///
  /// In en, this message translates to:
  /// **'Quests Archive'**
  String get quests_archive;

  /// No description provided for @quests.
  ///
  /// In en, this message translates to:
  /// **'Quests'**
  String get quests;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @quest_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get quest_status;

  /// No description provided for @empty_quest_archive.
  ///
  /// In en, this message translates to:
  /// **'There is no quests in the archive for now'**
  String get empty_quest_archive;

  /// No description provided for @view_more.
  ///
  /// In en, this message translates to:
  /// **'view more'**
  String get view_more;

  /// No description provided for @empty_quests.
  ///
  /// In en, this message translates to:
  /// **'You don’t have any active quests right now. Would you like to embark on a new quest?\n\n(using ai)'**
  String get empty_quests;

  /// No description provided for @quest_generation_toast.
  ///
  /// In en, this message translates to:
  /// **'making new quest for you'**
  String get quest_generation_toast;

  /// No description provided for @wait_until.
  ///
  /// In en, this message translates to:
  /// **'you need to wait until'**
  String get wait_until;

  /// No description provided for @quest_finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get quest_finished;

  /// No description provided for @quest_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get quest_failed;

  /// No description provided for @quest_status_card_title.
  ///
  /// In en, this message translates to:
  /// **'Quest Status is ?'**
  String get quest_status_card_title;

  /// No description provided for @quest_complete_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are You Sure You’ve Completed the Quest?'**
  String get quest_complete_confirmation;

  /// No description provided for @quest_finish_alert1.
  ///
  /// In en, this message translates to:
  /// **'Completing a quest is an honorable achievement! However, if you claim completion without truly finishing, you may face penalties'**
  String get quest_finish_alert1;

  /// No description provided for @quest_finish_alert2.
  ///
  /// In en, this message translates to:
  /// **'· Lose Your Current Streak.\n· Forfeit Earned XP.\n· Block your account!'**
  String get quest_finish_alert2;

  /// No description provided for @quest_finish_alert3.
  ///
  /// In en, this message translates to:
  /// **'· Be honest, adventurer—your reputation and progress depend on it. Are you ready to confirm quest completion?'**
  String get quest_finish_alert3;

  /// No description provided for @quest_finish_btn1.
  ///
  /// In en, this message translates to:
  /// **'Yes, I’ve Completed It'**
  String get quest_finish_btn1;

  /// No description provided for @quest_finish_btn2.
  ///
  /// In en, this message translates to:
  /// **'No, I’ll Keep Working'**
  String get quest_finish_btn2;

  /// No description provided for @image_upload_count_alert.
  ///
  /// In en, this message translates to:
  /// **'You need to add at least {minImagesCount} photos.'**
  String image_upload_count_alert(Object minImagesCount);

  /// No description provided for @image_submit_card_title.
  ///
  /// In en, this message translates to:
  /// **'Provide some pictures from your results please.'**
  String get image_submit_card_title;

  /// No description provided for @image_submit_card_note.
  ///
  /// In en, this message translates to:
  /// **'Note: for more safety for your account from false reports we suggest at least to select one image for the quest that you\'ve done.'**
  String get image_submit_card_note;

  /// No description provided for @free_coins.
  ///
  /// In en, this message translates to:
  /// **'Free Coins ?'**
  String get free_coins;

  /// No description provided for @free_coins_amount.
  ///
  /// In en, this message translates to:
  /// **'{amount} coins per AD'**
  String free_coins_amount(Object amount);

  /// No description provided for @free_coins_button.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get free_coins_button;

  /// No description provided for @marketplace_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get marketplace_categories;

  /// No description provided for @soon.
  ///
  /// In en, this message translates to:
  /// **'soon'**
  String get soon;

  /// No description provided for @marketplace_item_locked_toast.
  ///
  /// In en, this message translates to:
  /// **'this item is locked for now'**
  String get marketplace_item_locked_toast;

  /// No description provided for @marketplace_item_locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get marketplace_item_locked;

  /// No description provided for @marketplace_empty.
  ///
  /// In en, this message translates to:
  /// **'There is no items'**
  String get marketplace_empty;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'cost'**
  String get cost;

  /// No description provided for @buy_btn.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy_btn;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profile_custom_quests.
  ///
  /// In en, this message translates to:
  /// **'Custom Quests'**
  String get profile_custom_quests;

  /// No description provided for @profile_titles.
  ///
  /// In en, this message translates to:
  /// **'Titels'**
  String get profile_titles;

  /// No description provided for @profile_goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get profile_goals;

  /// No description provided for @profile_achivments.
  ///
  /// In en, this message translates to:
  /// **'Achivment'**
  String get profile_achivments;

  /// No description provided for @profile_guild.
  ///
  /// In en, this message translates to:
  /// **'Guild'**
  String get profile_guild;

  /// No description provided for @profile_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profile_friends;

  /// No description provided for @add_goal_alert.
  ///
  /// In en, this message translates to:
  /// **'Goal should be contains at lease 8 characters'**
  String get add_goal_alert;

  /// No description provided for @add_goal_card_title.
  ///
  /// In en, this message translates to:
  /// **'NEW GOAL!'**
  String get add_goal_card_title;

  /// No description provided for @add_goal_card_note.
  ///
  /// In en, this message translates to:
  /// **'hint: Your goals help the system to understand more about your needs to make better quests for you.'**
  String get add_goal_card_note;

  /// No description provided for @delete_goal_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get delete_goal_title;

  /// No description provided for @delete_goal_readme.
  ///
  /// In en, this message translates to:
  /// **'readme: Your goals help the system to understand more about your needs to make better quests for you.\ndo you want to delete this goal?'**
  String get delete_goal_readme;

  /// No description provided for @add_goal_hint.
  ///
  /// In en, this message translates to:
  /// **'please enter your goal here'**
  String get add_goal_hint;

  /// No description provided for @titles_empty.
  ///
  /// In en, this message translates to:
  /// **'There is no titles for now'**
  String get titles_empty;

  /// No description provided for @titles_empty_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get titles_empty_refresh;

  /// No description provided for @titles_change_title_message.
  ///
  /// In en, this message translates to:
  /// **'do you want to change\nyour current active title?'**
  String get titles_change_title_message;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'yes'**
  String get yes;

  /// No description provided for @owned_at.
  ///
  /// In en, this message translates to:
  /// **'owned at'**
  String get owned_at;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @your_rank.
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get your_rank;

  /// No description provided for @leaderboard_buttons1.
  ///
  /// In en, this message translates to:
  /// **'Global'**
  String get leaderboard_buttons1;

  /// No description provided for @leaderboard_buttons2.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get leaderboard_buttons2;

  /// No description provided for @event_join_title.
  ///
  /// In en, this message translates to:
  /// **'🌟 Exclusive Event: {title} – Register Now!'**
  String event_join_title(Object title);

  /// No description provided for @event_join_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Be part of something special! Join {title} on Questra and experience an unforgettable event filled with unique opportunities. Secure your spot today and stay updated with all the latest details. Don\'t miss out! 🎉🚀'**
  String event_join_subtitle(Object title);

  /// No description provided for @event_join_fee.
  ///
  /// In en, this message translates to:
  /// **'registration fee is'**
  String get event_join_fee;

  /// No description provided for @event_register_btn.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get event_register_btn;

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @total_participants.
  ///
  /// In en, this message translates to:
  /// **'Total number of participants'**
  String get total_participants;

  /// No description provided for @view_quest.
  ///
  /// In en, this message translates to:
  /// **'View Quest'**
  String get view_quest;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @player_quests_title.
  ///
  /// In en, this message translates to:
  /// **'Player Quests'**
  String get player_quests_title;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'skip'**
  String get skip;

  /// No description provided for @delete_custom_quest.
  ///
  /// In en, this message translates to:
  /// **'delete'**
  String get delete_custom_quest;

  /// No description provided for @quest_completetion_card_title.
  ///
  /// In en, this message translates to:
  /// **'Victory Achieved, Hero!'**
  String get quest_completetion_card_title;

  /// No description provided for @quest_completetion_card_description.
  ///
  /// In en, this message translates to:
  /// **'Your dedication and skills have led you to triumph. The realm celebrates your success great rewards await you!'**
  String get quest_completetion_card_description;

  /// No description provided for @quest_completetion_card_reward.
  ///
  /// In en, this message translates to:
  /// **'- Your reward is: {xp_reward}XP, {coin_reward}\$ coins'**
  String quest_completetion_card_reward(Object coin_reward, Object xp_reward);

  /// No description provided for @quest_completetion_card_title_earned.
  ///
  /// In en, this message translates to:
  /// **'- Earned title: {owned_title}'**
  String quest_completetion_card_title_earned(Object owned_title);

  /// No description provided for @level_up_description.
  ///
  /// In en, this message translates to:
  /// **'This isn’t just a level-up—it’s proof of your grind, your will, and your power. Weaklings stay the same. You? You evolve.'**
  String get level_up_description;

  /// No description provided for @lootbox_title.
  ///
  /// In en, this message translates to:
  /// **'WELL, WELL, LOOK WHO GOT LUCKY!'**
  String get lootbox_title;

  /// No description provided for @lootbox_description.
  ///
  /// In en, this message translates to:
  /// **'What’s this? A loot box? Did the game accidentally mistake you for someone important? Nah, just kidding—you’re obviously a legend.'**
  String get lootbox_description;

  /// No description provided for @lootbox_description2.
  ///
  /// In en, this message translates to:
  /// **'💰 Inside: A glorious stash of coins (\$reward).\n🎲 Luck is just skill you didn’t plan for.'**
  String lootbox_description2(Object reward);

  /// No description provided for @lootbox_btn.
  ///
  /// In en, this message translates to:
  /// **'GIMME MY MONEY 💰'**
  String get lootbox_btn;

  /// No description provided for @avatar_update.
  ///
  /// In en, this message translates to:
  /// **'Update Your Avatar.'**
  String get avatar_update;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
