import 'package:flutter/material.dart';

import 'data.dart';
import 'shell.dart';

const _gold = Color(0xFFFFB866);

/// Slow, smooth page transition used for every new screen.
Future<T?> pushScreen<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(PageRouteBuilder<T>(
    pageBuilder: (_, _, _) => page,
    transitionDuration: const Duration(milliseconds: 700),
    reverseTransitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (_, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, .03), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
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
          transform: Matrix4.translationValues(0, _h && !_d ? -widget.lift : 0, 0)..scale(_d ? .96 : 1.0),
          transformAlignment: Alignment.center,
          child: Opacity(opacity: widget.enabled ? 1 : .5, child: widget.child),
        ),
      ),
    );
  }
}

/// Nine-slice art. [px] is the image size, [slice] the border in image pixels.
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
        child: Image.asset('assets/images/$asset.webp', scale: 1 / u, centerSlice: Rect.fromLTRB(s, s, px.width * u - s, px.height * u - s), fit: BoxFit.fill, filterQuality: FilterQuality.medium),
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
        child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: fontPx * u * 1.2, color: Colors.white), SizedBox(width: 16 * u)],
          Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, fontPx, w: FontWeight.w800))),
        ]));
    return Tap(onTap: onTap, enabled: enabled, child: expand ? SizedBox(width: double.infinity, child: w) : w);
  }
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
        padding: EdgeInsets.fromLTRB(10 * u, 30 * u, 10 * u, 10 * u),
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x0006090D), Color(0xE006090D), Color(0xF206090D)], stops: [0, .45, 1])),
        child: child,
      );
}

/// Slow fade-and-rise entrance for blocks.
class Rise extends StatelessWidget {
  const Rise({super.key, required this.child, this.i = 0});
  final Widget child;
  final int i;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 800 + i.clamp(0, 8) * 70),
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
      pageBuilder: (c, _, _) => Align(alignment: Alignment.bottomCenter, child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: kMaxW), child: Material(color: Colors.transparent, child: builder(c)))),
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
