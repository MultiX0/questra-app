import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';
import 'package:zo_animated_border/widget/zo_dual_border.dart';

class SharedQuestsCard extends ConsumerWidget {
  const SharedQuestsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: ZoDualBorder(
          duration: Duration(seconds: 5),
          glowOpacity: 0.3,
          firstBorderColor: AppColors.primary,
          secondBorderColor: AppColors.primary.withValues(alpha: .5),
          trackBorderColor: Colors.transparent,
          borderWidth: 4,
          borderRadius: BorderRadius.circular(12),
          padding: EdgeInsets.all(5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://ijetdkekpdlnbyrnirfe.supabase.co/storage/v1/object/public/public_stotage//shared_quests.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withValues(alpha: .65),
              ),
              child: Center(
                child: GlowText(
                  text: AppLocalizations.of(context).shared_quests,
                  glowColor: AppColors.primary,
                  style: TextStyle(
                    fontFamily: isArabic ? null : AppFonts.header,
                    fontWeight: isArabic ? FontWeight.bold : null,
                    fontSize: 24,
                  ),
                ).tada(duration: const Duration(milliseconds: 2000)),
              ),
            ),
          ),
        ).bounceInDown(duration: const Duration(milliseconds: 1800)),
      ),
    );
  }
}
