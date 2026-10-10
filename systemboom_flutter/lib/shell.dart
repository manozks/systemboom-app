import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'main.dart' show HomePage;
import 'pages/calls_page.dart';
import 'pages/anon_pages.dart';
import 'pages/chats_page.dart';
import 'pages/design_page.dart';
import 'pages/market_page.dart';
import 'pages/profile_page.dart';
import 'ui.dart';

/// Pages can be reached from the home screen and the dock. Set to false to turn all navigation off.
const bool kEnableNav = true;

const double kMaxW = 430;

extension UCtx on BuildContext {
  /// 1 design unit (artboard is 941 wide) in logical pixels.
  double get u => math.min(MediaQuery.sizeOf(this).width, kMaxW) / 941;
}

// ─────────────────────────────────────────────── navigation + toast

Widget _pageFor(String route) {
  switch (route) {
    case 'chats':
      return const ChatsPage();
    case 'calls':
      return const CallsPage();
    case 'market':
      return const MarketPage();
    case 'profile':
      return const ProfilePage();
    case 'design':
      return const DesignPage();
    case 'anonymous':
      return const AnonymousPage();
    default:
      return const HomePage();
  }
}

Route<void> _route(String r) => PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => _pageFor(r),
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, a, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .02), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
      ),
    );

/// Switch between the five main tabs (replaces the current page).
void goTab(BuildContext context, String route) {
  if (!kEnableNav) return;
  Navigator.of(context).pushAndRemoveUntil(_route(route), (r) => r.isFirst && false);
}

/// Open a sub page on top (back returns).
void openPage(BuildContext context, String route) {
  if (!kEnableNav) return;
  Navigator.of(context).push(_route(route));
}

OverlayEntry? _toastEntry;
Timer? _toastTimer;

void showToast(BuildContext context, String msg) {
  _toastTimer?.cancel();
  _toastEntry?.remove();
  final u = context.u;
  final e = OverlayEntry(
    builder: (_) => Positioned(
      left: 0,
      right: 0,
      bottom: 270 * u,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xF20A0E14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x99FF9632)),
              boxShadow: const [BoxShadow(color: Color(0x80FF7814), blurRadius: 14)],
            ),
            child: Text(msg, style: const TextStyle(fontSize: 13, color: Colors.white, decoration: TextDecoration.none, fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    ),
  );
  _toastEntry = e;
  Overlay.of(context, rootOverlay: true).insert(e);
  _toastTimer = Timer(const Duration(milliseconds: 1600), () {
    e.remove();
    if (_toastEntry == e) _toastEntry = null;
  });
}

// ─────────────────────────────────────────────── page shell

class PageShell extends StatefulWidget {
  const PageShell({
    super.key,
    required this.title,
    required this.active,
    required this.children,
    this.brand = 'SYSTEMBOOM',
    this.right,
    this.searchHint,
    this.onSearch,
    this.tabs,
    this.tab = 0,
    this.onTab,
    this.showDock = true,
    this.titleSize = 66,
    this.headerArt,
    this.footer,
    this.bottomPad,
    this.controller,
    this.headerExtra,
    this.hideTitle = false,
  });

  final String title;
  final String brand;
  final String active; // dock highlight: home | chats | calls | market | profile
  final List<Widget> children;
  final Widget? right;
  final String? searchHint;
  final ValueChanged<String>? onSearch;
  final List<String>? tabs;
  final int tab;
  final ValueChanged<int>? onTab;
  final bool showDock;
  final double titleSize;
  final String? headerArt; // optional full header artwork (title baked in), 854x209
  final Widget? footer;
  final double? bottomPad;
  final ScrollController? controller;
  final Widget Function(BuildContext, double u, double w, double h)? headerExtra;
  final bool hideTitle;

  @override
  State<PageShell> createState() => _PageShellState();
}

