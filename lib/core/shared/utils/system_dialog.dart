import 'package:questra_app/imports.dart';

void systemDialog(BuildContext context, {required SystemCard card}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shadowColor: Colors.black,
        content: SystemCard(child: card),
        backgroundColor: Colors.transparent,
      );
    },
  );
}
