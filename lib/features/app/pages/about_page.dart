import 'package:questra_app/core/providers/package_into_provider.dart';
import 'package:questra_app/core/shared/widgets/glow_text.dart';
import 'package:questra_app/imports.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  final data = [
    {"name": "Donations", "icon": Icons.paypal, "url": "https://www.paypal.me/multix1"},
    {
      "name": "Instagram",
      "icon": LucideIcons.instagram,
      "url": "https://www.instagram.com/questra_app/",
    },
    {"name": "Discord", "icon": Icons.discord, "url": "https://discord.gg/8cK4SjDnjn"},
    {
      "name": "Tiktok",
      "icon": Icons.tiktok,
      "url": "https://www.tiktok.com/@questra.app?_t=ZM-8u8ABQ5JgwP&_r=1",
    },
    {"name": "Email", "icon": Icons.mail, "url": "mailto:support@devaven.com"},
  ];

  @override
  Widget build(BuildContext context) {
    final appVersion = ref.watch(appVersionProvider);
    final buildNumber = ref.watch(appBuildNumberProvider);
    final size = MediaQuery.sizeOf(context);
    return BackgroundWidget(
      child: Scaffold(
        appBar: TheAppBar(title: AppLocalizations.of(context).about_us_title),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: ListView(
              shrinkWrap: true,
              children: [
                Center(
                  child: GlowText(
                    text: "Q",
                    glowColor: AppColors.whiteColor,
                    blurRadius: 10,
                    spreadRadius: 0.1,
                    style: TextStyle(fontFamily: AppFonts.appLogo, fontSize: 148),
                  ),
                ),
                Center(
                  child: Text(
                    "App Version $appVersion.$buildNumber",
                    style: TextStyle(color: AppColors.descriptionColor, fontSize: 16),
                  ),
                ),
                SizedBox(height: size.width * .1),
                Center(
                  child: GlowText(
                    text: "our accounts",
                    glowColor: AppColors.primary,
                    blurRadius: 10,
                    spreadRadius: 0.1,
                    style: TextStyle(
                      fontFamily: AppFonts.header,
                      color: AppColors.primary,
                      fontSize: 18,
                    ),
                  ),
                ),
                SizedBox(height: size.width * .05),
                ...data.map((card) {
                  return buildCard(
                    card['icon'] as IconData,
                    card['name'] as String,
                    card['url'] as String,
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SystemCard buildCard(IconData icon, String text, String url) => SystemCard(
    onTap: () async {
      ref.read(soundEffectsServiceProvider).playSystemButtonClick();
      await launchUrl(Uri.parse(url));
    },
    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    margin: EdgeInsets.only(bottom: 15),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 30),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const Spacer(),
        Icon(Icons.chevron_right),
      ],
    ),
  );
}
