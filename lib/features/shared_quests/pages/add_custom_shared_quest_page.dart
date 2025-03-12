// ignore_for_file: deprecated_member_use

import 'package:questra_app/imports.dart';

class AddCustomSharedQuestPage extends ConsumerStatefulWidget {
  const AddCustomSharedQuestPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddCustomSharedQuestPageState();
}

class _AddCustomSharedQuestPageState extends ConsumerState<AddCustomSharedQuestPage> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(questsControllerProvider);
    final size = MediaQuery.sizeOf(context);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    return WillPopScope(
      onWillPop: () async {
        if (isLoading) {
          CustomToast.systemToast(AppLocalizations.of(context).custom_quest_add_alert);
          return false;
        }
        return true;
      },
      child: BackgroundWidget(
        child: Scaffold(
          appBar: TheAppBar(title: AppLocalizations.of(context).custom_quest_add_appbar_title),
          body: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: SystemCard(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).custom_quest_add_card_title,
                              style: TextStyle(
                                fontFamily: isArabic ? null : AppFonts.header,
                                fontWeight: isArabic ? FontWeight.bold : null,
                                fontSize: 18,
                              ),
                            ),
                            Icon(LucideIcons.diamond, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 15),
                        buildQuestForm(size),
                        const SizedBox(height: 15),
                        Text(
                          AppLocalizations.of(context).custom_quest_add_card_note,
                          style: TextStyle(fontSize: 12, color: Colors.white60),
                        ),
                        const SizedBox(height: 10),
                        if (isLoading) ...[BeatLoader()] else ...[SystemCardButton(onTap: () {})],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox buildQuestForm(Size size) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: size.width * .25),
      child: TextField(
        // controller: _controller,
        maxLines: null,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          filled: false,
          border: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
          hintStyle: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 14,
            color: Colors.white.withValues(alpha: .86),
          ),
          hintText: AppLocalizations.of(context).custom_quest_add_field_hint,
        ),
      ),
    );
  }
}
