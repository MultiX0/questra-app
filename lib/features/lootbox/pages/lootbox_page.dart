import 'package:animate_do/animate_do.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/features/lootbox/controller/lootbox_controller.dart';
import 'package:questra_app/features/lootbox/utils/random_reward.dart';
import 'package:questra_app/imports.dart';
import 'package:rive/rive.dart';

class LootboxPage extends ConsumerStatefulWidget {
  const LootboxPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LootboxPageState();
}

class _LootboxPageState extends ConsumerState<LootboxPage> {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  SMIInput<bool>? _tapped;
  int reward = getReward();

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

  Future<void> _load() async {
    ref.read(soundEffectsServiceProvider).playFirstTada();
    final file = await RiveFile.asset('assets/rive/chest.riv');

    final artboard = file.mainArtboard;

    // Create a copy of the artboard to avoid conflicts
    final artboardCopy = artboard.instance();

    // Look at the UI in the second screenshot, it shows "Number 1" as the input name
    final controller = StateMachineController.fromArtboard(artboardCopy, 'State Machine');

    if (controller != null) {
      artboardCopy.addController(controller);
      setState(() => _riveArtboard = artboardCopy);

      _tapped = controller.findInput<bool>('Tapped');

      _controller = controller;
    }
  }

  void finish() {
    final user = ref.read(authStateProvider);
    ref.read(lootBoxControllerProvider.notifier).reciveReward(userId: user!.id, amount: reward);
  }

  @override
  Widget build(BuildContext context) {
    bool tappedBool = _tapped?.value ?? false;
    final isLoading = ref.watch(lootBoxControllerProvider);

    void tapped() {
      if (tappedBool) return;
      ref.read(soundEffectsServiceProvider).playCoinsRecived();

      setState(() {
        if (_tapped != null) {
          _tapped!.value = true;
          reward = getReward();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: .85),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_riveArtboard != null)
              Center(
                child: AnimatedContainer(
                  duration: const Duration(seconds: 300),

                  width: 200,
                  height: 200,
                  child: GestureDetector(
                    onTap: tapped,
                    child: Rive(artboard: _riveArtboard!).bounceInDown(from: 0),
                  ),
                ),
              )
            else ...[
              BeatLoader(),
              const SizedBox(height: 10),
            ],
            Visibility(
              visible: tappedBool,
              maintainState: true,
              maintainSize: false,
              maintainAnimation: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    opacity: tappedBool ? 1 : 0,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                    child: Text(
                      textAlign: TextAlign.center,
                      "WELL, WELL, LOOK WHO GOT LUCKY!",
                      style: TextStyle(
                        fontFamily: AppFonts.header,
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ).tada(duration: const Duration(milliseconds: 1200)),
                  ),
                  const SizedBox(height: 10),
                  AnimatedOpacity(
                    opacity: tappedBool ? 1 : 0,
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.easeOut,
                    child: Text(
                      textAlign: TextAlign.center,
                      "What’s this? A loot box? Did the game accidentally mistake you for someone important? Nah, just kidding—you’re obviously a legend.",
                      style: TextStyle(
                        // color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  AnimatedOpacity(
                    opacity: tappedBool ? 1 : 0,
                    duration: const Duration(milliseconds: 2800),
                    curve: Curves.easeOut,
                    child: Text(
                      textAlign: TextAlign.center,
                      "💰 Inside: A glorious stash of coins ($reward).\n🎲 Luck is just skill you didn’t plan for.",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 35),

                  AnimatedOpacity(
                    opacity: tappedBool ? 1 : 0,
                    duration: const Duration(milliseconds: 4000),
                    curve: Curves.easeOut,
                    child:
                        isLoading
                            ? BeatLoader()
                            : SystemCardButton(onTap: finish, text: "GIMME MY MONEY 💰"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