class _PageShellState extends State<PageShell> with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = math.min(MediaQuery.sizeOf(context).width, kMaxW);
    final u = w / 941;
    final kk = w / 878;
    return Scaffold(
      backgroundColor: const Color(0xFF07090C),
      body: Center(
        child: SizedBox(
          width: w,
          child: Stack(children: [
            const Positioned.fill(child: CarbonBg()),
            Column(children: [
              _header(context, u, kk),
              if (widget.searchHint != null) _search(u),
              if (widget.tabs != null) _tabs(u),
              Expanded(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (r) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xFF000000)], stops: [0, .03]).createShader(r),
                  child: ListView(
                    controller: widget.controller,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(26 * u, 16 * u, 26 * u, (widget.bottomPad ?? (widget.showDock ? 330 : 60)) * u),
                    children: widget.children,
                  ),
                ),
              ),
            ]),
            if (widget.showDock)
              Positioned(left: 0, right: 0, bottom: 0, child: Dock(active: widget.active, loop: _loop)),
            if (widget.footer != null) Positioned(left: 0, right: 0, bottom: 0, child: widget.footer!),
            // device rim + vignette
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(radius: 1.15, colors: [Color(0x00000000), Color(0x00000000), Color(0x59000000)], stops: [0, .78, 1]),
                    border: Border.symmetric(vertical: BorderSide(color: const Color(0xFF2A3138), width: 3 * u)),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, double u, double kk) {
    final art = widget.headerArt;
    final h = art != null ? 209 * (math.min(MediaQuery.sizeOf(context).width, kMaxW) / 854) : 252 * kk;
    return SizedBox(
      height: h,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(child: Image.asset('assets/images/${art ?? 'hero-header'}.webp', fit: BoxFit.fill)),
        if (art == null) Positioned(
          left: 0,
          right: 0,
          top: 30 * kk,
          child: Center(
            child: Text(widget.brand,
                style: TextStyle(
                  fontSize: (24 * u).clamp(10, 13),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: const Color(0xFFD4DBE2),
                  shadows: [Shadow(color: Colors.black, offset: Offset(0, -1 * u)), Shadow(color: const Color(0x66FFFFFF), offset: Offset(0, 1.5 * u))],
                )),
          ),
        ),
        if (art != null && !widget.hideTitle) Positioned(left: 0, right: 0, top: h * .47, child: FractionalTranslation(translation: const Offset(0, -.5), child: Center(child: Embossed(widget.title, fontSize: (widget.titleSize * u * 1.05).clamp(22, 34), u: u)))),
        if (art == null) Positioned(
          left: 0,
          right: 0,
          top: 98 * kk, // same centre line as the back / bell buttons
          child: FractionalTranslation(
            translation: const Offset(0, -.5),
            child: Center(child: Embossed(widget.title, fontSize: (widget.titleSize * u).clamp(20, 32), u: u)),
          ),
        ),
        Positioned(
          left: (art != null ? 82 * (kk * 878 / 854) : 80 * kk) - 42 * u,
          top: (art != null ? h * .47 : 98 * kk) - 42 * u,
          width: 84 * u,
          height: 84 * u,
          child: ChromeBtn(
            u: u,
            onTap: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                goTab(context, 'home');
              }
            },
            child: Icon(Icons.chevron_left_rounded, size: 52 * u, color: const Color(0xFFDFE6EE)),
          ),
        ),
        if (widget.headerExtra != null) Positioned.fill(child: widget.headerExtra!(context, u, math.min(MediaQuery.sizeOf(context).width, kMaxW), h)),
        if (widget.right != null)
          Positioned(left: (art != null ? 790 * (kk * 878 / 854) : 796 * kk) - 45 * u, top: (art != null ? h * .47 : 98 * kk) - 45 * u, width: 90 * u, height: 90 * u, child: widget.right!),
      ]),
    );
  }

  Widget _search(double u) {
    return Padding(
      padding: EdgeInsets.fromLTRB(34 * u, 8 * u, 34 * u, 12 * u),
      child: LayoutBuilder(builder: (context, c) {
        final k = c.maxWidth / 851;
        return SizedBox(
          height: 83 * k,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: Image.asset('assets/images/search-bar.webp', fit: BoxFit.fill)),
            Positioned.fill(
              child: Row(children: [
                SizedBox(width: 34 * k),
                Icon(Icons.search_rounded, size: 40 * k, color: Colors.white),
                SizedBox(width: 16 * k),
                Expanded(
                  child: TextField(
                    onChanged: widget.onSearch,
                    cursorColor: const Color(0xFFFFB866),
                    style: TextStyle(color: Colors.white, fontSize: (27 * k).clamp(12, 17)),
                    decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: widget.searchHint, hintStyle: TextStyle(color: const Color(0xFFD3DBE4), fontSize: (27 * k).clamp(11, 16))),
                  ),
                ),
                SizedBox(width: 34 * k),
              ]),
            ),
          ]),
        );
      }),
    );
  }

  Widget _tabs(double u) {
    final tabs = widget.tabs!;
    return Padding(
      padding: EdgeInsets.fromLTRB(34 * u, 24 * u, 34 * u, 0),
      child: Well(
        u: u,
        height: 118,
        child: Padding(
          padding: EdgeInsets.all(5 * u),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(children: [
              for (var i = 0; i < tabs.length; i++) ...[
                if (i > 0) SizedBox(width: 8 * u),
                _TabKey(u: u, label: tabs[i], on: i == widget.tab, expand: tabs.length <= 3, onTap: () => widget.onTab?.call(i)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────── dock

class Dock extends StatelessWidget {
  const Dock({super.key, required this.active, required this.loop});
  final String active;
  final AnimationController loop;

  @override
  Widget build(BuildContext context) {
    final w = math.min(MediaQuery.sizeOf(context).width, kMaxW);
    final k = w / 896;
    final u = w / 941;
    return SizedBox(
      width: w,
      height: 215 * k,
      child: AnimatedBuilder(
        animation: loop,
        builder: (context, _) {
          final t = loop.value * 60;
          Widget item(String id, String label, double x, double y, double bw, double bh, double cx, double cy, double phase) {
            final on = active == id;
            final bob = -3 * k * math.sin(2 * math.pi * (t / 3.6 + phase));
            final period = 6.5 + phase * 2;
            final q = ((t + phase * 5) % period) / period;
            double rot = 0, hop = 0;
            if (q > .82 && q < .96) {
              final z = (q - .82) / .14;
              rot = math.sin(z * math.pi * 4) * .16 * (1 - z);
              hop = -math.sin(z * math.pi) * 7 * k;
            }
            return Positioned(
              left: x * k,
              top: y * k,
              width: bw * k,
              height: bh * k,
              child: Press(
                u: u,
                radius: 30,
                scaleUp: 1.06,
                lift: 2,
                shine: false,
                onTap: () => id == 'home' ? goTab(context, 'home') : goTab(context, id),
                builder: (context, g, hs) => Stack(clipBehavior: Clip.none, children: [
                  Positioned(
                    left: (cx - 32 - x) * k,
                    top: (cy - 32 - y) * k,
                    width: 64 * k,
                    height: 64 * k,
                    child: Transform.translate(
                      offset: Offset(0, bob + hop + hoverDy(label, hs, k)),
                      child: Transform.rotate(
                        angle: rot + hoverRot(label, hs),
                        child: Transform.scale(
                          scale: hoverScale(label, hs),
                          child: CustomPaint(painter: NavGlyph(id, on ? 1 : g)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            );
          }

          Widget lab(double x, String s, bool on, {bool calls = false}) => Positioned(
                left: x * k,
                top: 141 * k,
                width: 120 * k,
                child: Text(s,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (27 * u).clamp(11, 15),
                      fontWeight: FontWeight.w700,
                      height: 1,
                      decoration: TextDecoration.none,
                      color: on ? const Color(0xFFFFD9A6) : (calls ? const Color(0xFFFFE9D0) : const Color(0xFFF1F4F7)),
                      shadows: [
                        if (calls || on) Shadow(color: const Color(0xCCFF7814), blurRadius: 8 * u),
                        Shadow(color: const Color(0xCC000000), offset: Offset(0, 1.5 * u), blurRadius: 2 * u),
                      ],
                    )),
              );

          return Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: Image.asset('assets/images/dock.webp', fit: BoxFit.fill)),
            item('home', 'Home', 38, 62, 104, 118, 85, 105, 0),
            item('chats', 'Chats', 205, 72, 105, 106, 258, 108, .25),
            item('market', 'Market', 575, 68, 112, 110, 628, 108, .5),
            item('profile', 'Profile', 752, 72, 96, 106, 800, 108, .75),
            lab(23, 'Home', active == 'home'),
            lab(197, 'Chats', active == 'chats'),
            lab(380, 'Calls', active == 'calls', calls: true),
            lab(568, 'Market', active == 'market'),
            lab(740, 'Profile', active == 'profile'),
            // unread badge on Chats
            Positioned(left: 272 * k, top: 62 * k, child: RedBadge(text: '10', size: 46 * u, scale: 1 + .06 * math.max(0, math.sin(t * 2 * math.pi / 4.5)))),
            // Calls orb: the art's own button, animated on hover
            Positioned(
              left: 374 * k,
              top: 2 * k,
              width: 148 * k,
              height: 148 * k,
              child: Press(
                u: u,
                circle: true,
                scaleUp: 1.08,
                lift: 5,
                onTap: () => goTab(context, 'calls'),
                builder: (context, g, hs) => OverflowBox(
                  maxWidth: 152 * k,
                  maxHeight: 152 * k,
                  child: Transform.rotate(
                    angle: .09 * math.sin(hs * math.pi * 3) * (1 - hs),
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(<double>[
                        1 + .16 * g, 0, 0, 0, 5 * g,
                        0, 1 + .16 * g, 0, 0, 5 * g,
                        0, 0, 1 + .16 * g, 0, 5 * g,
                        0, 0, 0, 1, 0,
                      ]),
                      child: Image.asset('assets/images/nav-calls.webp', width: 152 * k, height: 152 * k, fit: BoxFit.fill),
                    ),
                  ),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────── shared widgets

class CarbonBg extends StatelessWidget {
  const CarbonBg({super.key});

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF070A0E),
        image: DecorationImage(image: const AssetImage('assets/images/carbon-tile.webp'), repeat: ImageRepeat.repeat, scale: 68 / (18 * u), filterQuality: FilterQuality.medium),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1),
            radius: 1.2,
            colors: [const Color(0xFFFF7A1A).withValues(alpha: .08), const Color(0x00FF7A1A)],
            stops: const [0, .6],
          ),
        ),
      ),
    );
  }
}

/// Recessed steel well with a chrome lip (search + tab tracks).
class Well extends StatelessWidget {
  const Well({super.key, required this.u, required this.height, required this.child});
  final double u;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height * u,
      padding: EdgeInsets.all(6 * u),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFC3CBD2), Color(0xFF6B757E), Color(0xFF1B2127), Color(0xFF0B0E11), Color(0xFF59626B), Color(0xFFE9EEF2), Color(0xFF9AA3AB)],
          stops: [0, .1, .24, .42, .55, .74, .92, 1],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 12 * u, offset: Offset(0, 8 * u)),
          BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .22), blurRadius: 20 * u),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Stack(fit: StackFit.expand, children: [
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF02050A), Color(0xFF0A1119), Color(0xFF101A25)]))),
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              widthFactor: .92,
              heightFactor: .38,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .13), Colors.white.withValues(alpha: 0)]),
                ),
              ),
            ),
          ),
          child,
        ]),
      ),
    );
  }
}

