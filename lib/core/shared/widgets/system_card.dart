import 'package:questra_app/imports.dart';

class SystemCard extends StatefulWidget {
  const SystemCard({
    super.key,
    this.border,
    required this.child,
    this.color,
    this.padding,
    this.borderRadius,
    this.onTap,
    this.isButton,
    this.margin,
    this.duration = const Duration(seconds: 1),
  });

  final Color? color;
  final Border? border;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final Function()? onTap;
  final bool? isButton;
  final Duration? duration;

  @override
  State<SystemCard> createState() => _SystemCardState();
}

class _SystemCardState extends State<SystemCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    if (widget.duration == null) {
      return;
    }
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _scaleAnimation = Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.8, 1.0, curve: Curves.linear)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    if (widget.duration != null) {
      _controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    if (widget.duration == null) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: widget.margin,
          constraints:
              (widget.isButton != null && widget.isButton!)
                  ? null
                  : BoxConstraints(minWidth: size.width),
          decoration: BoxDecoration(
            color:
                widget.color?.withValues(alpha: .25) ?? HexColor('7AD5FF').withValues(alpha: .05),
            border:
                widget.border ?? Border.all(color: widget.color ?? HexColor('43A7D5'), width: 0.75),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
          ),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 40),
            child: widget.child,
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              margin: widget.margin,
              duration: widget.duration!,
              constraints:
                  (widget.isButton != null && widget.isButton!)
                      ? null
                      : BoxConstraints(minWidth: size.width),
              decoration: BoxDecoration(
                color:
                    widget.color?.withValues(alpha: .25) ??
                    HexColor('7AD5FF').withValues(alpha: .05),
                border:
                    widget.border ??
                    Border.all(color: widget.color ?? HexColor('43A7D5'), width: 0.75),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
              ),
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.symmetric(vertical: 40),
                child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
              ),
            ),
          ),
        );
      },
    );
  }
}
