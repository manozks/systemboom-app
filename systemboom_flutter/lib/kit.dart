import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'data.dart';
import 'shell.dart';

const _gold = Color(0xFFFFB866);

/// Page transition: the new page fades, rises and settles in while the page underneath dims and steps back.
Widget pageTransition(Animation<double> a, Animation<double> secondary, Widget child) {
  final enter = CurvedAnimation(parent: a, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
  final cover = CurvedAnimation(parent: secondary, curve: Curves.easeOut);
  return ScaleTransition(
    scale: Tween<double>(begin: 1, end: .96).animate(cover),
    child: FadeTransition(
      opacity: Tween<double>(begin: 1, end: .55).animate(cover),
      child: FadeTransition(
        opacity: enter,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .045), end: Offset.zero).animate(enter),
          child: ScaleTransition(scale: Tween<double>(begin: .985, end: 1).animate(enter), child: child),
        ),
      ),
    ),
  );
}

/// Used for every new screen.
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(PageRouteBuilder<T>(
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 420),
    reverseTransitionDuration: const Duration(milliseconds: 320),
    transitionsBuilder: (_, a, sa, child) => pageTransition(a, sa, child),
  ));
}

/// A press/hover wrapper with slow animations (no ink).
class Tap extends StatefulWidget {
  const Tap({super.key, required this.onTap, required this.child, this.lift = 2, this.enabled = true});
  final VoidCallback? onTap;
  final Widget child;
  final double lift;
  final bool enabled;
  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool _h = false, _d = false;
  @override
  Widget build(BuildContext context) {
    final on = widget.enabled && widget.onTap != null;
    return MouseRegion(
      cursor: on ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _h = true),
      onExit: (_) => setState(() => _h = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: on ? (_) => setState(() => _d = true) : null,
        onTapCancel: () => setState(() => _d = false),
        onTapUp: (_) => setState(() => _d = false),
        onTap: on ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _h && !_d ? -widget.lift : 0, 0)..scaleByDouble(_d ? .96 : 1.0, _d ? .96 : 1.0, 1.0, 1.0),
          transformAlignment: Alignment.center,
          child: Opacity(opacity: widget.enabled ? 1 : .5, child: widget.child),
        ),
      ),
    );
  }
}

/// Nine-slice art. [px] is the image size, [slice] the border in image pixels.
/// Image scale nudged by a few ulps so Flutter's debug-only 9-slice check (which compares doubles with ==)
/// doesn't trip on float noise. Mirrors the arithmetic in paintImage; the change is far below a pixel.
double _nineScale(double w, double h, double cw, double ch, double s) {
  bool ok(double c) {
    double fit(double n, double cs) {
      final inp = n - (n / c - cs) * c;
      return (inp / c) * c - inp;
    }
    return fit(w, cw) == 0 && fit(h, ch) == 0;
  }

  if (ok(s)) return s;
  for (var i = 1; i < 600; i++) {
    for (final d in [i, -i]) {
      final c = s * (1 + d * 2.2e-16);
      if (ok(c)) return c;
    }
  }
  return s;
}

class Nine extends StatelessWidget {
  const Nine(this.asset, {super.key, required this.px, required this.slice, required this.u, this.child, this.pad = EdgeInsets.zero, this.minH});
  final String asset;
  final Size px;
  final double slice;
  final double u;
  final Widget? child;
  final EdgeInsets pad;
  final double? minH;

  @override
  Widget build(BuildContext context) {
    final s = slice * u;
    return Stack(children: [
      Positioned.fill(
        // The slices must fit inside the destination: shrink them when the box is smaller than
        // twice the border (and draw nothing for an empty box) — otherwise Flutter's 9-slice asserts.
        child: LayoutBuilder(builder: (context, c) {
          if (c.biggest.isEmpty) return const SizedBox.shrink();
          final sx = math.min(s, c.maxWidth / 2 - .5), sy = math.min(s, c.maxHeight / 2 - .5);
          if (sx <= 0 || sy <= 0) return const SizedBox.shrink();
          final slice = Rect.fromLTRB(sx, sy, px.width * u - sx, px.height * u - sy);
          return Image.asset('assets/images/$asset.webp', scale: _nineScale(px.width, px.height, slice.width, slice.height, 1 / u), centerSlice: slice, fit: BoxFit.fill, filterQuality: FilterQuality.medium);
        }),
      ),
      if (child != null) ConstrainedBox(constraints: BoxConstraints(minHeight: minH ?? 0), child: Padding(padding: pad, child: child)),
    ]);
  }
}

