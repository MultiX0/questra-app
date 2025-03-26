// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/gestures.dart';
// ignore: unnecessary_import
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/auth/controller/auth_controller.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:url_launcher/url_launcher_string.dart';

class OnboardingFirstPage extends ConsumerStatefulWidget {
  const OnboardingFirstPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OnboardingFirstPageState();
}

class _OnboardingFirstPageState extends ConsumerState<OnboardingFirstPage> {
  bool hover = false;
  bool get isArabic => ref.watch(localeProvider).languageCode == 'ar';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLoading = ref.watch(authControllerProvider);

    void handleLogin() async {
      ref.read(soundEffectsServiceProvider).playEffect('default_btn.aac');
      if (isLoading) return;
      await ref.read(authControllerProvider.notifier).login();
    }

    void hangleLangChange() {
      final currentLang = ref.read(localeProvider);
      if (currentLang.languageCode == 'en') {
        ref.read(localeProvider.notifier).state = Locale("ar");
      } else {
        ref.read(localeProvider.notifier).state = Locale("en");
      }
    }

    return OnboardingBg(
      child: Scaffold(
        appBar: AppBar(
          actions: [IconButton(onPressed: hangleLangChange, icon: Icon(LucideIcons.languages))],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Assets.getImage('splash_icon.png'), fit: BoxFit.cover).swing(),
              const SizedBox(height: 30),
              GlowText(
                text: AppLocalizations.of(context).firstPageTitle,
                textAlign: TextAlign.center,
                glowColor: AppColors.primary,
                spreadRadius: .75,
                blurRadius: 30,
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: isArabic ? null : AppFonts.header,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ).fadeInDown(duration: const Duration(milliseconds: 900)),
              const SizedBox(height: 15),
              GlowText(
                text: AppLocalizations.of(context).firstPageSubtitle,
                textAlign: TextAlign.center,
                glowColor: Colors.white,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                blurRadius: 3,
              ).fadeInUp(duration: const Duration(milliseconds: 1000)),
              const SizedBox(height: 35),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: GestureDetector(
                  onLongPress: () {
                    log("message");
                    setState(() {
                      hover = true;
                    });
                  },
                  onLongPressEnd: (_) {
                    log("cancel");
                    setState(() {
                      hover = false;
                    });
                  },
                  child: GlowButton(
                    spreadRadius: 1.5,
                    blurRadius: 20,
                    glowColor: AppColors.primary.withValues(alpha: 0.4),
                    color: Color.fromARGB(151, 99, 206, 255),
                    onPressed: handleLogin,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: size.width * .35),
                    child:
                        isLoading
                            ? BeatLoader()
                            : Text(AppLocalizations.of(context).firstPageButtonTitle),
                  ).tada(duration: const Duration(milliseconds: 1100), infinite: hover),
                ),
              ),
              const SizedBox(height: 10),
              buildReachText(context),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Padding buildReachText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: RichText(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AppLocalizations.of(context).firstPageTermsPart1,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.descriptionColor,

            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: AppLocalizations.of(context).firstPageTermsPart2,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 12,

                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () async {
                      // context.push(Routes.termsPage);
                      await launchUrlString(termsUrl);
                    },
            ),
            TextSpan(
              text: AppLocalizations.of(context).firstPageTermsPart3,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.whiteColor,
                fontSize: 12,

                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: AppLocalizations.of(context).firstPageTermsPart4,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontSize: 12,

                decoration: TextDecoration.underline,
              ),
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () async {
                      // context.push(Routes.privacyPage);
                      await launchUrlString(termsUrl);
                    },
            ),
          ],
        ),
      ).fadeInUp(duration: const Duration(milliseconds: 1200)),
    );
  }
}
