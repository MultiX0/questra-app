import 'package:questra_app/features/preferences/models/user_preferences_model.dart';
import 'package:questra_app/imports.dart';

final localeProvider = StateProvider<Locale>((ref) => Locale('en'));
final localUserPereferencesState = StateProvider<UserPreferencesModel?>((ref) => null);
