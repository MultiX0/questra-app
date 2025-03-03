import 'package:animate_do/animate_do.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/events/controller/events_controller.dart';
import 'package:questra_app/imports.dart';

class RegisterToEventPage extends ConsumerStatefulWidget {
  const RegisterToEventPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterToEventPageState();
}

class _RegisterToEventPageState extends ConsumerState<RegisterToEventPage> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);

    final event = ref.watch(selectedQuestEvent);
    final isLoading = ref.watch(eventsControllerProvider);

    void register() {
      ref
          .read(eventsControllerProvider.notifier)
          .registerToEvent(eventId: event!.id, context: context, user: user!);
    }

    return BackgroundWidget(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlowText(
                  text: "🌟 Exclusive Event: ${event?.title} – Register Now!",
                  glowColor: AppColors.primary,
                  style: TextStyle(
                    fontFamily: AppFonts.header,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ).tada(),
                const SizedBox(height: 20),
                Text(
                  "Be part of something special! Join ${event?.title} on Questra and experience an unforgettable event filled with unique opportunities. Secure your spot today and stay updated with all the latest details. Don't miss out! 🎉🚀",
                  style: TextStyle(color: AppColors.descriptionColor),
                  textAlign: TextAlign.center,
                ).fadeIn(duration: const Duration(milliseconds: 1400)),
                const SizedBox(height: 15),
                Text(
                  "registration fee is \$${calcEventRegisterationFee(user!.level!.level)}",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                if (isLoading)
                  BeatLoader()
                else
                  SystemCardButton(onTap: register, text: "Register Now").bounceIn(),
                const SizedBox(height: 15),

                SystemCardButton(
                  onTap: () => context.pop(),
                  text: "Cancel",
                  doneButton: false,
                ).bounceIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