const sizePlateRow = Size(890, 184);
const sizeGreen = Size(904, 170);
const sizeBtnSteel = Size(426, 174);
const sizeBtnOrange = Size(454, 174);
const sizeCtaO = Size(916, 146);
const sizeInfoRow = Size(916, 146);
const sizeChipOn = Size(292, 100);
const sizeChipOff = Size(276, 92);
const sizeBubble = Size(571, 134);
const sizeBubbleOut = Size(435, 132);
const sizeNotif = Size(920, 210);
const sizePill = Size(308, 102);
const sizeBtnSmall = Size(330, 108);
const sizeTitle = Size(900, 113);
const sizeTab = Size(886, 88);
const sizePhotoFrame = Size(924, 655);

TextStyle ts(double u, double px, {FontWeight w = FontWeight.w600, Color c = Colors.white, double? h, List<Shadow>? sh, double? ls}) => TextStyle(
      fontSize: px * u,
      fontWeight: w,
      color: c,
      height: h,
      letterSpacing: ls,
      decoration: TextDecoration.none,
      shadows: sh ?? [Shadow(color: Colors.black.withValues(alpha: .85), blurRadius: 3 * u, offset: Offset(0, 3 * u))],
    );

/// Gold-ringed round photo / initials avatar.
class Face extends StatelessWidget {
  const Face({super.key, required this.u, required this.person, this.size = 110, this.online = false, this.tint});
  final double u;
  final Person person;
  final double size;
  final bool online;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final d = size * u;
    final ph = person.photo;
    const hues = [Color(0xFFE5560A), Color(0xFF7C5CFF), Color(0xFF1EA7A0), Color(0xFFD94F8A), Color(0xFF3B82F6), Color(0xFFC28A1A)];
    final c = tint ?? (person.business ? const Color(0xFF14A09A) : hues[person.name.codeUnits.fold<int>(0, (a, b) => a + b) % hues.length]);
    return SizedBox(
      width: d,
      height: d,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          padding: EdgeInsets.all(5 * u),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(colors: [Color(0xFFFFE2A8), Color(0xFFB9772A), Color(0xFF5A3510), Color(0xFFFFD58A), Color(0xFFB9772A), Color(0xFFFFE2A8)]),
            boxShadow: [BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .6), blurRadius: 14 * u), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 7 * u, offset: Offset(0, 5 * u))],
          ),
          child: ClipOval(
            child: ph != null
                ? Image.asset('assets/images/$ph.webp', fit: BoxFit.cover, width: d, height: d)
                : DecoratedBox(
                    decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(-.3, -.5), colors: [c, const Color(0xFF0C0F14)], radius: 1.2)),
                    child: Center(child: Text(person.initials, style: ts(u, size * .36, w: FontWeight.w800))),
                  ),
          ),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 2 * u,
            child: Container(width: 28 * u, height: 28 * u, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF22C55E), border: Border.all(color: const Color(0xFF0D1117), width: 3.5 * u), boxShadow: const [BoxShadow(color: Color(0xAA22C55E), blurRadius: 8)])),
          ),
      ]),
    );
  }
}

/// "| LABEL ─────" section heading with the orange accent bar.
class OLabel extends StatelessWidget {
  const OLabel(this.text, {super.key, required this.u});
  final String text;
  final double u;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(4 * u, 34 * u, 4 * u, 14 * u),
        child: Row(children: [
          Container(width: 6 * u, height: 40 * u, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFB35A), Color(0xFFE5560A)]), boxShadow: [BoxShadow(color: const Color(0xFFFF7A1A), blurRadius: 10 * u)])),
          SizedBox(width: 18 * u),
          Text(text.toUpperCase(), style: ts(u, 36, w: FontWeight.w800, c: const Color(0xFFD6DBE1), ls: 36 * u * .16)),
          SizedBox(width: 18 * u),
          Expanded(child: Container(height: 3 * u, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFF8A2A), Color(0x26FF8A2A), Color(0x00FF8A2A)]), boxShadow: [BoxShadow(color: const Color(0x99FF7A1A), blurRadius: 8 * u)]))),
        ]),
      );
}

