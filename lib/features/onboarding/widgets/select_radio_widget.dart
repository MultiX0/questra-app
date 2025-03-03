import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';

class SelectRadioWidget extends ConsumerStatefulWidget {
  const SelectRadioWidget({
    super.key,
    required this.changeVal,
    required this.group,
    required this.choices,
    required this.title,
  });

  final Function(Map<String, dynamic>) changeVal;
  final Map<String, dynamic> group;
  final List<Map<String, dynamic>> choices;
  final String title;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectSelectAvtivityLevelWidgetState();
}

class _SelectSelectAvtivityLevelWidgetState extends ConsumerState<SelectRadioWidget> {
  Map<String, dynamic> selectedGender = {};

  @override
  void initState() {
    super.initState();
    selectedGender = widget.group;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: GlowText(
              text: widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                fontFamily: AppFonts.primary,
                color: AppColors.primary,
              ),
              spreadRadius: 1,
              blurRadius: 20,
              glowColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 15),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ...widget.choices.map(
                  (activity) => RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: activity['key'],
                    groupValue: selectedGender['key'],
                    onChanged: (v) {
                      ref.read(soundEffectsServiceProvider).playSystemButtonClick();
                      if (v != null) {
                        // Find the corresponding map from choices
                        final selectedMap = widget.choices.firstWhere(
                          (element) => element['key'] == v,
                          orElse: () => activity,
                        );

                        setState(() {
                          selectedGender = selectedMap;
                        });
                        widget.changeVal(selectedMap);
                      }
                    },
                    activeColor: AppColors.primary,
                    title: Text(
                      activity['value'],
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.whiteColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
