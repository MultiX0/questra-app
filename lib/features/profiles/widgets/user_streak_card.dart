import 'package:questra_app/imports.dart';

class UserStreakCard extends StatelessWidget {
  const UserStreakCard({super.key, required this.userStreak});

  final int userStreak;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
      child: SystemCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(LucideIcons.crown, color: AppColors.whiteColor),
            const SizedBox(width: 15),
            Text(
              AppLocalizations.of(context).player_streak,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Spacer(),
            Text(
              userStreak.toString(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
