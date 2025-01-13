import 'package:questra_app/features/app/widgets/dashboard_quest_widget.dart';
import 'package:questra_app/features/app/widgets/user_dashboard_widget.dart';
import 'package:questra_app/imports.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final duration = const Duration(seconds: 2);
    // final size = MediaQuery.sizeOf(context);

    return BackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TheAppBar(
          title: 'Questra',
          // actions: [
          // IconButton(
          // onPressed: () {
          // ref.read(aiFunctionsProvider).generateQuests();
          // },
          // icon: Icon(LucideIcons.hexagon),
          // ),
          // ],
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 2),
            children: [
              const SizedBox(
                height: 15,
              ),
              SystemCard(
                duration: duration,
                onTap: () {
                  CustomToast.systemToast("the shop is comming soon!");
                },
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlowText(
                      blurRadius: 20,
                      spreadRadius: 0.75,
                      glowColor: AppColors.whiteColor,
                      text: "Marketplace",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: AppFonts.header,
                        color: AppColors.whiteColor,
                      ),
                      // glowColor: AppColors.whiteColor,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    GlowText(
                      blurRadius: 20,
                      spreadRadius: 0.5,
                      glowColor: AppColors.whiteColor,
                      text:
                          "Discover exclusive items, power-ups, and gear to level up your journey. Spend your coins and enhance your adventure!",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: AppFonts.primary,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              UserDashboardWidget(),
              const SizedBox(
                height: 15,
              ),
              DashboardQuestWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
