import 'dart:math' as math;

import 'package:flutter/material.dart';

// Shared building blocks (press/hover wrapper, badges, gradient text, nav glyphs) used by every page.

class RedBadge extends StatelessWidget {
  const RedBadge({super.key,
    required this.text,
    required this.size,
    this.colors,
    this.textColor = Colors.white,
    this.scale = 1,
  });
  final String text;
  final double size;
  final List<Color>? colors;
  final Color textColor;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final c = colors ?? const [Color(0xFFFF7B7B), Color(0xFFE11D1D), Color(0xFF7F0B0B)];
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(center: const Alignment(-.3, -.4), colors: c, stops: const [0, .55, 1]),
          border: Border.all(color: Colors.white.withValues(alpha: .55), width: size * .06),
          boxShadow: [BoxShadow(color: c[1].withValues(alpha: .9), blurRadius: size * .35)],
        ),
        child: Text(text,
            style: TextStyle(fontSize: (size * .42).clamp(10, 16), fontWeight: FontWeight.w800, color: textColor, height: 1)),
      ),
    );
  }
}

/// Embossed silver text (greeting name).
class Embossed extends StatelessWidget {
  const Embossed(this.text, {super.key, required this.fontSize, required this.u});
  final String text;
  final double fontSize;
  final double u;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, height: 1, letterSpacing: -.5);
    return Stack(children: [
      Text(text, style: base.copyWith(color: const Color(0xFF232A31), shadows: [Shadow(color: const Color(0xD9000000), offset: Offset(0, 8 * u), blurRadius: 7 * u)]))
          .withOffset(Offset(0, 4 * u)),
      ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFD3DAE1), Color(0xFF7D8791), Color(0xFFC4CCD3), Color(0xFF8E98A2)],
          stops: [0, .38, .52, .7, 1],
        ).createShader(r),
        child: Text(text, style: base.copyWith(color: Colors.white)),
      ),
    ]);
  }
}

extension on Widget {
  Widget withOffset(Offset o) => Transform.translate(offset: o, child: this);
}

/// Gradient-filled text with a hard under-shadow.
class GradText extends StatelessWidget {
  const GradText(this.text, {super.key, required this.colors, required this.stops, required this.style, required this.shadow, required this.u});
  final String text;
  final List<Color> colors;
  final List<double> stops;
  final TextStyle style;
  final Color shadow;
  final double u;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Transform.translate(
        offset: Offset(0, 2 * u),
        child: Text(text, style: style.copyWith(color: shadow, shadows: [Shadow(color: const Color(0xD9000000), offset: Offset(0, 4 * u), blurRadius: 5 * u)])),
      ),
      ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: colors, stops: stops).createShader(r),
        child: Text(text, style: style.copyWith(color: Colors.white)),
      ),
    ]);
  }
}

// Per-icon hover motions for the bottom nav (s runs 0 → 1 once each time the pointer enters).
double hoverDy(String l, double s, double u) {
  switch (l) {
    case 'Home':
      return -12 * u * math.sin(s * math.pi); // hop
    case 'Profile':
      return -5 * u * math.sin(s * math.pi * 2).abs(); // little double bounce
    default:
      return -4 * u * math.sin(s * math.pi);
  }
}

double hoverRot(String l, double s) {
  switch (l) {
    case 'Chats':
      return -.16 * math.sin(s * math.pi * 2); // bubble wobble
    case 'Market':
      return .22 * math.sin(s * math.pi * 3) * (1 - s); // awning sway
    case 'Profile':
      return .12 * math.sin(s * math.pi * 2) * (1 - s);
    default:
      return 0;
  }
}

double hoverScale(String l, double s) {
  switch (l) {
    case 'Chats':
      return 1 + .2 * math.sin(s * math.pi); // pop
    case 'Home':
      return 1 + .1 * math.sin(s * math.pi);
    default:
      return 1 + .08 * math.sin(s * math.pi);
  }
}

/// Small spring-like wiggle for icon tiles while [s] runs 0 → 1.
class Wobble extends StatelessWidget {
  const Wobble({super.key, required this.s, required this.child});
  final double s;
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform.rotate(
        angle: .07 * math.sin(s * math.pi * 3) * (1 - s),
        child: Transform.scale(scale: 1 + .12 * math.sin(s * math.pi), child: child),
      );
}

/// Interactive wrapper: on hover it springs up and grows a little, a light shine sweeps across it,
/// and [builder] receives the hover amount (g) plus a one-shot 0 → 1 progress (s) for icon animations.
/// Pressing squashes it. (No glow.)
class Press extends StatefulWidget {
  const Press({super.key,
    required this.onTap,
    required this.u,
    this.child,
    this.builder,
    this.radius = 0,
    this.circle = false,
    this.scaleUp = 1.02,
    this.lift = 3,
    this.shine = true,
  });
  final VoidCallback onTap;
  final double u;
  final Widget? child;
  final Widget Function(BuildContext, double, double)? builder;
  final double radius;
  final bool circle;
  final double scaleUp;
  final double lift;
  final bool shine;

  @override
  State<Press> createState() => PressState();
}

