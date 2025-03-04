import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';

class UserQuestTypes extends ConsumerStatefulWidget {
  const UserQuestTypes({super.key, required this.next, required this.prev});

  final VoidCallback prev;
  final VoidCallback next;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserQuestTypesState();
}

class _UserQuestTypesState extends ConsumerState<UserQuestTypes> {
  List<int> typeIds = [];

  void handleNext() {
    ref.read(soundEffectsServiceProvider).playMainButtonEffect();

    if (typeIds.length > 8 || typeIds.length < 5) {
      CustomToast.systemToast(
        AppLocalizations.of(context).you_need_to_select_5_to_8_quest_types,
        systemMessage: true,
      );
      return;
    }

    final localUser = ref.read(localUserProvider);
    final updatedPrefs = localUser?.user_preferences?.copyWith(questTypes: typeIds);
    log("the quest types of this user is $updatedPrefs");
    ref.read(localUserProvider.notifier).state = localUser?.copyWith(
      user_preferences: updatedPrefs,
    );

    widget.next();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final typesRef = ref.watch(getAllQuestTypesProvider);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    return OnboardingBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: AccountSetupNextButton(next: handleNext, size: size),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.1),
              OnboardingTitle(title: AppLocalizations.of(context).preferences),
              SizedBox(height: size.height * 0.05),
              GlowText(
                text: AppLocalizations.of(context).quest_types,
                spreadRadius: 1,
                blurRadius: 25,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: AppFonts.primary,
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                glowColor: Colors.white,
              ),
              SizedBox(height: size.height * 0.025),
              Expanded(
                child: SingleChildScrollView(
                  child: typesRef.when(
                    data: (types) {
                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            types
                                .map(
                                  (type) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (typeIds.contains(type.id)) {
                                          typeIds.remove(type.id);
                                        } else {
                                          typeIds.add(type.id);
                                        }
                                      });
                                    },
                                    child:
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          margin: EdgeInsets.only(top: 5),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: .4),
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                              color:
                                                  typeIds.contains(type.id)
                                                      ? Colors.purpleAccent
                                                      : HexColor('7AD5FF'),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    typeIds.contains(type.id)
                                                        ? Colors.purpleAccent.withValues(alpha: .3)
                                                        : HexColor('7AD5FF').withValues(alpha: .3),
                                                spreadRadius: 0.25,
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            isArabic ? type.arName : type.name,
                                            style: TextStyle(color: AppColors.whiteColor),
                                          ),
                                        ).swing(),
                                  ),
                                )
                                .toList(),
                      );
                    },
                    error: (error, _) => Center(child: Text(AppLocalizations.of(context).error)),
                    loading: () => BeatLoader(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