/// Dark steel row/plate with riveted bezel (reference art).
class SteelPlate extends StatelessWidget {
  const SteelPlate({super.key, required this.u, required this.child, this.onTap, this.pad, this.minH = 132, this.margin});
  final double u;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? pad;
  final double minH;
  final EdgeInsets? margin;
  @override
  Widget build(BuildContext context) {
    final inner = Nine('plate-row', px: sizePlateRow, slice: 60, u: u, pad: pad ?? EdgeInsets.symmetric(horizontal: 54 * u, vertical: 34 * u), minH: minH * u, child: child);
    return Padding(padding: margin ?? EdgeInsets.only(bottom: 12 * u), child: onTap == null ? inner : Tap(onTap: onTap, child: inner));
  }
}

/// Gold-ringed round icon (settings rows, list rows).
class GoldIcon extends StatelessWidget {
  const GoldIcon(this.icon, {super.key, required this.u, this.size = 104, this.teal = false});
  final IconData icon;
  final double u;
  final double size;
  final bool teal;
  @override
  Widget build(BuildContext context) {
    final c = teal ? const Color(0xFF4FF0E0) : const Color(0xFFFFA83A);
    return Container(
      width: size * u,
      height: size * u,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(center: const Alignment(-.2, -.4), colors: teal ? const [Color(0xFF0A3A36), Color(0xFF031210)] : const [Color(0xFF2A1A08), Color(0xFF0A0603)]),
        border: Border.all(color: teal ? const Color(0xFF4AB8AE) : const Color(0xFFB98A3A), width: 5 * u),
        boxShadow: [BoxShadow(color: c.withValues(alpha: .6), blurRadius: 14 * u)],
      ),
      child: Icon(icon, size: size * u * .5, color: c, shadows: [Shadow(color: c, blurRadius: 8 * u)]),
    );
  }
}

/// Glossy steel / orange bezel button (reference art with a live label).
class ArtBtn extends StatelessWidget {
  const ArtBtn({super.key, required this.u, required this.label, required this.onTap, this.icon, this.orange = false, this.minH = 150, this.fontPx = 44, this.enabled = true, this.expand = true});
  final double u;
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool orange;
  final double minH;
  final double fontPx;
  final bool enabled;
  final bool expand;
  @override
  Widget build(BuildContext context) {
    final w = Nine(orange ? 'btn-orange' : 'btn-steel', px: orange ? sizeBtnOrange : sizeBtnSteel, slice: 60, u: u, minH: minH * u, pad: EdgeInsets.symmetric(horizontal: 54 * u, vertical: 34 * u),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, size: fontPx * u * 1.2, color: Colors.white), SizedBox(width: 16 * u)],
              Text(label, maxLines: 1, style: ts(u, fontPx, w: FontWeight.w800)),
            ]),
          ),
        ));
    return Tap(onTap: onTap, enabled: enabled, child: expand ? SizedBox(width: double.infinity, child: w) : w);
  }
}

