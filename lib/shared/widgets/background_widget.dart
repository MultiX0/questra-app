import 'package:questra_app/imports.dart';

class BackgroundWidget extends ConsumerWidget {
  const BackgroundWidget({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            Assets.getImage('app_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.65,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [
                    0.0,
                    1.0,
                  ],
                  colors: [
                    HexColor('22B2F4'),
                    HexColor('14688E'),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black38,
          ),
        ),
        child,
      ],
    );
  }
}