class _TabKey extends StatelessWidget {
  const _TabKey({required this.u, required this.label, required this.on, required this.expand, required this.onTap});
  final double u;
  final String label;
  final bool on;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final key = Press(
      u: u,
      radius: 999,
      scaleUp: 1.03,
      lift: 1.5,
      onTap: onTap,
      child: Container(
        height: 96 * u,
        constraints: BoxConstraints(minWidth: 140 * u),
        padding: EdgeInsets.symmetric(horizontal: 26 * u),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: on
              ? const RadialGradient(center: Alignment(0, -1), radius: 1.6, colors: [Color(0xFFFFD9A0), Color(0xFFFF9A3A), Color(0xFFE5560A), Color(0xFF8F2A02)], stops: [0, .28, .68, 1])
              : const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF6D7882), Color(0xFF3A444E), Color(0xFF1B2229), Color(0xFF2A333C)], stops: [0, .14, .52, 1]),
          border: Border.all(color: on ? const Color(0xFF5A1D02) : Colors.black.withValues(alpha: .8), width: 2 * u),
          boxShadow: [
            if (on) BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .9), blurRadius: 18 * u),
            BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 6 * u, offset: Offset(0, 4 * u)),
          ],
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: (33 * u).clamp(13, 16),
              fontWeight: FontWeight.w800,
              color: on ? Colors.white : const Color(0xFFC4CFDB),
              decoration: TextDecoration.none,
              shadows: [Shadow(color: on ? const Color(0xCC5A1400) : Colors.black, offset: Offset(0, 2 * u))],
            )),
      ),
    );
    return expand ? Expanded(child: key) : key;
  }
}