/// Compact glossy steel button for 2–3 across rows (no 9-slice art, so it never distorts when narrow).
class MiniBtn extends StatelessWidget {
  const MiniBtn({super.key, required this.u, required this.label, this.icon, required this.onTap, this.fontPx = 34, this.hot = false});
  final double u;
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final double fontPx;
  final bool hot; // orange, eye-catching primary action
  @override
  Widget build(BuildContext context) {
    return Tap(
      onTap: onTap,
      child: Container(
        height: 112 * u,
        padding: EdgeInsets.all(5 * u),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34 * u),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF2F5F8), Color(0xFF7C8791), Color(0xFF2B333B), Color(0xFFB7C0C8)]),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 10 * u, offset: Offset(0, 6 * u)), BoxShadow(color: const Color(0xFFFF821E).withValues(alpha: hot ? .6 : .28), blurRadius: hot ? 24 * u : 16 * u)],
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30 * u),
            gradient: hot
                ? const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFD596), Color(0xFFFF9A3A), Color(0xFFE5560A), Color(0xFF9A3004)], stops: [0, .3, .68, 1])
                : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF3A4C63), Color(0xFF172231), Color(0xFF0A1018)], stops: [0, .5, 1]),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14 * u),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[Icon(icon, size: fontPx * 1.25 * u, color: hot ? Colors.white : const Color(0xFFFFB866), shadows: [Shadow(color: const Color(0xCCFF821E), blurRadius: 8 * u)]), SizedBox(width: 12 * u)],
                  Text(label, maxLines: 1, style: ts(u, fontPx, w: FontWeight.w800)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Action button with a glowing circular icon badge. The icon has its own little animation (the phone rings, the
/// magnifier circles, the flag waves…), a light orbits the badge, and a shine sweeps across the button now and then.
/// [vertical] stacks badge over label (for 3-across rows); otherwise badge and label sit side by side.
class ActionBtn extends StatefulWidget {
  const ActionBtn({super.key, required this.u, required this.label, required this.icon, required this.onTap, this.accent = const Color(0xFFFFB347), this.vertical = false, this.motion = 'pulse', this.phase = 0, this.red = false, this.plain = false, this.badge = 112});
  final bool plain; // no plate: just the glowing circular badge with its label underneath
  final double badge; // badge diameter (design units) in plain mode
  final bool red; // destructive: red ring
  final double u;
  final String label, motion;
  final IconData icon;
  final VoidCallback onTap;
  final Color accent;
  final bool vertical;
  final double phase;
  @override
  State<ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<ActionBtn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))
    ..value = widget.phase % 1
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _icon(double d, double v) {
    final a = v * math.pi * 2;
    var rot = 0.0, sc = 1.0, dx = 0.0, dy = 0.0;
    switch (widget.motion) {
      case 'ring': // phone ringing: a quick shake burst, then rest
        final f = (v * 1.2) % 1;
        if (f < .35) rot = math.sin(f / .35 * math.pi * 7) * .3 * (1 - f / .35);
      case 'pulse':
        sc = 1 + .1 * math.sin(a);
      case 'orbit': // magnifier sweeps a small circle
        dx = math.cos(a) * d * .05;
        dy = math.sin(a) * d * .05;
      case 'wobble':
        rot = math.sin(a) * .22;
      case 'wave': // flag waving
        rot = math.sin(a * 2) * .18;
        dx = math.sin(a * 2) * d * .03;
      case 'pop':
        sc = 1 + .13 * math.pow(math.max(0, math.sin(a)), 3);
    }
    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.rotate(angle: rot, child: Transform.scale(scale: sc, child: Icon(widget.icon, size: d * .46, color: Color.lerp(widget.accent, Colors.white, .55), shadows: [Shadow(color: widget.accent, blurRadius: 12 * widget.u), Shadow(color: widget.accent.withValues(alpha: .7), blurRadius: 22 * widget.u), Shadow(color: Colors.black.withValues(alpha: .55), blurRadius: 3 * widget.u, offset: Offset(0, 2 * widget.u))]))),
    );
  }

  Widget _badge(double d, double v) {
    final ac = widget.accent;
    final a = v * math.pi * 2;
    return SizedBox(
      width: d,
      height: d,
      child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
        // tint inside the dark metal centre so each badge reads in its own colour
        Positioned.fill(child: Padding(padding: EdgeInsets.all(d * .12), child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [ac.withValues(alpha: .38 + .14 * math.sin(a)), ac.withValues(alpha: 0)]))))),
        // the app's chrome ring art (orange glints; the red variant for destructive actions)
        Positioned.fill(child: Image.asset('assets/images/${widget.red ? 'ring63-red' : 'ring63-act'}.webp', fit: BoxFit.fill, filterQuality: FilterQuality.medium)),
        _icon(d, v),
        // light orbiting the rim
        Positioned.fill(child: Transform.scale(scale: 1.04, child: const RingSweep(inner: .84, period: Duration(milliseconds: 2800)))),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.u, ac = widget.accent;
    if (widget.plain) {
      return Tap(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => Column(mainAxisSize: MainAxisSize.min, children: [
            _badge(widget.badge * u, _c.value),
            SizedBox(height: 10 * u),
            FittedBox(fit: BoxFit.scaleDown, child: Text(widget.label, maxLines: 1, style: ts(u, 33, w: FontWeight.w900))),
          ]),
        ),
      );
    }
    final badgeD = (widget.vertical ? 116 : 92) * u;
    final h = (widget.vertical ? 230 : 138) * u;
    return Tap(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final v = _c.value;
          final label = Text(widget.label, maxLines: 1, style: ts(u, 36, w: FontWeight.w900));
          return SizedBox(
            height: h,
            child: Stack(fit: StackFit.expand, clipBehavior: Clip.none, children: [
              // metal plate art (same chamfered chrome button as the notification buttons)
              Nine('notif-btn', px: const Size(330, 108), slice: 44, u: u * .62, pad: EdgeInsets.zero, child: SizedBox(width: double.infinity, height: h)),
              // accent glow along the bottom edge + sweeping shine, clipped to the plate
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.all(5 * u),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26 * u),
                      child: Stack(fit: StackFit.expand, children: [
                        Positioned(left: 0, right: 0, bottom: 0, height: h * .5, child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [ac.withValues(alpha: .22 + .1 * math.sin(v * math.pi * 2)), ac.withValues(alpha: 0)])))),
                        CustomPaint(painter: _BtnShine(((v + widget.phase) % 1) / 1)),
                      ]),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22 * u, vertical: 14 * u),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: widget.vertical
                        ? Column(mainAxisSize: MainAxisSize.min, children: [_badge(badgeD, v), SizedBox(height: 6 * u), label])
                        : Row(mainAxisSize: MainAxisSize.min, children: [_badge(badgeD, v), SizedBox(width: 14 * u), label]),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

