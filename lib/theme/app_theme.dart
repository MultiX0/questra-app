import 'package:flutter/foundation.dart';
import '/imports.dart';

class AppTheme {
  // Colors
  static final blackColor = AppColors.scaffoldBackground;
  static final cardColor = AppColors.mainCardColor;
  static final whiteColor = AppColors.whiteColor;

  // Themes
  static var darkModeAppTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Colors.transparent,
    cardColor: cardColor,
    iconTheme: IconThemeData(color: AppColors.whiteColor),
    appBarTheme: AppBarTheme(
      scrolledUnderElevation: 0,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontFamily: AppFonts.header,
        fontSize: 23,
      ),
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(
        color: whiteColor,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: blackColor,
    ),
    primaryColor: AppColors.primary,
    textTheme: (kIsWeb)
        ? TextTheme(
            headlineLarge: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            headlineMedium: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            headlineSmall: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            bodyLarge: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            bodyMedium: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            bodySmall: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
          )
        : TextTheme(
            headlineLarge: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            headlineMedium: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            headlineSmall: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            bodyLarge: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            bodyMedium: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            bodySmall: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            displayLarge: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            displayMedium: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            displaySmall: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            labelLarge: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            labelMedium: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            labelSmall: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            titleLarge: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            titleMedium: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
            titleSmall: TextStyle(fontFamily: AppFonts.primary, color: whiteColor),
          ),
  );
}

class AppColors {
  static Color scaffoldBackground = HexColor("#020403");
  static Color primary = HexColor('#7AD5FF');
  static Color redColor = HexColor('FF7A7C');
  static Color descriptionColor = Colors.white.withValues(alpha: .86);
  static Color whiteColor = HexColor('#f1f2f4');
  static Color aiChatCard = HexColor('#34514F').withValues(alpha: .6);
  static Color userChatCard = HexColor('#30726D').withValues(alpha: .8);
  static Color mainCardColor = HexColor('#5A5A5A').withValues(alpha: .09);
  static Color mainCardBorderColor = HexColor('AEAEAE').withValues(alpha: .21);
  static Color navBarColor = HexColor('#0A7B54');
  static Color chatInputsColor = HexColor('#54827B').withValues(alpha: .67);
  static Color chatInputsBorderColor = HexColor('#19DD98').withValues(alpha: .1);
  static Color bgSphereColor = HexColor('#19DD98').withValues(alpha: .1);
  static Color redCardsColor = HexColor('#F44D4D').withValues(alpha: .62);
  static Color circularIconColor = HexColor('457975').withValues(alpha: .8);
}

class AppSizes {
  final EdgeInsets padding;

  AppSizes({required BuildContext context})
      : padding = EdgeInsets.only(
            bottom: MediaQuery.of(context).size.width / 4, left: 10, right: 10, top: 10);

  static double borderRadius = 10.0;

  static final normalPadding = EdgeInsets.symmetric(vertical: 15, horizontal: 25);
}
