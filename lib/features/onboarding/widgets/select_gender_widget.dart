import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/constants/app_fonts.dart';
import 'package:questra_app/shared/widgets/glow_text.dart';

class SelectGenderWidget extends ConsumerStatefulWidget {
  const SelectGenderWidget({
    super.key,
    required this.changeVal,
    required this.group,
  });

  final Function(String) changeVal;
  final String group;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectGenderWidgetState();
}

class _SelectGenderWidgetState extends ConsumerState<SelectGenderWidget> {
  String selectedGender = '';

  @override
  void initState() {
    super.initState();
    selectedGender = widget.group;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(25),
      shrinkWrap: true,
      children: [
        GlowText(
          text: "Select Gender",
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
        const SizedBox(height: 15),
        ...['m', 'f'].map(
          (g) => RadioListTile(
            contentPadding: EdgeInsets.zero,
            value: g,
            groupValue: selectedGender,
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  selectedGender = v;
                });
                widget.changeVal(v);
              }
            },
            activeColor: AppColors.primary,
            title: Text(
              g == 'm' ? "Male" : "Female",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