class _BtnShine extends CustomPainter {
  _BtnShine(this.p);
  final double p;
  @override
  void paint(Canvas canvas, Size size) {
    if (p < .62) return; // rests for most of the cycle, then sweeps across
    final k = (p - .62) / .38;
    final x = -size.width * .3 + size.width * 1.6 * Curves.easeInOut.transform(k);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(x, 0);
    canvas.skew(-.3, 0);
    final band = Rect.fromLTWH(0, -4, size.width * .22, size.height + 8);
    canvas.drawRect(band, Paint()..shader = const LinearGradient(colors: [Color(0x00FFFFFF), Color(0x55FFFFFF), Color(0x00FFFFFF)]).createShader(band));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BtnShine o) => o.p != p;
}

/// Wide orange / red call-to-action (chat info style).
class CtaBtn extends StatelessWidget {
  const CtaBtn({super.key, required this.u, required this.label, required this.icon, required this.onTap, this.red = false});
  final double u;
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool red;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.symmetric(vertical: 14 * u, horizontal: 6 * u),
        child: Tap(
          onTap: onTap,
          child: Nine(red ? 'info-cta-red' : 'info-cta-orange', px: sizeCtaO, slice: 70, u: u, minH: 146 * u, pad: EdgeInsets.symmetric(horizontal: 66 * u, vertical: 30 * u),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 62 * u, color: Colors.white),
                SizedBox(width: 20 * u),
                Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 56, w: FontWeight.w800, sh: [Shadow(color: const Color(0xCC501400), blurRadius: 4 * u, offset: Offset(0, 3 * u))]))),
              ])),
        ),
      );
}

/// Metal toggle switch.
class MetalSwitch extends StatelessWidget {
  const MetalSwitch({super.key, required this.u, required this.on, required this.onChanged});
  final double u;
  final bool on;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Tap(
        onTap: () => onChanged(!on),
        lift: 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          width: 150 * u,
          height: 82 * u,
          padding: EdgeInsets.all(5 * u),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: const Color(0xFFAAB3BB), width: 4 * u),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: on ? const [Color(0xFF7A2A05), Color(0xFFC2410C), Color(0xFFFF8A2A)] : const [Color(0xFF04070B), Color(0xFF121A23)]),
            boxShadow: [if (on) BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .8), blurRadius: 16 * u)],
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            alignment: on ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(width: 60 * u, height: 60 * u, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(center: Alignment(-.3, -.4), colors: [Colors.white, Color(0xFFC9D0D6), Color(0xFF6B757E)]), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 6 * u, offset: Offset(0, 4 * u))])),
          ),
        ),
      );
}

/// Recessed glass input well.
class GlassWell extends StatelessWidget {
  const GlassWell({super.key, required this.u, required this.child, this.pad, this.radius = 36});
  final double u;
  final Widget child;
  final EdgeInsets? pad;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: 6 * u),
        padding: pad ?? EdgeInsets.symmetric(horizontal: 36 * u, vertical: 22 * u),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius * u),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF02050A), Color(0xFF0A1119), Color(0xFF111B27)]),
          border: Border.all(color: const Color(0xFFAAB3BB), width: 5 * u),
          boxShadow: [BoxShadow(color: const Color(0xFFFF821E).withValues(alpha: .18), blurRadius: 12 * u), BoxShadow(color: Colors.white.withValues(alpha: .15), offset: Offset(0, 3 * u))],
        ),
        child: child,
      );
}

