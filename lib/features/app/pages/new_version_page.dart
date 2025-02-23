import 'dart:developer';

import 'package:questra_app/core/services/updates_service.dart';
import 'package:questra_app/core/shared/widgets/background_widget.dart';
import 'package:questra_app/core/shared/widgets/beat_loader.dart';
import 'package:questra_app/imports.dart';
import 'package:url_launcher/url_launcher_string.dart';

class NewVersionPage extends ConsumerStatefulWidget {
  const NewVersionPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewVersionPageState();
}

class _NewVersionPageState extends ConsumerState<NewVersionPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BackgroundWidget(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    Assets.getImage('splash_icon.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "NEW UPDATE",
                  style: TextStyle(
                    fontFamily: AppFonts.header,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  "تحديث جديد",
                  style: TextStyle(
                    fontFamily: AppFonts.header,
                    fontSize: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Please download the latest version and delete the current version. The update contains some bug fixes",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "الرجاء تحميل أخر اصدار وحذف الاصدار الحالي. التحديث يحتوي على اصلاح لبعض الأخطاء",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Text(
                  "[Download it from the website]",
                  style: TextStyle(
                    fontFamily: AppFonts.header,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                if (isLoading) ...[
                  BeatLoader(),
                ] else
                  SystemCardButton(
                    onTap: () async {
                      setState(() {
                        isLoading = true;
                      });
                      final url = await UpdatesService.getLastVersionLink();
                      log(url);
                      await launchUrlString(url);

                      setState(() {
                        isLoading = false;
                      });
                    },
                    text: "Download",
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
