import 'package:questra_app/imports.dart';

class AccountSetupNextButton extends StatelessWidget {
  const AccountSetupNextButton({super.key, required this.next, required this.size});

  final Function() next;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 15, bottom: 35, top: 15),
      child: GlowButton(
        glowColor: HexColor('7AD5FF').withValues(alpha: 0.4),
        color: Color.fromARGB(151, 99, 206, 255),
        onPressed: () {
          next();
        },
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: size.width * .35),
        child: Text(AppLocalizations.of(context).next_button),
      ),
    );
  }
}