/// Round chrome stepper button.
class RoundBtn extends StatelessWidget {
  const RoundBtn({super.key, required this.u, required this.icon, required this.onTap, this.hot = false});
  final double u;
  final IconData icon;
  final VoidCallback onTap;
  final bool hot;
  @override
  Widget build(BuildContext context) => Tap(
        onTap: onTap,
        child: Container(
          width: 140 * u,
          height: 140 * u,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(colors: [Colors.white, Color(0xFFAEB7C0), Color(0xFF3A424A), Color(0xFFCFD6DC), Color(0xFF69737C), Colors.white]),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 10 * u, offset: Offset(0, 8 * u)), if (hot) BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .85), blurRadius: 24 * u)],
          ),
          padding: EdgeInsets.all(10 * u),
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: const Alignment(0, -.55), colors: hot ? const [Color(0xFFFFD596), Color(0xFFFF8A2A), Color(0xFF9A3004)] : const [Color(0xFF5A6672), Color(0xFF1C232B), Color(0xFF0A0D11)])),
            child: Center(child: Icon(icon, size: 64 * u, color: Colors.white)),
          ),
        ),
      );
}

/// Product / media tile: gradient in the product colour with an icon (or the real photo).
class ProdTile extends StatelessWidget {
  const ProdTile({super.key, required this.u, required this.p, this.w = 150, this.h = 138});
  final double u;
  final Product p;
  final double w;
  final double h;
  @override
  Widget build(BuildContext context) => Container(
        width: w * u,
        height: h * u,
        padding: EdgeInsets.all(6 * u),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18 * u),
          gradient: const SweepGradient(colors: [Colors.white, Color(0xFF9AA3AB), Color(0xFF3A424A), Color(0xFFCFD6DC), Colors.white]),
          boxShadow: [BoxShadow(color: const Color(0xFFFF821E).withValues(alpha: .45), blurRadius: 12 * u), BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 7 * u, offset: Offset(0, 5 * u))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12 * u),
          child: p.photo != null
              ? Image.asset('assets/images/${p.photo}.webp', fit: BoxFit.cover, width: double.infinity, height: double.infinity)
              : DecoratedBox(
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(p.tint), const Color(0xFF10151C)])),
                  child: Center(child: Icon(Icons.inventory_2_outlined, size: w * u * .36, color: Colors.white70)),
                ),
        ),
      );
}

/// Pill with an art bezel.
class StatusArt extends StatelessWidget {
  const StatusArt({super.key, required this.u, required this.text, this.color = const Color(0xFFFFB347)});
  final double u;
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Nine('pill-status', px: sizePill, slice: 40, u: u, minH: 96 * u, pad: EdgeInsets.symmetric(horizontal: 42 * u, vertical: 20 * u), child: Center(widthFactor: 1, child: Text(text, style: ts(u, 38, w: FontWeight.w800, c: color, sh: [Shadow(color: color, blurRadius: 10 * u)]))));
}

/// Floating bottom bar (primary action / composer).
class FootBar extends StatelessWidget {
  const FootBar({super.key, required this.u, required this.child});
  final double u;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.fromLTRB(10 * u, 30 * u, 10 * u, 10 * u + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x0006090D), Color(0xE006090D), Color(0xF206090D)], stops: [0, .45, 1])),
        child: child,
      );
}

/// Eases a block in (fade + rise + settle) the first time it is built. Inside a lazy list that is exactly when it
/// scrolls into view; revealed blocks are kept alive so they don't replay when scrolling back.
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;
  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 540));
  Timer? _t;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final delay = widget.index < 8 ? widget.index * 40 : 0; // first screenful staggers, later blocks come in as you scroll
    _t = Timer(Duration(milliseconds: delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) {
        final t = Curves.easeOutCubic.transform(_c.value);
        if (t >= 1) return child!;
        return Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 30 * (1 - t)), child: Transform.scale(scale: .97 + .03 * t, child: child)));
      },
    );
  }
}

/// A bright light that orbits a circular ring (profile photo frame) plus a slow breathing glow just outside it.
/// Size the box to the ring's outer diameter; [inner] is the inner radius as a fraction of the outer radius.
class RingSweep extends StatefulWidget {
  const RingSweep({super.key, this.inner = .77, this.period = const Duration(milliseconds: 3400)});
  final double inner;
  final Duration period;
  @override
  State<RingSweep> createState() => _RingSweepState();
}

