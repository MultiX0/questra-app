import 'dart:async';
import 'package:questra_app/imports.dart';

class CooldownTimer extends ConsumerStatefulWidget {
  final DateTime lastQuestTime; // Time when the last quest was created
  final Widget refreshWidget;

  const CooldownTimer({super.key, required this.lastQuestTime, required this.refreshWidget});

  @override
  // ignore: library_private_types_in_public_api
  _CooldownTimerState createState() => _CooldownTimerState();
}

class _CooldownTimerState extends ConsumerState<CooldownTimer> {
  late Duration cooldownRemaining;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateCooldown();
    _startCooldownTimer();
  }

  void _updateCooldown() {
    final now = DateTime.now().toUtc();
    final cooldownEnd = widget.lastQuestTime.add(const Duration(hours: 6));
    cooldownRemaining =
        cooldownEnd.difference(now).isNegative ? Duration.zero : cooldownEnd.difference(now);
  }

  void _startCooldownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateCooldown();
          if (cooldownRemaining.inSeconds <= 0) {
            _timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = (duration.inMinutes % 60);
    int seconds = (duration.inSeconds % 60);
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    if (cooldownRemaining.inSeconds == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context).cooldown_over,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            widget.refreshWidget,
          ],
        ),
      );
    }
    return Text(
      "${AppLocalizations.of(context).cooldown}: ${_formatDuration(cooldownRemaining)}",
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
