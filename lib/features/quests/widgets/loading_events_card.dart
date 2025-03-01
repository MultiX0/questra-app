import 'package:questra_app/imports.dart';
import 'package:shimmer/shimmer.dart';

class LoadingQuestsCard extends StatelessWidget {
  const LoadingQuestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.primary.withValues(alpha: .15),
      highlightColor: AppColors.primary.withValues(alpha: .5),
      child: AspectRatio(
        aspectRatio: 16 / 8,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[800],
          ),
          child: Stack(
            children: [
              // Background placeholder (simulating image area)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
              ),

              // Content overlay placeholder
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: .1),
                      Colors.black.withValues(alpha: .3),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 120,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
