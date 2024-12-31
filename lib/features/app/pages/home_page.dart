import 'package:questra_app/imports.dart';
import 'package:questra_app/shared/constants/app_fonts.dart';
import 'package:questra_app/shared/widgets/background_widget.dart';
import 'package:questra_app/shared/widgets/glow_text.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: ListView(
          children: [
            SizedBox(
              height: kToolbarHeight,
            ),
            Center(
              child: GlowText(
                glowColor: HexColor('7AD5FF').withValues(alpha: 0.8),
                text: "Questra",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: HexColor('7AD5FF'),
                  fontFamily: AppFonts.header,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