/// Round chrome button (back, bell, …).
class ChromeBtn extends StatelessWidget {
  const ChromeBtn({super.key, required this.u, required this.child, required this.onTap, this.gold = false, this.badge});
  final double u;
  final Widget child;
  final VoidCallback onTap;
  final bool gold;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Press(
      u: u,
      circle: true,
      scaleUp: 1.1,
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: gold
                    ? const [Color(0xFFFFF6D0), Color(0xFFE0AA38), Color(0xFF6B4308), Color(0xFFF0C864), Color(0xFFFFF0B8), Color(0xFFFFF6D0)]
                    : const [Colors.white, Color(0xFF8B949D), Color(0xFF1C2229), Color(0xFFAAB3BB), Colors.white],
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 7 * u, offset: Offset(0, 5 * u)),
                if (gold) BoxShadow(color: const Color(0xFFFFAA28).withValues(alpha: .6), blurRadius: 16 * u),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(5 * u),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(center: const Alignment(-.3, -.5), colors: gold ? const [Color(0xFF3A2A10), Color(0xFF0E0904)] : const [Color(0xFF2B3540), Color(0xFF0B0F13)], stops: const [0, .75]),
                ),
                child: Center(child: child),
              ),
            ),
          ),
        ),
        if (badge != null) Positioned(right: -14 * u, top: -14 * u, child: RedBadge(text: badge!, size: 46 * u)),
      ]),
    );
  }
}

