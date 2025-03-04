// ignore_for_file: use_build_context_synchronously

import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/events/controller/events_controller.dart';
import 'package:questra_app/features/events/models/event_model.dart';
import 'package:questra_app/imports.dart';
import 'package:zo_animated_border/zo_animated_border.dart';

class EventsCaruosel extends ConsumerWidget {
  const EventsCaruosel({super.key, required this.events});

  final List<EventModel> events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return const SizedBox.shrink(); // Or a placeholder widget
    }
    final isLoading = ref.watch(eventsControllerProvider);
    bool isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final user = ref.watch(authStateProvider);
    return ExpandableCarousel.builder(
      key: ValueKey('quest-carousel-${events.length}'),
      options: ExpandableCarouselOptions(
        autoPlay: events.length > 1,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 1,
        autoPlayCurve: Curves.ease,
        enableInfiniteScroll: events.length > 1,
        enlargeCenterPage: true,
        floatingIndicator: true,
        showIndicator: false,
      ),
      itemCount: events.length,
      itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
        final event = events[itemIndex];
        return KeyedSubtree(
          key: ValueKey('event-${event.id}'), // Assuming quest has an id field
          child: AspectRatio(
            aspectRatio: 16 / 8,
            child: GestureDetector(
              onTap: () async {
                ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                ref.read(selectedQuestEvent.notifier).state = event;
                final registered = await ref
                    .read(eventsControllerProvider.notifier)
                    .isRegisteredInEvent(userId: user!.id, eventId: event.id);

                if (registered) {
                  context.push(Routes.eventQuestsPage);
                } else {
                  context.push(Routes.registerToEventPage);
                }
              },
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
                    image:
                        event.thumbnail == null
                            ? null
                            : DecorationImage(
                              image: CachedNetworkImageProvider(event.thumbnail!),
                              fit: BoxFit.cover,
                            ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black.withValues(alpha: .75),
                    ),
                    child: Center(
                      child:
                          isLoading
                              ? BeatLoader()
                              : GlowText(
                                text: isArabic ? event.ar_title ?? event.title : event.title,
                                glowColor: AppColors.primary,
                                style: TextStyle(
                                  fontFamily: isArabic ? null : AppFonts.header,
                                  fontWeight: isArabic ? FontWeight.bold : null,
                                  fontSize: 24,
                                ),
                              ).tada(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).elasticInDown();
  }
}
