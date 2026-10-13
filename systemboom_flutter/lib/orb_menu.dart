import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'kit.dart';
import 'shell.dart';

/// Wraps the Calls orb in the dock. Hovering it (mouse) or tapping it (touch) fans out a circular menu with
/// Chats, Calls, Marketplace and Anonymous. With the menu already open from hovering, a click goes straight to Calls.
class DockOrbMenu extends StatefulWidget {
  const DockOrbMenu({super.key, required this.builder});

  /// Builds the orb; call [onTap] from its tap handler.
  final Widget Function(BuildContext context, VoidCallback onTap) builder;

  @override
  State<DockOrbMenu> createState() => _DockOrbMenuState();
}

class _DockOrbMenuState extends State<DockOrbMenu> with SingleTickerProviderStateMixin {
  final _orbKey = GlobalKey();
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 520), reverseDuration: const Duration(milliseconds: 260));
  OverlayEntry? _entry;
  Timer? _closeTimer;
  bool _viaTap = false;

  @override
  void dispose() {
    _closeTimer?.cancel();
    _entry?.remove();
    _entry = null;
    _c.dispose();
    super.dispose();
  }

  void _open({required bool viaTap}) {
    _closeTimer?.cancel();
    if (viaTap) _viaTap = true;
    if (_entry != null) {
      _c.forward();
      return;
    }
    final box = _orbKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final center = box.localToGlobal(box.size.center(Offset.zero));
    final u = context.u;
    _entry = OverlayEntry(
      builder: (_) => _OrbMenuOverlay(
        anim: _c,
        center: center,
        u: u,
        modal: _viaTap,
        onHover: (inside) => inside ? _closeTimer?.cancel() : _scheduleClose(),
        onDismiss: _close,
        onPick: (route) {
          _close(immediately: true);
          if (route == 'anonymous') {
            openPage(context, route);
          } else {
            goTab(context, route);
          }
        },
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
    _c.forward(from: 0);
  }

  void _scheduleClose() {
    if (_viaTap) return; // opened by touch: stays until dismissed
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 320), _close);
  }

  void _close({bool immediately = false}) {
    _closeTimer?.cancel();
    _viaTap = false;
    final e = _entry;
    if (e == null) return;
    _entry = null;
    if (immediately) {
      e.remove();
      _c.value = 0;
    } else {
      _c.reverse().whenComplete(e.remove);
    }
  }

  void _tap() {
    if (_entry == null) {
      _open(viaTap: true); // touch: first tap opens the menu
    } else if (_viaTap) {
      _close();
    } else {
      _close(immediately: true); // mouse: menu is open from hovering — a click goes straight to Calls
      goTab(context, 'calls');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _open(viaTap: false),
      onExit: (_) => _scheduleClose(),
      child: KeyedSubtree(key: _orbKey, child: widget.builder(context, _tap)),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.route, this.label, this.icon, this.glow, this.angle);
  final String route, label;
  final IconData icon;
  final Color glow;
  final double angle; // degrees from straight up
}

const _items = [
  _MenuItem('chats', 'Chats', Icons.chat_bubble_outline_rounded, Color(0xFF5AB8F2), -60),
  _MenuItem('calls', 'Calls', Icons.call_rounded, Color(0xFFFF9A2A), -20),
  _MenuItem('market', 'Marketplace', Icons.storefront_outlined, Color(0xFFFFD27A), 20),
  _MenuItem('anonymous', 'Anonymous', Icons.masks_outlined, Color(0xFF28E6D7), 60),
];