/// Chrome-ringed round avatar (initials / icon) with a coloured glow and optional status dot.
class ChromeAvatar extends StatelessWidget {
  const ChromeAvatar({super.key, required this.u, required this.size, required this.color, this.child, this.dot, this.glow});
  final double u;
  final double size;
  final Color color;
  final Widget? child;
  final Color? dot;
  final Color? glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * u,
      height: size * u,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(colors: [Colors.white, Color(0xFF9AA3AC), Color(0xFF2A3138), Color(0xFFC9D0D6), Color(0xFF5B656E), Colors.white]),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: .85), blurRadius: 9 * u, offset: Offset(0, 6 * u)),
                BoxShadow(color: (glow ?? color).withValues(alpha: glow != null ? .9 : .55), blurRadius: (glow != null ? 20 : 16) * u),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(5.5 * u),
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: const Alignment(-.3, -.5), radius: 1, colors: [Color.lerp(color, Colors.white, .15)!, color, Color.lerp(color, Colors.black, .5)!], stops: const [0, .5, 1])),
                child: Stack(children: [
                  Align(alignment: const Alignment(-.2, -.7), child: FractionallySizedBox(widthFactor: .6, heightFactor: .32, child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .35), Colors.white.withValues(alpha: 0)]))))),
                  Center(child: child),
                ]),
              ),
            ),
          ),
        ),
        if (dot != null)
          Positioned(
            right: -4 * u,
            bottom: -2 * u,
            child: Container(
              width: 30 * u,
              height: 30 * u,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dot, border: Border.all(color: const Color(0xFF0D1117), width: 4 * u), boxShadow: [BoxShadow(color: dot!, blurRadius: 8 * u)]),
            ),
          ),
      ]),
    );
  }
}

