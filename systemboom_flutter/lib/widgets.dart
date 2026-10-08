import 'package:flutter/material.dart';

import 'ui.dart';

/// Round gold-rimmed action button (call / video back).
class GoldBtn extends StatelessWidget {
  const GoldBtn({super.key, required this.u, required this.icon, required this.onTap, this.size = 92});
  final double u;
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * u,
      height: size * u,
      child: Press(
        u: u,
        circle: true,
        scaleUp: 1.12,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(colors: [Colors.white, Color(0xFFC9A46A), Color(0xFF4A3414), Color(0xFFE8C27A), Colors.white]),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .85), blurRadius: 7 * u, offset: Offset(0, 5 * u)), BoxShadow(color: const Color(0xFFFF8C28).withValues(alpha: .5), blurRadius: 14 * u)],
          ),
          child: Padding(
            padding: EdgeInsets.all(5 * u),
            child: DecoratedBox(
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-.3, -.5), colors: [Color(0xFF3A2A1A), Color(0xFF0C0804)], stops: [0, .75])),
              child: Center(child: Icon(icon, size: 44 * u, color: const Color(0xFFFFC58A), shadows: [Shadow(color: const Color(0xFFFF8C28), blurRadius: 8 * u)])),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glossy orange round button (chat-with-seller etc.).
class OrangeOrb extends StatelessWidget {
  const OrangeOrb({super.key, required this.u, required this.icon, required this.onTap, this.size = 78});
  final double u;
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * u,
      height: size * u,
      child: Press(
        u: u,
        circle: true,
        scaleUp: 1.12,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const SweepGradient(colors: [Colors.white, Color(0xFFC9A46A), Color(0xFF4A3414), Color(0xFFE8C27A), Colors.white]),
            boxShadow: [BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .7), blurRadius: 14 * u), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 6 * u, offset: Offset(0, 4 * u))],
          ),
          child: Padding(
            padding: EdgeInsets.all(4 * u),
            child: DecoratedBox(
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(0, -.6), radius: 1, colors: [Color(0xFFFFB866), Color(0xFFE5560A), Color(0xFF7A2A02)], stops: [0, .6, 1])),
              child: Center(child: Icon(icon, size: 38 * u, color: Colors.white, shadows: const [Shadow(color: Color(0xCC5A1400), offset: Offset(0, 2))])),
            ),
          ),
        ),
      ),
    );
  }
}

enum BtnKind { primary, steel, outline, soft, danger, ghost }