class _OrbMenuOverlay extends StatelessWidget {
  const _OrbMenuOverlay({required this.anim, required this.center, required this.u, required this.modal, required this.onHover, required this.onDismiss, required this.onPick});
  final Animation<double> anim;
  final Offset center;
  final double u;
  final bool modal;
  final ValueChanged<bool> onHover;
  final VoidCallback onDismiss;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final r = 400 * u; // radius of the fan
    final item = 168 * u; // button diameter
    return AnimatedBuilder(
      animation: anim,
      builder: (context, _) {
        final c = anim.value;
        final fade = Curves.easeOut.transform(c.clamp(0.0, 1.0));
        return Material(
          type: MaterialType.transparency,
          child: Stack(children: [
          // dim backdrop (taps dismiss when opened by touch; for hover it only dims)
          Positioned.fill(
            child: modal
                ? GestureDetector(behavior: HitTestBehavior.opaque, onTap: onDismiss, child: ColoredBox(color: Colors.black.withValues(alpha: .55 * fade)))
                : IgnorePointer(child: ColoredBox(color: Colors.black.withValues(alpha: .38 * fade))),
          ),
          // the glowing circle the buttons pop out of
          Positioned(
            left: center.dx - (r + item * .9),
            top: center.dy - (r + item * .9),
            width: 2 * (r + item * .9),
            height: 2 * (r + item * .9),
            child: IgnorePointer(child: CustomPaint(painter: _CirclePainter(progress: c, u: u, r: r))),
          ),
          // hover zone covering the whole fan so moving from the orb onto a button keeps it open
          Positioned(
            left: center.dx - (r + item),
            top: center.dy - (r + item * .9),
            width: 2 * (r + item),
            height: r + item * .9 + 90 * u,
            child: MouseRegion(onEnter: (_) => onHover(true), onExit: (_) => onHover(false), opaque: false, child: const SizedBox.expand()),
          ),
          for (var i = 0; i < _items.length; i++) _buildItem(i, c, r, item),
        ]));
      },
    );
  }

  Widget _buildItem(int i, double c, double r, double size) {
    final m = _items[i];
    final a = m.angle * math.pi / 180;
    final target = center + Offset(math.sin(a) * r, -math.cos(a) * r * .92 - 10 * u);
    // staggered spring: each button flies out of the orb a little after the previous one
    final p = Curves.easeOutBack.transform(Interval(i * .09, .62 + i * .09, curve: Curves.linear).transform(c));
    final pos = Offset.lerp(center, target, p.clamp(0.0, 1.4))!;
    final op = (p * 1.6).clamp(0.0, 1.0);
    return Positioned(
      left: pos.dx - size * .8,
      top: pos.dy - size / 2,
      width: size * 1.6,
      height: size + 56 * u,
      child: Opacity(
        opacity: op,
        child: Transform.rotate(
          angle: (1 - p.clamp(0.0, 1.0)) * (m.angle < 0 ? -1.2 : 1.2),
          child: Transform.scale(
            scale: p.clamp(0.0, 1.2),
            alignment: Alignment.topCenter,
            child: _OrbItem(m: m, u: u, size: size, hot: m.route == 'calls', onTap: () => onPick(m.route)),
          ),
        ),
      ),
    );
  }
}

class _OrbItem extends StatefulWidget {
  const _OrbItem({required this.m, required this.u, required this.size, required this.hot, required this.onTap});
  final _MenuItem m;
  final double u, size;
  final bool hot;
  final VoidCallback onTap;
  @override
  State<_OrbItem> createState() => _OrbItemState();
}

class _OrbItemState extends State<_OrbItem> {
  bool _hover = false, _down = false;

  @override
  Widget build(BuildContext context) {
    final u = widget.u;
    final g = widget.m.glow;
    final on = _hover || _down;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => setState(() => _down = true),
        onPointerCancel: (_) => setState(() => _down = false),
        onPointerUp: (_) {
          setState(() => _down = false);
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _down ? .94 : (on ? 1.14 : 1),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: Stack(alignment: Alignment.center, children: [
                Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: g.withValues(alpha: on ? .85 : .55), blurRadius: (on ? 44 : 30) * u, spreadRadius: 3 * u)]))),
                Positioned.fill(child: Image.asset('assets/images/share-ring.webp', fit: BoxFit.fill)),
                Icon(widget.m.icon, size: widget.size * .42, color: const Color(0xFFFFF4DC), shadows: [Shadow(color: g.withValues(alpha: .95), blurRadius: 16 * u), Shadow(color: Colors.black.withValues(alpha: .6), blurRadius: 4 * u, offset: Offset(0, 3 * u))]),
              ]),
            ),
            SizedBox(height: 8 * u),
            Text(widget.m.label, maxLines: 1, textAlign: TextAlign.center, style: ts(u, 32, w: FontWeight.w900, c: on ? const Color(0xFFFFE6B0) : Colors.white)),
          ]),
        ),
      ),
    );
  }
}

/// Soft radial glow + a ring that sweeps open, drawn behind the buttons.
class _CirclePainter extends CustomPainter {
  _CirclePainter({required this.progress, required this.u, required this.r});
  final double progress, u, r;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final rad = (r + 150 * u) * p;
    canvas.drawCircle(c, rad, Paint()..shader = radialGlow(c, rad));
    // sweeping ring on which the buttons sit
    final ringR = r * .96 * p;
    final rect = Rect.fromCircle(center: c, radius: ringR);
    final sweep = math.pi * 2 * p;
    canvas.drawArc(rect, -math.pi / 2 - sweep / 2, sweep, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * u
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFB347).withValues(alpha: .75 * p)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * u));
    canvas.drawArc(rect, -math.pi / 2 - sweep / 2, sweep, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 * u
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFFFFF0D0).withValues(alpha: .9 * p));
    // tiny sparks riding the ring
    for (var i = 0; i < 18; i++) {
      final ang = -math.pi / 2 - sweep / 2 + sweep * (i / 17);
      canvas.drawCircle(c + Offset(math.cos(ang), math.sin(ang)) * ringR, (2.2 + (i % 3)) * u, Paint()..color = const Color(0xFFFFD27A).withValues(alpha: .8 * p));
    }
  }

  Shader radialGlow(Offset c, double rad) => RadialGradient(colors: const [Color(0x66FF9A2A), Color(0x33FF6A1A), Color(0x00FF6A1A)], stops: const [0, .55, 1]).createShader(Rect.fromCircle(center: c, radius: math.max(rad, 1)));

  @override
  bool shouldRepaint(_CirclePainter o) => o.progress != progress || o.r != r || o.u != u;
}