class _RingSweepState extends State<RingSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(child: RepaintBoundary(child: CustomPaint(painter: _RingSweepPainter(_c, widget.inner), size: Size.infinite)));
}

class _RingSweepPainter extends CustomPainter {
  _RingSweepPainter(this.anim, this.inner) : super(repaint: anim);
  final Animation<double> anim;
  final double inner;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rOut = math.min(size.width, size.height) / 2;
    final rIn = rOut * inner;
    final mid = (rOut + rIn) / 2, w = rOut - rIn;
    final ang = anim.value * math.pi * 2;
    // breathing glow just outside the ring
    final pulse = .5 + .5 * math.sin(anim.value * math.pi * 4);
    canvas.drawCircle(c, rOut, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * .5
      ..color = Color.fromRGBO(255, 140, 30, .1 + .22 * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * .7));
    // orbiting highlight: a comet-like arc with a bright head
    final rect = Rect.fromCircle(center: c, radius: mid);
    canvas.drawCircle(c, mid, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..blendMode = BlendMode.plus
      ..shader = SweepGradient(
        colors: const [Color(0x00FFE3B0), Color(0x00FFE3B0), Color(0x55FFD08A), Color(0xFFFFF4D6), Color(0x00FFE3B0)],
        stops: const [0, .6, .85, .985, 1],
        transform: GradientRotation(ang),
      ).createShader(rect));
    final head = c + Offset(math.cos(ang + math.pi * 2 * .985), math.sin(ang + math.pi * 2 * .985)) * mid;
    canvas.drawCircle(head, w * .55, Paint()..color = const Color(0xCCFFF1CC)..maskFilter = MaskFilter.blur(BlurStyle.normal, w * .5));
  }

  @override
  bool shouldRepaint(_RingSweepPainter o) => o.inner != inner;
}

/// Slow fade-and-rise entrance for blocks.
class Rise extends StatelessWidget {
  const Rise({super.key, required this.child, this.i = 0});
  final Widget child;
  final int i;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 520 + i.clamp(0, 8) * 50),
        curve: Curves.easeOutCubic,
        builder: (_, t, c) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: c)),
        child: child,
      );
}

/// Modal helpers --------------------------------------------------------------------------------

Future<T?> showArtSheet<T>(BuildContext context, WidgetBuilder builder) => showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: const Color(0xA8000000),
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (c, _, _) => Align(alignment: Alignment.bottomCenter, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: kMaxW), child: Material(color: Colors.transparent, child: Padding(padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(c).bottom), child: builder(c))))),
      transitionBuilder: (_, a, _, child) => SlideTransition(position: Tween<Offset>(begin: const Offset(0, .35), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: FadeTransition(opacity: a, child: child)),
    );

Future<bool> confirmDialog(BuildContext context, {required String title, required String text, String confirm = 'Delete'}) async {
  final u = context.u;
  final r = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close',
    barrierColor: const Color(0xA8000000),
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (c, _, _) => Center(
      child: SizedBox(
        width: (u * 941 * .9).clamp(260, 400),
        child: AspectRatio(
          aspectRatio: 513 / 262,
          child: LayoutBuilder(builder: (_, bc) {
            final k = bc.maxWidth / 513;
            return Stack(children: [
              Positioned.fill(child: Image.asset('assets/images/dialog-bg.webp', fit: BoxFit.fill)),
              Positioned(left: 34 * k, right: 34 * k, top: 72 * k, child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 38 * k, fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none))),
              Positioned(left: 34 * k, right: 34 * k, top: 120 * k, child: Text(text, style: TextStyle(fontSize: 19 * k, color: const Color(0xFFE9EEF3), decoration: TextDecoration.none, height: 1.25, fontWeight: FontWeight.w400))),
              Positioned(left: 36 * k, top: 160 * k, width: 212 * k, height: 58 * k, child: Tap(onTap: () => Navigator.pop(c, false), child: Center(child: Text('Cancel', style: TextStyle(fontSize: 25 * k, fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none))))),
              Positioned(left: 264 * k, top: 160 * k, width: 212 * k, height: 58 * k, child: Tap(onTap: () => Navigator.pop(c, true), child: Center(child: Text(confirm, style: TextStyle(fontSize: 25 * k, fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none))))),
            ]);
          }),
        ),
      ),
    ),
    transitionBuilder: (_, a, _, child) => ScaleTransition(scale: Tween<double>(begin: .92, end: 1).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: FadeTransition(opacity: a, child: child)),
  );
  return r ?? false;
}