/// Wide steel plate row (same art as the Start a conversation / Design System cards).
class RowCard extends StatelessWidget {
  const RowCard({super.key, required this.u, required this.onTap, required this.leading, required this.title, this.subtitle, this.trailing, this.titleColors, this.hot = false, this.minHeight = 156, this.onLong});
  final VoidCallback? onLong;
  final double u;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Color>? titleColors;
  final bool hot;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final tc = titleColors ?? const [Colors.white, Color(0xFFDFE6EE), Color(0xFF9AA6B2)];
    return Padding(
      padding: EdgeInsets.only(bottom: 14 * u),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPress: onLong,
        onSecondaryTap: onLong,
        child: Press(
        u: u,
        radius: 34,
        lift: 3,
        onTap: onTap,
        child: Stack(children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30 * u),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 12 * u, offset: Offset(0, 9 * u)),
                  BoxShadow(color: const Color(0xFFFF8C32).withValues(alpha: hot ? .5 : .25), blurRadius: (hot ? 22 : 14) * u),
                ],
              ),
              child: Stack(fit: StackFit.passthrough, children: [
                Positioned.fill(child: Image.asset('assets/images/cta-blank-wide.webp', fit: BoxFit.fill)),
                Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * u), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .12), Colors.white.withValues(alpha: 0), const Color(0xFFFF9A3A).withValues(alpha: .12)], stops: const [0, .5, 1]))))),
              ]),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight * u),
            child: Padding(
              padding: EdgeInsets.fromLTRB(46 * u, 22 * u, 40 * u, 22 * u),
              child: Row(children: [
                leading,
                SizedBox(width: 24 * u),
                Expanded(
                  child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (r) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: tc).createShader(r),
                      child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: (42 * u).clamp(15, 21), fontWeight: FontWeight.w800, height: 1.1, color: Colors.white, decoration: TextDecoration.none, shadows: [Shadow(color: const Color(0x99000000), offset: Offset(0, 1.5 * u))])),
                    ),
                    if (subtitle != null) ...[SizedBox(height: 8 * u), subtitle!],
                  ]),
                ),
                if (trailing != null) ...[SizedBox(width: 14 * u), trailing!],
              ]),
            ),
          ),
        ]),
      ),
      ),
    );
  }
}

TextStyle subStyle(double u, {Color color = const Color(0xFFC3CEDB), bool shadow = true}) => TextStyle(
      fontSize: (31 * u).clamp(12, 15),
      height: 1.25,
      color: color,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.none,
      shadows: shadow ? [Shadow(color: const Color(0xE6000000), offset: Offset(0, 2 * u), blurRadius: 3 * u)] : null,
    );

/// Code-drawn framed glass panel (chrome rim, blue glass face, gloss) for cards that are not wide.
class MetalBox extends StatelessWidget {
  const MetalBox({super.key, required this.u, required this.child, this.padding, this.radius = 30, this.glow = const Color(0xFFFF7A1A), this.hot = false});
  final double u;
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final Color glow;
  final bool hot;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius * u),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF4E4), Color(0xFFE9A868), Color(0xFF2A3138), Color(0xFF0E1215), Color(0xFFB87A44), Color(0xFFFFE2BD)],
          stops: [0, .14, .36, .54, .76, 1],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .75), blurRadius: 16 * u, offset: Offset(0, 10 * u)),
          BoxShadow(color: glow.withValues(alpha: hot ? .5 : .3), blurRadius: (hot ? 24 : 18) * u),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(7 * u),
        child: ClipRRect(
          borderRadius: BorderRadius.circular((radius - 6) * u),
          child: Stack(children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2D4C7A), Color(0xFF16294A), Color(0xFF0A1425)], stops: [0, .45, 1])),
              ),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: RadialGradient(center: Alignment(-.8, -1), radius: 1.1, colors: [Color(0x6664A0FF), Color(0x0064A0FF)])),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.topCenter,
                child: FractionallySizedBox(
                  heightFactor: .45,
                  child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .2), Colors.white.withValues(alpha: .02)]))),
                ),
              ),
            ),
            Padding(padding: padding ?? EdgeInsets.all(20 * u), child: child),
          ]),
        ),
      ),
    );
  }
}

