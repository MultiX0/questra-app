import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/features/profiles/controller/profile_controller.dart';
import 'package:questra_app/imports.dart';

import '../../../core/shared/widgets/beat_loader.dart';

class EnterCode extends ConsumerStatefulWidget {
  const EnterCode({
    super.key,
    required this.next,
    required this.prev,
  });

  final VoidCallback next;
  final VoidCallback prev;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EnterCodeState();
}

class _EnterCodeState extends ConsumerState<EnterCode> {
  late TextEditingController _controller;
  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: "Enter Code"),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: buildAddForm(),
          ),
        ),
      ),
    );
  }

  Widget buildAddForm() {
    final size = MediaQuery.sizeOf(context);
    final isLoading = ref.watch(profileControllerProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        child: Center(
          child: SystemCard(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Secret Code",
                      style: TextStyle(
                        fontFamily: AppFonts.header,
                        fontSize: 18,
                      ),
                    ),
                    Icon(
                      LucideIcons.sparkles,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                buildCodeForm(size),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  "hint: Your need an invite code to be able to signup",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                if (isLoading) ...[
                  BeatLoader(),
                ] else ...[
                  SystemCardButton(
                    onTap: finish,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void finish() {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    ref.read(profileControllerProvider.notifier).checkTheCode(
          _controller.text.trim(),
          userId,
          context: context,
        );
  }

  ConstrainedBox buildCodeForm(Size size) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: size.width * .25,
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        maxLength: 8,
        controller: _controller,
        maxLines: null,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          filled: false,
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w200,
            fontSize: 14,
            color: Colors.white.withValues(alpha: .86),
          ),
          hintText: "please enter your code here ...",
        ),
      ),
    );
  }
}
