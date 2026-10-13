import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'kit.dart';
import 'shell.dart';

/// Celestial emoji: each planet replaces a standard emoji key (kept as the stored value).
class Celestial {
  final String key, asset, name, label;
  final Color glow; // halo colour in the picker
  const Celestial(this.key, this.asset, this.name, this.label, this.glow);
  String get path => 'assets/images/celestial/$asset.webp';
}

const celestials = [
  Celestial('❤️', 'venus', 'Venus', 'Love', Color(0xFFFF6FA3)),
  Celestial('🔥', 'sun', 'Sun', 'Joy', Color(0xFFFFB02E)),
  Celestial('😂', 'meteors', 'Meteor Shower', 'Laugh', Color(0xFFFF7A2A)),
  Celestial('😮', 'comet', 'Comet', 'Wow', Color(0xFF4FA8FF)),
  Celestial('👍', 'jupiter', 'Jupiter', 'Celebrate', Color(0xFFFFA860)),
  Celestial('🙏', 'saturn', 'Saturn', 'Support', Color(0xFFFFD27A)),
  Celestial('🌙', 'moon', 'Moon', 'Touched', Color(0xFFA9C4FF)),
  Celestial('🤔', 'mercury', 'Mercury', 'Curious', Color(0xFFFFB84D)),
];

Celestial? celestialFor(String key) {
  for (final c in celestials) {
    if (c.key == key) return c;
  }
  return null;
}

Widget celestialIcon(String key, double size, {double fallbackFont = 26}) {
  final c = celestialFor(key);
  if (c == null) return Text(key, style: TextStyle(fontSize: fallbackFont, decoration: TextDecoration.none));
  return Image.asset(c.path, width: size, height: size, fit: BoxFit.contain);
}


/// A reaction planet that is always alive: it floats, breathes and tilts, and each planet has its own character
/// (Sun spins, Venus beats like a heart, the Comet and Meteor Shower drift along their trails).
class AnimatedPlanet extends StatefulWidget {
  const AnimatedPlanet(this.keyStr, this.size, {super.key, this.fallbackFont = 26});
  final String keyStr;
  final double size, fallbackFont;
  @override
  State<AnimatedPlanet> createState() => _AnimatedPlanetState();
}

class _AnimatedPlanetState extends State<AnimatedPlanet> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: 3200 + (widget.keyStr.hashCode.abs() % 1500)))
    ..value = (widget.keyStr.hashCode.abs() % 100) / 100
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final z = widget.size;
    final icon = celestialIcon(widget.keyStr, z, fallbackFont: widget.fallbackFont);
    final name = celestialFor(widget.keyStr)?.asset ?? '';
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: icon,
        builder: (_, child) {
          final a = _c.value * math.pi * 2;
          var dx = 0.0, dy = math.sin(a) * z * .05, rot = math.sin(a + 1) * .06, sc = 1 + .045 * math.sin(a + 2);
          switch (name) {
            case 'sun':
              rot = a; // slow full spin
              dy = math.sin(a) * z * .03;
              sc = 1 + .06 * math.sin(a * 2);
            case 'venus':
              final b = math.pow(math.max(0, math.sin(a * 2)), 4).toDouble(); // heart-beat
              sc = 1 + .12 * b;
              rot = 0;
            case 'comet' || 'meteors':
              dx = math.sin(a) * z * .06;
              dy = -math.sin(a) * z * .06;
              rot = 0;
              sc = 1 + .03 * math.sin(a * 2);
          }
          return Transform.translate(offset: Offset(dx, dy), child: Transform.rotate(angle: rot, child: Transform.scale(scale: sc, child: child)));
        },
      ),
    );
  }
}

/// One planet in the picker: wobbles on hover, and bursts into sparks when picked.
class _PlanetCell extends StatefulWidget {
  const _PlanetCell({required this.e, required this.u, required this.onPicked});
  final Celestial e;
  final double u;
  final VoidCallback onPicked;
  @override
  State<_PlanetCell> createState() => _PlanetCellState();
}

class _PlanetCellState extends State<_PlanetCell> with SingleTickerProviderStateMixin {
  late final AnimationController _b = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
  bool _hover = false;

  @override
  void dispose() {
    _b.dispose();
    super.dispose();
  }