const goldColor = _gold;


/// The ornate sheet panel (title bar with bolts + corner tabs) around any content; height follows the content.
class ArtFrame extends StatelessWidget {
  const ArtFrame({super.key, required this.u, required this.child, this.title});
  final double u;
  final String? title;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final k = 889 / 1116 * u;
    final w = 1116 * k;
    return SizedBox(
      width: w,
      child: Stack(children: [
        Positioned.fill(
          child: LayoutBuilder(builder: (context, c) {
            if (c.biggest.isEmpty) return const SizedBox.shrink();
            return Image.asset('assets/images/asheet-frame.webp', fit: BoxFit.fill, filterQuality: FilterQuality.medium, scale: 1 / k, centerSlice: Rect.fromLTRB(40 * k, 178 * k, w - 40 * k, 1190 * k), width: c.maxWidth, height: c.maxHeight);
          }),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(height: 178 * k, child: Center(child: Padding(padding: EdgeInsets.only(top: 6 * k), child: title == null ? null : Text(title!, style: ts(u, 60 * 889 / 1116, w: FontWeight.w900, c: const Color(0xFFE9EDF3)))))),
          Padding(padding: EdgeInsets.fromLTRB(70 * k, 0, 70 * k, 0), child: child),
          SizedBox(height: 96 * k),
        ]),
      ]),
    );
  }
}

class ActItem {
  const ActItem(this.label, this.icon, this.onSelect, {this.danger = false});
  final String label;
  final IconData icon;
  final VoidCallback onSelect;
  final bool danger;
}

/// Bottom action sheet: ornate art panel + metal rows (reference 1116x1296).
Future<void> showActions(BuildContext context, {String? title, required List<ActItem> items}) {
  final u = context.u;
  final k = 889 / 1116 * u;
  final n = items.length;
  final w = 1116 * k;
  final h = (170 + n * 205 - 5 + 106) * k;
  return showArtSheet<void>(context, (c) => Container(
        margin: EdgeInsets.only(bottom: 26 * u),
        child: Center(
          heightFactor: 1,
          child: SizedBox(
            width: w,
            height: h,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(child: Image.asset('assets/images/asheet-frame.webp', scale: _nineScale(1116, 1296, (w - 80 * k), 1012 * k, 1 / k), centerSlice: Rect.fromLTRB(40 * k, 178 * k, w - 40 * k, 1190 * k), fit: BoxFit.fill, filterQuality: FilterQuality.medium)),
              if (title != null) Positioned(left: 0, right: 0, top: 58 * k, child: Center(child: Text(title, style: ts(u, 66 * 889 / 1116, w: FontWeight.w900, c: const Color(0xFFE9EDF3))))),
              for (var i = 0; i < n; i++)
                Positioned(
                  left: 36 * k,
                  top: (170 + i * 205) * k,
                  width: 1044 * k,
                  height: 200 * k,
                  child: Tap(
                    onTap: () {
                      Navigator.pop(c);
                      items[i].onSelect();
                    },
                    child: Stack(children: [
                      Positioned.fill(child: Image.asset('assets/images/${items[i].danger ? 'asheet-row-red' : 'asheet-row'}.webp', fit: BoxFit.fill, filterQuality: FilterQuality.medium)),
                      Positioned(
                        left: 117 * k - 40 * k,
                        top: 102 * k - 40 * k,
                        width: 80 * k,
                        height: 80 * k,
                        child: Icon(items[i].icon, size: 50 * k, color: items[i].danger ? const Color(0xFFFF5A3C) : const Color(0xFFFFA21F), shadows: [Shadow(color: (items[i].danger ? const Color(0xFFFF4628) : const Color(0xFFFF961E)).withValues(alpha: .9), blurRadius: 7 * k)]),
                      ),
                      Positioned(left: 234 * k, right: 150 * k, top: 0, bottom: 0, child: Align(alignment: Alignment.centerLeft, child: Text(items[i].label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 56 * 889 / 1116, w: FontWeight.w800, c: items[i].danger ? const Color(0xFFFF9A88) : const Color(0xFFF4F6FA))))),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ));
}
