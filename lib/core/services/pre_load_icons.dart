import 'package:questra_app/imports.dart';

class PreLoadIcons {
  static void loadIcons() {
    final _icons = [
      LucideIcons.instagram,
      LucideIcons.x,
      LucideIcons.mail,
      LucideIcons.youtube,
      LucideIcons.settings,
      LucideIcons.settings_2,
      LucideIcons.pen,
      LucideIcons.pen_line,
      LucideIcons.pen_tool,
      LucideIcons.pencil,
      LucideIcons.pencil_line,
      LucideIcons.pencil_off,
      Icons.privacy_tip,
      Icons.privacy_tip_outlined,
      Icons.chevron_right,
      LucideIcons.shield,
      LucideIcons.shield_alert,
      LucideIcons.shield_ban,
      LucideIcons.shield_check,
      LucideIcons.shield_ellipsis,
      LucideIcons.sheet,
      LucideIcons.shell,
      LucideIcons.search,
      LucideIcons.group,
      LucideIcons.user,
      LucideIcons.user_plus,
      LucideIcons.info,
      LucideIcons.badge,
      LucideIcons.badge_check,
      LucideIcons.badge_info,
      Icons.paypal,
    ];
    for (final icon in _icons) {
      Icon(icon);
    }
  }
}
