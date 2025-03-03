import 'package:animate_do/animate_do.dart';
import 'package:questra_app/core/enums/religions_enum.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/features/profiles/controller/profile_controller.dart';
import 'package:questra_app/imports.dart';

class DefineReligionPage extends ConsumerStatefulWidget {
  const DefineReligionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DefineReligionPageState();
}

class _DefineReligionPageState extends ConsumerState<DefineReligionPage> {
  List<Map<String, dynamic>> get religions => [
    // 'christianity', 'islam', 'hinduism', 'buddhism', 'judaism', 'atheist'
    {'key': 'christianity', 'value': AppLocalizations.of(context).christianity},
    {'key': 'islam', 'value': AppLocalizations.of(context).islam},
    {'key': 'hinduism', 'value': AppLocalizations.of(context).hinduism},
    {'key': 'buddhism', 'value': AppLocalizations.of(context).buddhism},
    {'key': 'judaism', 'value': AppLocalizations.of(context).judaism},
    {'key': 'atheist', 'value': AppLocalizations.of(context).atheist},
  ];
  String? selected;

  void finish() {
    if (selected != null) {
      final user = ref.read(authStateProvider);
      ref
          .read(profileControllerProvider.notifier)
          .defineReligion(userId: user!.id, religion: stringToReligion(selected!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileControllerProvider);
    return BackgroundWidget(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GlowText(
                  text: AppLocalizations.of(context).choose_your_religion,
                  glowColor: AppColors.primary,
                  style: TextStyle(fontFamily: AppFonts.header, fontSize: 22),
                ).tada(),
                const SizedBox(height: 30),
                Wrap(
                  // spacing: 10,
                  runSpacing: 15,
                  children:
                      religions.map((r) {
                        bool _selected = r['key'] == selected;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected == r['key']) {
                                selected = null;
                                return;
                              }
                              selected = r['key'];
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  _selected
                                      ? Colors.purple.withValues(alpha: .1)
                                      : AppColors.primary.withValues(alpha: .1),
                              border: Border.all(
                                color: _selected ? Colors.purple : AppColors.primary,
                              ),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(r['value']),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
                const SizedBox(height: 30),
                Visibility(
                  visible: selected != null,
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  child:
                      isLoading
                          ? BeatLoader()
                          : AnimatedOpacity(
                            opacity: selected != null ? 1 : 0,
                            duration: const Duration(milliseconds: 400),
                            child: SystemCardButton(onTap: finish),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