  void _pick() {
    if (_b.isAnimating || _b.value > 0) return;
    _b.forward().whenComplete(() {
      if (mounted) widget.onPicked();
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.u, e = widget.e;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _pick,
        child: AnimatedBuilder(
          animation: _b,
          builder: (_, _) {
            final b = _b.value;
            // squash-and-pop: grows, then shrinks away while the sparks fly out
            final pop = b < .35 ? 1 + .35 * Curves.easeOut.transform(b / .35) : 1.35 * (1 - Curves.easeIn.transform((b - .35) / .65));
            return AnimatedScale(
              scale: _hover && b == 0 ? 1.12 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  width: 176 * u,
                  height: 176 * u,
                  child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                    Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: e.glow.withValues(alpha: _hover ? .75 : .5), blurRadius: (_hover ? 40 : 32) * u, spreadRadius: 2 * u)]))),
                    Positioned.fill(child: Image.asset('assets/images/ring63-emoji.webp', fit: BoxFit.fill)),
                    Transform.scale(scale: pop.clamp(0.0, 2.0), child: AnimatedPlanet(e.key, 124 * u)),
                    if (b > 0) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _BurstPainter(b, e.glow, u), size: Size.infinite))),
                  ]),
                ),
                SizedBox(height: 10 * u),
                FittedBox(fit: BoxFit.scaleDown, child: Text(e.name.toUpperCase(), maxLines: 1, style: ts(u, 23, c: e.glow.withValues(alpha: .95), w: FontWeight.w800, ls: 23 * u * .06))),
                SizedBox(height: 2 * u),
                Text(e.label, style: ts(u, 38, w: FontWeight.w900)),
              ]),
            );
          },
        ),
      ),
    );
  }
}

/// Sparks radiating from the centre when a planet is picked.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.p, this.color, this.u);
  final double p, u;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final e = Curves.easeOut.transform(p);
    for (var i = 0; i < 18; i++) {
      final ang = i / 18 * math.pi * 2 + (i.isEven ? .1 : -.1);
      final d = (70 + (i % 3) * 26) * u * e;
      final pos = c + Offset(math.cos(ang), math.sin(ang)) * d;
      final al = (1 - p).clamp(0.0, 1.0);
      canvas.drawCircle(pos, (4.5 - (i % 3)) * u * (1 - p * .6), Paint()..color = Color.lerp(color, Colors.white, i.isEven ? .7 : .2)!.withValues(alpha: al));
    }
    canvas.drawCircle(c, 80 * u * e, Paint()..style = PaintingStyle.stroke..strokeWidth = 4 * u * (1 - p)..color = color.withValues(alpha: .8 * (1 - p)));
  }

  @override
  bool shouldRepaint(_BurstPainter o) => o.p != p;
}

/// Text with celestial emoji keys rendered as planet images.
Widget celestialText(String text, TextStyle style, double iconSize) {
  final keys = celestials.map((c) => RegExp.escape(c.key)).join('|');
  final re = RegExp(keys);
  if (!re.hasMatch(text)) return Text(text, style: style);
  final spans = <InlineSpan>[];
  var i = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start)));
    spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: celestialIcon(m.group(0)!, iconSize)));
    i = m.end;
  }
  if (i < text.length) spans.add(TextSpan(text: text.substring(i)));
  return Text.rich(TextSpan(children: spans), style: style);
}

/// 4×2 picker: glowing ringed planets in the ornate sheet panel. Calls [onPick] with the emoji key.
Future<void> showCelestialPicker(BuildContext context, void Function(String key) onPick) {
  return showArtSheet<void>(context, (c) {
    final u = c.u;
    Widget cell(Celestial e) => _PlanetCell(e: e, u: u, onPicked: () {
          Navigator.pop(c);
          onPick(e.key);
        });
    return Container(
      margin: EdgeInsets.only(bottom: 20 * u),
      child: Center(
        heightFactor: 1,
        child: ArtFrame(
          u: u,
          title: 'React',
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final e in celestials.sublist(0, 4)) Expanded(child: cell(e))]),
            SizedBox(height: 30 * u),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final e in celestials.sublist(4)) Expanded(child: cell(e))]),
          ]),
        ),
      ),
    );
  });
}