/// Small engraved section label.
class SecLabel extends StatelessWidget {
  const SecLabel(this.text, {super.key, required this.u});
  final String text;
  final double u;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(10 * u, 34 * u, 0, 14 * u),
        child: Text(text.toUpperCase(),
            style: TextStyle(
              fontSize: (28 * u).clamp(11, 13),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: const Color(0xFFC7CFD7),
              decoration: TextDecoration.none,
              shadows: [Shadow(color: const Color(0x33FFFFFF), offset: Offset(0, 1.5 * u)), Shadow(color: const Color(0xE6000000), offset: Offset(0, -1.5 * u))],
            )),
      );
}

/// Blue glass info banner.
class NoteBanner extends StatelessWidget {
  const NoteBanner({super.key, required this.u, required this.icon, required this.text});
  final double u;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 18 * u),
      padding: EdgeInsets.all(4 * u),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30 * u),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFF8B949D), Color(0xFF2A3138), Color(0xFF8B949D), Colors.white]),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 10 * u, offset: Offset(0, 6 * u)), BoxShadow(color: const Color(0xFF50A0FF).withValues(alpha: .25), blurRadius: 14 * u)],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 26 * u, vertical: 20 * u),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27 * u),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x8C285A8C), Color(0xCC0A1C30)]),
        ),
        child: Row(children: [
          Icon(icon, size: 46 * u, color: const Color(0xFF6BD0FF), shadows: [Shadow(color: const Color(0xE650BEFF), blurRadius: 8 * u)]),
          SizedBox(width: 16 * u),
          Expanded(child: Text(text, style: TextStyle(fontSize: (29 * u).clamp(11, 14), height: 1.35, color: const Color(0xFFCFE6F7), decoration: TextDecoration.none, shadows: [Shadow(color: Colors.black, offset: Offset(0, 2 * u))]))),
        ]),
      ),
    );
  }
}

/// List row styled like the search block: its own rounded block with a chrome lip and a dark-glass body.
class CleanRow extends StatelessWidget {
  const CleanRow({super.key, required this.u, required this.onTap, required this.leading, required this.title, this.subtitle, this.trailing, this.titleColors, this.last = false});
  final double u;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Color>? titleColors;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final tc = titleColors ?? const [Colors.white, Colors.white];
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * u),
      child: Press(
        u: u,
        radius: 46,
        lift: 2,
        scaleUp: 1.012,
        shine: false,
        onTap: onTap,
        builder: (context, g, s) {
          final gg = g.clamp(0.0, 1.0);
          return Container(
            padding: EdgeInsets.all(5 * u),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(46 * u),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFC3CBD2), Color(0xFF6B757E), Color(0xFF1B2127), Color(0xFF0B0E11), Color(0xFF59626B), Color(0xFFE9EEF2), Color(0xFF9AA3AB)],
                stops: [0, .1, .24, .42, .55, .74, .92, 1],
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: .75), blurRadius: 10 * u, offset: Offset(0, 7 * u)),
                BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .14 + .2 * gg), blurRadius: 16 * u),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(41 * u),
              child: Stack(children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color.lerp(const Color(0xFF02050A), const Color(0xFF0C1622), gg)!, Color.lerp(const Color(0xFF0A1119), const Color(0xFF142234), gg)!, Color.lerp(const Color(0xFF101A25), const Color(0xFF1A2C42), gg)!],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20 * u,
                  right: 20 * u,
                  top: 4 * u,
                  height: 34 * u,
                  child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .13), Colors.white.withValues(alpha: 0)]))),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(26 * u, 18 * u, 24 * u, 18 * u),
                  child: Row(children: [
                    leading,
                    SizedBox(width: 24 * u),
                    Expanded(
                      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (r) => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: tc).createShader(r),
                          child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: (43 * u).clamp(16, 22), fontWeight: FontWeight.w800, height: 1.1, color: Colors.white, decoration: TextDecoration.none)),
                        ),
                        if (subtitle != null) ...[SizedBox(height: 8 * u), subtitle!],
                      ]),
                    ),
                    if (trailing != null) ...[SizedBox(width: 14 * u), trailing!],
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