/// Design-system button: glossy orange / steel / outline / soft / danger / ghost.
class MBtn extends StatelessWidget {
  const MBtn(this.label, {super.key, required this.u, this.kind = BtnKind.primary, this.icon, this.onTap, this.loading = false, this.height = 96, this.fontSize = 33, this.hPad = 40});
  final String label;
  final double u;
  final BtnKind kind;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool loading;
  final double height;
  final double fontSize;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null && !loading;
    BoxDecoration deco;
    Color fg = Colors.white;
    switch (kind) {
      case BtnKind.primary:
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const RadialGradient(center: Alignment(0, -1), radius: 1.7, colors: [Color(0xFFFFD9A0), Color(0xFFFF9A3A), Color(0xFFE5560A), Color(0xFF8F2A02)], stops: [0, .28, .68, 1]),
          border: Border.all(color: const Color(0xFF5A1D02), width: 2 * u),
          boxShadow: [BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .8), blurRadius: 18 * u), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 6 * u, offset: Offset(0, 5 * u))],
        );
      case BtnKind.steel:
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF76828D), Color(0xFF3A444E), Color(0xFF1B2229), Color(0xFF2A333C)], stops: [0, .14, .52, 1]),
          border: Border.all(color: Colors.black.withValues(alpha: .85), width: 2.5 * u),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .85), blurRadius: 8 * u, offset: Offset(0, 6 * u))],
        );
      case BtnKind.outline:
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A1017), Color(0xFF05080C)]),
          border: Border.all(color: const Color(0xFFAAB3BB), width: 3.5 * u),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 7 * u, offset: Offset(0, 5 * u))],
        );
      case BtnKind.soft:
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF4A8FC9), Color(0xFF1B4A78), Color(0xFF12304E)], stops: [0, .55, 1]),
          border: Border.all(color: Colors.black.withValues(alpha: .7), width: 2 * u),
          boxShadow: [BoxShadow(color: const Color(0xFF50A0FF).withValues(alpha: .45), blurRadius: 14 * u), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 6 * u, offset: Offset(0, 5 * u))],
        );
      case BtnKind.danger:
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const RadialGradient(center: Alignment(0, -1), radius: 1.7, colors: [Color(0xFFFFB0A8), Color(0xFFFF4A3D), Color(0xFFC0221A), Color(0xFF6A0A06)], stops: [0, .32, .7, 1]),
          boxShadow: [BoxShadow(color: const Color(0xFFFF3C32).withValues(alpha: .7), blurRadius: 16 * u), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 6 * u, offset: Offset(0, 5 * u))],
        );
      case BtnKind.ghost:
        deco = const BoxDecoration();
        fg = const Color(0xFFFFC58A);
    }
    final content = Row(mainAxisSize: MainAxisSize.min, children: [
      if (loading) ...[SizedBox(width: 34 * u, height: 34 * u, child: const CircularProgressIndicator(strokeWidth: 3, color: Colors.white)), SizedBox(width: 12 * u)],
      if (icon != null && !loading) ...[Icon(icon, size: 40 * u, color: fg), SizedBox(width: 12 * u)],
      Text(label, style: TextStyle(fontSize: (fontSize * u).clamp(12, 17), fontWeight: FontWeight.w800, color: fg, decoration: TextDecoration.none, shadows: [Shadow(color: Colors.black.withValues(alpha: .6), offset: Offset(0, 2 * u))])),
    ]);
    final body = Container(
      height: height * u,
      padding: EdgeInsets.symmetric(horizontal: hPad * u),
      decoration: deco,
      child: Stack(alignment: Alignment.center, children: [
        if (kind != BtnKind.ghost && kind != BtnKind.outline)
          Positioned(
            top: 4 * u,
            left: 14 * u,
            right: 14 * u,
            height: height * u * .38,
            child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .35), Colors.white.withValues(alpha: 0)]))),
          ),
        content,
      ]),
    );
    return Opacity(
      opacity: disabled ? .45 : 1,
      child: IgnorePointer(
        ignoring: disabled || loading,
        child: Press(u: u, radius: 999, scaleUp: 1.04, lift: 2, onTap: onTap ?? () {}, child: body),
      ),
    );
  }
}

/// Glowing status pill (Verified / Online / Draft / Failed / Anonymous) or stock indicator.
class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key, required this.u, required this.color, this.icon, this.dot = false, this.small = false});
  final String label;
  final double u;
  final Color color;
  final IconData? icon;
  final bool dot;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (small ? 54 : 70) * u,
      padding: EdgeInsets.symmetric(horizontal: (small ? 18 : 26) * u),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF07090C), Color(0xFF141B23)]),
        border: Border.all(color: color, width: 2.5 * u),
        boxShadow: [BoxShadow(color: color.withValues(alpha: .55), blurRadius: 10 * u), BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 5 * u, offset: Offset(0, 3 * u))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (dot) Container(width: 16 * u, height: 16 * u, margin: EdgeInsets.only(right: 10 * u), decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 8 * u)])),
        if (icon != null) Padding(padding: EdgeInsets.only(right: 8 * u), child: Icon(icon, size: 32 * u, color: color)),
        Text(label, style: TextStyle(fontSize: ((small ? 26 : 29) * u).clamp(10, 14), fontWeight: FontWeight.w800, color: color, decoration: TextDecoration.none, shadows: [Shadow(color: color.withValues(alpha: .8), blurRadius: 8 * u)])),
      ]),
    );
  }
}
