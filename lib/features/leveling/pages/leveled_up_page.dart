import 'dart:developer';

import 'package:questra_app/core/providers/leveling_providers.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';
import 'dart:math' as math;
import 'package:rive/rive.dart';

class LeveledUpPage extends ConsumerStatefulWidget {
  const LeveledUpPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LeveledUpPageState();
}

class _LeveledUpPageState extends ConsumerState<LeveledUpPage> {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<double>? _numberInput;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String btnString = '';
  final _strings = [
    "BOW BEFORE ME 👑",
    "WITNESS GREATNESS ⚡",
    "I AM POWER 🔥",
    "KNEEL, MORTALS 💀",
    "THE LEGEND CONTINUES 🚀",
    "NONE CAN MATCH ME 💪",
  ];

  final _arStrings = [
    "شاهدوا العظمة ⚡",
    "أنا القوة 🔥",
    "الأسطورة مستمرة 🚀",
    "لا أحد يمكنه مجارتي 💪",
  ];

  Future<void> _load() async {
    final rand = math.Random.secure();
    bool isArabic = ref.read(localeProvider).languageCode == 'ar';
    setState(() {
      if (isArabic) {
        btnString = _strings[rand.nextInt(_arStrings.length)];
      } else {
        btnString = _strings[rand.nextInt(_strings.length)];
      }
    });

    final cachedLevel = ref.read(cachedUserLevelProvider);

    final file =
        ref.read(levelUpRiveFileProvider) ??
        await RiveFile.asset('assets/rive/level_display_modifed.riv');

    final artboard = file.mainArtboard;

    // Create a copy of the artboard to avoid conflicts
    final artboardCopy = artboard.instance();

    // Look at the UI in the second screenshot, it shows "Number 1" as the input name
    final controller = StateMachineController.fromArtboard(artboardCopy, 'State Machine 1');

    if (controller != null) {
      artboardCopy.addController(controller);
      setState(() => _riveArtboard = artboardCopy);

      // Try "Number 1" as seen in the community files screenshot
      _numberInput = controller.findInput<double>('Number 1');

      _controller = controller;

      log("Setting initial level to 1");
      changeLevel(cachedLevel?.level ?? 1);
      await Future.delayed(const Duration(milliseconds: 500), () {
        ref.read(soundEffectsServiceProvider).playFirstTada();
        changeLevel((cachedLevel?.level ?? 1) + 1);
      });
    }
  }

  void changeLevel(int level) {
    setState(() {
      log("new level $level");
      if (_numberInput != null) {
        _numberInput!.value = level.toDouble();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_riveArtboard != null)
                  SizedBox(width: 200, height: 200, child: Rive(artboard: _riveArtboard!))
                else ...[
                  BeatLoader(),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 10),
                GlowText(
                  text: "Level UP!",
                  glowColor: AppColors.primary,
                  style: TextStyle(
                    fontFamily: AppFonts.header,
                    fontSize: 24,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  AppLocalizations.of(context).level_up_description,
                  style: TextStyle(color: AppColors.descriptionColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SystemCardButton(onTap: () => context.pop(), text: btnString),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