class PressState extends State<Press> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
  bool _down = false;
  bool _hover = false;
  Offset? _downAt;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = _hover || _down;
    final u = widget.u;
    final br = BorderRadius.circular(widget.circle ? 999 : widget.radius * u);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hover = true);
        _c.forward(from: 0);
      },
      onExit: (_) => setState(() => _hover = false),
      // Raw pointer events (not the gesture arena) so a quick click/tap always registers, even right after a page change.
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) {
          _downAt = e.position;
          setState(() => _down = true);
          if (!_hover) _c.forward(from: 0);
        },
        onPointerCancel: (_) => setState(() => _down = false),
        onPointerUp: (e) {
          setState(() => _down = false);
          final d = _downAt;
          if (d != null && (e.position - d).distance < 14) widget.onTap();
          _downAt = null;
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: on ? 1 : 0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutBack,
          builder: (context, g, _) => AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final inner = widget.builder != null ? widget.builder!(context, g, _c.value) : (widget.child ?? const SizedBox.expand());
              return Transform.translate(
                offset: Offset(0, -widget.lift * u * g),
                child: Transform.scale(
                  scale: 1 + (widget.scaleUp - 1) * g - (_down ? .035 : 0),
                  child: Stack(fit: StackFit.passthrough, children: [
                    inner,
                    if (widget.shine)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ClipRRect(
                            borderRadius: br,
                            child: FractionalTranslation(
                              translation: Offset(-1.4 + 2.9 * _c.value, 0),
                              child: FractionallySizedBox(
                                widthFactor: .32,
                                alignment: Alignment.centerLeft,
                                child: Transform(
                                  transform: Matrix4.skewX(-.35),
                                  child: const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [Color(0x00FFFFFF), Color(0x40FFFFFF), Color(0x00FFFFFF)]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Crisp vector chrome icons for the bottom nav: dark outline under a white→silver stroke (24-unit grid).
class NavGlyph extends CustomPainter {
  NavGlyph(this.kind, this.g);
  final String kind;
  final double g;

  Path _path() {
    final p = Path();
    switch (kind) {
      case 'home':
        p
          ..moveTo(4, 11)
          ..lineTo(12, 4)
          ..lineTo(20, 11)
          ..lineTo(20, 20)
          ..lineTo(15, 20)
          ..lineTo(15, 14)
          ..lineTo(9, 14)
          ..lineTo(9, 20)
          ..lineTo(4, 20)
          ..close();
      case 'chats':
        const r = Radius.circular(2.5);
        p
          ..moveTo(6, 4.5)
          ..lineTo(18, 4.5)
          ..arcToPoint(const Offset(20.5, 7), radius: r, clockwise: true)
          ..lineTo(20.5, 14.5)
          ..arcToPoint(const Offset(18, 17), radius: r, clockwise: true)
          ..lineTo(11.5, 17)
          ..lineTo(6.5, 20.5)
          ..lineTo(6.5, 17)
          ..lineTo(6, 17)
          ..arcToPoint(const Offset(3.5, 14.5), radius: r, clockwise: true)
          ..lineTo(3.5, 7)
          ..arcToPoint(const Offset(6, 4.5), radius: r, clockwise: true)
          ..close();
      case 'market':
        p
          ..moveTo(4, 9.5)
          ..lineTo(5.5, 4)
          ..lineTo(18.5, 4)
          ..lineTo(20, 9.5)
          ..moveTo(4, 9.5)
          ..cubicTo(4, 10.9, 5.1, 12, 6.5, 12)
          ..cubicTo(7.9, 12, 9, 10.9, 9, 9.5)
          ..cubicTo(9, 10.9, 10.1, 12, 11.5, 12)
          ..lineTo(12.5, 12)
          ..cubicTo(13.9, 12, 15, 10.9, 15, 9.5)
          ..cubicTo(15, 10.9, 16.1, 12, 17.5, 12)
          ..cubicTo(18.9, 12, 20, 10.9, 20, 9.5)
          ..moveTo(5.5, 12)
          ..lineTo(5.5, 20)
          ..lineTo(18.5, 20)
          ..lineTo(18.5, 12)
          ..moveTo(10, 20)
          ..lineTo(10, 15.5)
          ..lineTo(14, 15.5)
          ..lineTo(14, 20);
      default: // profile
        p
          ..addOval(Rect.fromCircle(center: const Offset(12, 8.5), radius: 3.6))
          ..moveTo(5, 20)
          ..cubicTo(5.8, 16, 8.6, 14.2, 12, 14.2)
          ..cubicTo(15.4, 14.2, 18.2, 16, 19, 20);
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sc = size.width / 24;
    canvas.save();
    canvas.scale(sc);
    final path = _path();
    // soft contact shadow
    canvas.drawPath(
      path.shift(const Offset(0, 1)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0x99000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2),
    );
    // dark outline
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = const Color(0xFF0D1217),
    );
    // bright chrome stroke (gets whiter on hover)
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color.lerp(const Color(0xFFDDE3EA), Colors.white, g.clamp(0.0, 1.0))!, Color.lerp(const Color(0xFF9AA5B1), const Color(0xFFE6EBF0), g.clamp(0.0, 1.0))!],
        ).createShader(const Rect.fromLTWH(0, 0, 24, 24)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NavGlyph old) => old.g != g || old.kind != kind;
}
