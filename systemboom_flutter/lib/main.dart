import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'shell.dart';
import 'ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const SystemBoomApp());
}

class SystemBoomApp extends StatelessWidget {
  const SystemBoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SYSTEMBOOM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07090C),
        useMaterial3: true,
        fontFamily: 'Figtree',
      ),
      home: const HomePage(),
    );
  }
}

/// Reference artboard is 941 units wide; every size below is expressed in
/// those units and scaled by [u] (= stage width / 941), exactly like the web version.
const double kStageW = 941;
const double kStageH = 2097;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  final ValueNotifier<String?> _toast = ValueNotifier<String?>(null);
  int _toastId = 0;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 60))..repeat();
  }

  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // decode the art up front so the first frame doesn't pop images in one by one
    for (final n in const [
      'hero-nobomb.webp', 'logo-lockup.webp', 'greeting.webp', 'cta.webp', 'card-base-blue.webp', 'card-base-dark.webp',
      'ico-chat-ref.webp', 'ico-call-ref.webp', 'ico-mk.webp', 'ico-an.webp', 'ico-ds.webp', 'cta-blank-wide.webp', 'ai-nav.webp',
      'nav-calls.webp', 'hero-header.webp', 'dock.webp', 'hdr-calls.webp', 'brand-colors.webp', 'typography.webp', 'cta-new.webp', 'greeting-new.webp', 'buttons-panel.webp', 'icons-panel.webp', 'icon-key.webp', 'search-bar.webp', 'tabs-base.webp', 'tabs-key.webp', 'carbon-tile.png', 'profile.jpg',
    ]) {
      precacheImage(AssetImage('assets/images/$n'), context);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _toast.dispose();
    super.dispose();
  }

  /// seconds elapsed (looping), used by every animation
  double get _t => _loop.value * 60;

  void _tap(String label) {
    HapticFeedback.selectionClick();
    // pages reachable from the home screen (turn off with kEnableNav in shell.dart)
    const routes = <String, String>{
      'Chats': 'chats',
      'Starting a conversation': 'chats',
      'Calls': 'calls',
      'Marketplace': 'market',
      'Market': 'market',
      'Profile': 'profile',
      'Design System': 'design',
    };
    final r = routes[label];
    if (kEnableNav && r != null) {
      if (r == 'design') {
        openPage(context, r);
      } else {
        goTab(context, r);
      }
      return;
    }
    final id = ++_toastId;
    _toast.value = label;
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      if (id == _toastId) _toast.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth;
            final u = w / kStageW;
            return Stack(children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: w,
                  height: kStageH * u,
                  child: AnimatedBuilder(
                    animation: _loop,
                    builder: (context, _) => _Stage(u: u, t: _t, onTap: _tap),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 120 * u,
                child: IgnorePointer(child: _ToastView(notifier: _toast)),
              ),
            ]);
          }),
        ),
      ),
    );
  }
}

class _ToastView extends StatelessWidget {
  const _ToastView({required this.notifier});
  final ValueNotifier<String?> notifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: notifier,
      builder: (context, v, _) => AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: v == null ? 0 : 1,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xF20A0E14),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x99FF9632)),
              boxShadow: const [BoxShadow(color: Color(0x80FF7814), blurRadius: 14)],
            ),
            child: Text(v ?? '', style: const TextStyle(fontSize: 13, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────── stage

class _Stage extends StatelessWidget {
  const _Stage({required this.u, required this.t, required this.onTap});
  final double u;
  final double t;
  final void Function(String) onTap;

  Widget at(double x, double y, double w, double h, Widget child) =>
      Positioned(left: x * u, top: y * u, width: w * u, height: h * u, child: child);

  /// A section drawn at design size then scaled from its top-left corner (the web page does the same).
  Widget section(double x, double y, double w, double h, double scale, List<Widget> children) => Positioned(
        left: x * u,
        top: y * u,
        child: RepaintBoundary(
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topLeft,
            child: SizedBox(width: w * u, height: h * u, child: Stack(clipBehavior: Clip.none, children: children)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(70 * u),
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(child: _Background(u: u)),
        _hero(),
        _greeting(),
        _cta(),
        at(37, 848, 300, 40, _label('EXPLORE')),
        _card(26, 895, 'card-base-blue', 'ico-chat-ref', 95, null, Colors.white, 'Chats', 'Direct & group', 'chats',
            badge: '10', badgeColors: const [Color(0xFFFF7B7B), Color(0xFFE11D1D), Color(0xFF7F0B0B)], badgeText: Colors.white),
        _card(475, 895, 'card-base-dark', 'ico-call-ref', 85, null, Colors.white, 'Calls', 'Voice & video', 'calls'),
        _card(26, 1135, 'card-base-dark', 'ico-mk', 85, Icons.storefront_outlined, const Color(0xFFFFE6B0), 'Marketplace',
            'Shop in chat', 'marketplace',
            badge: '1',
            badgeColors: const [Color(0xFFFFD37A), Color(0xFFE09A1C), Color(0xFFB36F08)],
            badgeText: const Color(0xFF2A1700),
            glow: const Color(0xFFFFB432)),
        _card(475, 1135, 'card-base-dark', 'ico-an', 85, Icons.masks_outlined, const Color(0xFFB6FFF4), 'Anonymous',
            'Speak freely', 'anonymous',
            badge: '3',
            badgeColors: const [Color(0xFF7CFFF0), Color(0xFF12BFB0), Color(0xFF0A7F76)],
            badgeText: const Color(0xFF032A27),
            glow: const Color(0xFF28EBD7)),
        _designSystem(),
        _aiAndNav(),
        // outer device rim + vignette
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(70 * u),
                border: Border.all(color: const Color(0xFFB9C2CB), width: 3 * u),
                gradient: const RadialGradient(
                  radius: 1.1,
                  colors: [Color(0x00000000), Color(0x00000000), Color(0x59000000)],
                  stops: [0, .78, 1],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ───────────────────────── pieces

  Widget _label(String s) => Text(s,
      style: TextStyle(
        fontSize: (30 * u).clamp(13, 18),
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: const Color(0xFFC7CFD7),
        shadows: [
          Shadow(color: const Color(0x40FFFFFF), offset: Offset(0, 1.5 * u)),
          Shadow(color: const Color(0xE6000000), offset: Offset(0, -1.5 * u)),
        ],
      ));

  Widget _hero() {
    final sparkRect = Rect.fromLTWH(861 * .35, 355 * .28, 861 * .30, 355 * .40);
    final pulse = .6 + .4 * math.sin(t * 2 * math.pi / 5);
    return section(21, 29, 861, 355, 1.038, [
      Positioned.fill(
        child: ClipPath(
          clipper: _HeroClipper(),
          child: Image.asset('assets/images/hero-nobomb.webp', fit: BoxFit.fill),
        ),
      ),
      // pulsing glow on the platform
      Positioned(
        left: 861 * .27 * u,
        top: 355 * .66 * u,
        width: 861 * .46 * u,
        height: 355 * .24 * u,
        child: IgnorePointer(
          child: Opacity(
            opacity: pulse,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                gradient: RadialGradient(colors: [Color(0x8CFFAA3C), Color(0x33FF7814), Color(0x00FF7814)], stops: [0, .5, .72]),
              ),
            ),
          ),
        ),
      ),
      // spark cloud above the platform
      Positioned(
        left: sparkRect.left * u,
        top: sparkRect.top * u,
        width: sparkRect.width * u,
        height: sparkRect.height * u,
        child: IgnorePointer(child: CustomPaint(painter: _SparkPainter(t: t, u: u))),
      ),
      // logo lock-up (bomb + SYSTEMBOOM)
      Positioned(
        left: 78 * u,
        top: 62 * u,
        width: 600 * u,
        child: IgnorePointer(
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (r) => const LinearGradient(
              colors: [Color(0x00000000), Color(0xFF000000), Color(0xFF000000), Color(0x00000000)],
              stops: [0, .05, .95, 1],
            ).createShader(r),
            child: Image.asset('assets/images/logo-lockup.webp', fit: BoxFit.fitWidth),
          ),
        ),
      ),
      // notification badge + bell hit area
      Positioned(
        left: 790 * u,
        top: 55 * u,
        width: 37 * u,
        height: 37 * u,
        child: IgnorePointer(child: RedBadge(text: '14', size: 37 * u, scale: 1 + .06 * math.max(0, math.sin(t * 2 * math.pi / 5))) ),
      ),
      Positioned(
        left: 742 * u,
        top: 40 * u,
        width: 100 * u,
        height: 100 * u,
        child: Press(u: u, circle: true, scaleUp: 1.1, onTap: () => onTap('Notifications'), child: const SizedBox.expand()),
      ),
    ]);
  }

  Widget _greeting() {
    return section(21, 411, 865, 206, 1.025, [
      // reference art: steel plate, segmented chrome ring with the profile photo, orange edge glow
      Positioned.fill(child: Image.asset('assets/images/greeting-new.webp', fit: BoxFit.fill)),
      Positioned(
        left: 70 * u,
        top: 30 * u,
        width: 150 * u,
        height: 150 * u,
        child: Press(u: u, circle: true, scaleUp: 1.05, shine: false, onTap: () => onTap('Change profile photo'), child: const SizedBox.expand()),
      ),
      Positioned(
        left: 278 * u,
        top: 40 * u,
        child: Text('GOOD MORNING',
            style: TextStyle(
              fontSize: (27 * u).clamp(11, 15),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: const Color(0xFFE8ECF1),
              shadows: [
                Shadow(color: Colors.black, offset: Offset(0, -1 * u)),
                Shadow(color: const Color(0x80FFFFFF), offset: Offset(0, 1.5 * u)),
                Shadow(color: const Color(0xB3000000), offset: Offset(0, 3 * u), blurRadius: 3 * u),
              ],
            )),
      ),
      Positioned(
        left: 268 * u,
        top: 72 * u,
        child: Embossed('Aarav Sharma', fontSize: (74 * u).clamp(26, 44), u: u),
      ),
    ]);
  }

  Widget _cta() {
    return section(24, 621, 856, 216, 1.026, [
      // reference art: steel plate with glowing edges and the orange arrow button; text is live
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34 * u),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .75), blurRadius: 16 * u, offset: Offset(0, 12 * u)), BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .42), blurRadius: 24 * u)],
          ),
          child: Image.asset('assets/images/cta-new.webp', fit: BoxFit.fill),
        ),
      ),
      // glass: bright cap highlight on the upper half + warm light along the lower edge
      Positioned.fill(
        child: IgnorePointer(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14 * u, vertical: 12 * u),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26 * u),
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .16), Colors.white.withValues(alpha: .03), Colors.transparent, const Color(0xFFFF9A3A).withValues(alpha: .13)], stops: const [0, .35, .6, 1]),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 50 * u,
        top: 38 * u,
        width: 600 * u,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GradText(
            'Start a conversation',
            colors: const [Color(0xFFFFF0D2), Color(0xFFFFCF8F), Color(0xFFFF9A3A), Color(0xFFFFD199)],
            stops: const [0, .35, .6, 1],
            style: TextStyle(fontSize: (46 * u).clamp(18, 27), fontWeight: FontWeight.w800, height: 1.15, decoration: TextDecoration.none),
            shadow: const Color(0xFF3B1A04),
            u: u,
          ),
          SizedBox(height: 8 * u),
          Text('Everything begins with a chat — decisions, calls, and purchases.',
              style: TextStyle(
                fontSize: (31 * u).clamp(12, 18),
                height: 1.22,
                color: const Color(0xFFF2F4F7),
                decoration: TextDecoration.none,
                shadows: [Shadow(color: const Color(0xB3000000), offset: Offset(0, 2 * u), blurRadius: 2 * u)],
              )),
        ]),
      ),
      // tap area over the art's orange button
      Positioned(
        left: 672 * u,
        top: 38 * u,
        width: 138 * u,
        height: 138 * u,
        child: Press(u: u, circle: true, scaleUp: 1.07, onTap: () => onTap('Starting a conversation'), child: const SizedBox.expand()),
      ),
    ]);
  }

  Widget _card(
    double x,
    double y,
    String base,
    String tile,
    double tileW,
    IconData? icon,
    Color iconColor,
    String title,
    String sub,
    String action, {
    String? badge,
    List<Color>? badgeColors,
    Color? badgeText,
    Color glow = const Color(0xFFFF9632),
  }) {
    final pulse = .85 + .15 * math.sin(t * 2 * math.pi / 3.4 + x);
    return Positioned(
      left: x * u,
      top: y * u,
      width: 429 * u,
      height: 220 * u,
      child: RepaintBoundary(child: Press(
        u: u,
        radius: 34,
        lift: 4,
        onTap: () => onTap(title),
        builder: (context, g, s) => Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34 * u),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .55), blurRadius: 12 * u, offset: Offset(0, 8 * u))],
              ),
              child: Image.asset('assets/images/$base.webp', fit: BoxFit.fill),
            ),
          ),
          // icon tile (reference 3D glossy block)
          Positioned(
            left: 36 * u,
            top: 38 * u,
            width: tileW * u,
            height: 80 * u,
            child: Wobble(s: s, child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22 * u),
                boxShadow: [BoxShadow(color: glow.withValues(alpha: .35 * pulse), blurRadius: 18 * u)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22 * u),
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/$tile.webp', fit: BoxFit.fill),
                  if (icon != null)
                    Center(
                      child: Icon(icon, size: 50 * u, color: Colors.white, shadows: [Shadow(color: iconColor, blurRadius: 3 * u),
                        Shadow(color: glow, blurRadius: 12 * u),
                        Shadow(color: glow.withValues(alpha: .7), blurRadius: 22 * u),
                      ]),
                    ),
                ]),
              ),
            )),
          ),
          Positioned(
            left: 40 * u,
            top: 127 * u,
            child: Text(title,
                style: TextStyle(
                  fontSize: (41 * u).clamp(16, 23),
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  color: Colors.white,
                  shadows: [Shadow(color: const Color(0xFF0A1018), offset: Offset(0, 1.5 * u)), Shadow(color: const Color(0xB3000000), offset: Offset(0, 4 * u), blurRadius: 4 * u)],
                )),
          ),
          Positioned(
            left: 41 * u,
            top: 170 * u,
            child: Text(sub,
                style: TextStyle(
                  fontSize: (31 * u).clamp(12, 17),
                  height: 1,
                  color: const Color(0xFFEEF3F9),
                  shadows: [Shadow(color: const Color(0xB3000000), offset: Offset(0, 1.5 * u), blurRadius: 2 * u)],
                )),
          ),
          if (badge != null)
            Positioned(
              left: 357 * u,
              top: 28 * u,
              child: RedBadge(text: badge, size: 40 * u, colors: badgeColors, textColor: badgeText ?? Colors.white),
            ),
        ]),
      )),
    );
  }

  Widget _designSystem() {
    const dashes = [Color(0xFF2FD3E6), Color(0xFFE8A838), Color(0xFF25C9B5), Color(0xFF7A5CF0), Color(0xFFE8643C)];
    return Positioned(
      left: 26 * u,
      top: 1375 * u,
      width: 878 * u,
      height: 172 * u,
      child: Press(
        u: u,
        radius: 34,
        onTap: () => onTap('Design System'),
        builder: (context, g, s) => Stack(clipBehavior: Clip.none, children: [
          // same brushed-steel panel art as the Start a conversation card
          Positioned.fill(child: Image.asset('assets/images/cta-blank-wide.webp', fit: BoxFit.fill)),
          Positioned(
            left: 78 * u,
            top: 47 * u,
            width: 84 * u,
            height: 78 * u,
            child: Wobble(s: s, child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22 * u),
                boxShadow: [BoxShadow(color: const Color(0xFF3FD2F2).withValues(alpha: .35), blurRadius: 18 * u)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22 * u),
                child: Stack(fit: StackFit.expand, children: [
                  Image.asset('assets/images/ico-ds.webp', fit: BoxFit.fill),
                  Center(
                    child: Icon(Icons.palette_outlined, size: 44 * u, color: const Color(0xFFC9F6FF), shadows: [
                      Shadow(color: const Color(0xFF3FD2F2), blurRadius: 10 * u),
                      Shadow(color: const Color(0xB328AAFF), blurRadius: 20 * u),
                    ]),
                  ),
                ]),
              ),
            )),
          ),
          Positioned(
            left: 204 * u,
            top: 40 * u,
            child: Text('Design System',
                style: TextStyle(
                  fontSize: (41 * u).clamp(16, 23),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                  shadows: [Shadow(color: const Color(0xB3000000), offset: Offset(0, 3 * u), blurRadius: 3 * u)],
                )),
          ),
          Positioned(
            left: 204 * u,
            top: 86 * u,
            child: Text('Foundation tokens & components',
                style: TextStyle(fontSize: (31 * u).clamp(12, 17), height: 1, color: const Color(0xFFEEF3F9))),
          ),
          Positioned(
            left: 204 * u,
            top: 126 * u,
            child: Row(children: [
              for (final c in dashes)
                Container(
                  width: 34 * u,
                  height: 6 * u,
                  margin: EdgeInsets.only(right: 10 * u),
                  decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3 * u), boxShadow: [BoxShadow(color: c, blurRadius: 6 * u)]),
                ),
            ]),
          ),
          Positioned(
            right: 84 * u,
            top: 64 * u,
            child: Transform.translate(offset: Offset(12 * u * math.sin(s * math.pi), 0), child: Icon(Icons.chevron_right_rounded, size: 44 * u, color: Color.lerp(const Color(0xFF9FB2C8), Colors.white, g.clamp(0.0, 1.0)))),
          ),
        ]),
      ),
    );
  }

  Widget _aiAndNav() {
    Widget navLabel(double x, String s, {Color color = const Color(0xFFF1F4F7), bool glow = false}) => Positioned(
          left: x * u,
          top: 441 * u,
          width: 120 * u,
          child: Text(s,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (27 * u).clamp(11, 15),
                fontWeight: FontWeight.w700,
                height: 1,
                color: color,
                shadows: [
                  if (glow) Shadow(color: const Color(0xCCFF7814), blurRadius: 8 * u),
                  Shadow(color: const Color(0xCC000000), offset: Offset(0, 1.5 * u), blurRadius: 2 * u),
                ],
              )),
        );

    // Icons are the reference art's own chrome icons, cut out as sprites so they can still float / hop / tilt.
    Widget navItem(double x, double y, double w, double h, double sx, double sy, String sprite, String label, double phase) {
      final bob = -3 * u * math.sin(2 * math.pi * (t / 3.6 + phase));
      final period = 6.5 + phase * 2;
      final k = ((t + phase * 5) % period) / period;
      double rot = 0;
      double hop = 0;
      if (k > .82 && k < .96) {
        final q = (k - .82) / .14;
        rot = math.sin(q * math.pi * 4) * .16 * (1 - q);
        hop = -math.sin(q * math.pi) * 7 * u;
      }
      return Positioned(
        left: x * u,
        top: y * u,
        width: w * u,
        height: h * u,
        child: Press(
          u: u,
          radius: 30,
          scaleUp: 1.06,
          lift: 2,
          shine: false,
          onTap: () => onTap(label),
          builder: (context, g, hs) => Stack(clipBehavior: Clip.none, children: [
            Positioned(
              left: sx * u,
              top: sy * u,
              width: 76 * u,
              height: 63 * u,
              child: Transform.translate(
                offset: Offset(0, bob + hop + hoverDy(label, hs, u)),
                child: Transform.rotate(
                  angle: rot + hoverRot(label, hs),
                  child: Transform.scale(
                    scale: hoverScale(label, hs),
                    child: Center(
                      child: SizedBox(
                        width: 64 * u,
                        height: 64 * u,
                        child: CustomPaint(painter: NavGlyph(sprite, g)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      );
    }

    return section(0, 1562, 896, 515, 1.0502, [
      Positioned.fill(child: Image.asset('assets/images/ai-nav.webp', fit: BoxFit.fill)),
      Positioned(
        left: 370 * u,
        top: 33 * u,
        child: Text('MY AI COMPANION',
            style: TextStyle(
              fontSize: (27 * u).clamp(11, 15),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              color: const Color(0xFFD9DFE6),
              shadows: [Shadow(color: Colors.black, offset: Offset(0, -1 * u)), Shadow(color: const Color(0x66FFFFFF), offset: Offset(0, 1.5 * u))],
            )),
      ),
      Positioned(
        left: 370 * u,
        top: 66 * u,
        child: GradText(
          'Eos - Your Digital Strategist',
          colors: const [Color(0xFFFFF0D2), Color(0xFFFFCF8F), Color(0xFFFF9A3A), Color(0xFFFFD199)],
          stops: const [0, .35, .6, 1],
          style: TextStyle(fontSize: (35 * u).clamp(14, 21), fontWeight: FontWeight.w800, height: 1),
          shadow: const Color(0xFF3B1A04),
          u: u,
        ),
      ),
      Positioned(
        left: 371 * u,
        top: 102 * u,
        child: Text('Optimizing your day, every day.\nLast sync: 3 mins ago',
            style: TextStyle(
              fontSize: (30 * u).clamp(12, 17),
              fontWeight: FontWeight.w500,
              height: 1.3,
              color: const Color(0xFFF6F8FA),
              shadows: [Shadow(color: const Color(0xE6000000), offset: Offset(0, 2 * u), blurRadius: 3 * u)],
            )),
      ),
      // Configure Avatar
      Positioned(
        left: 368 * u,
        top: 210 * u,
        width: 452 * u,
        height: 82 * u,
        child: Press(
          u: u,
          radius: 42,
          scaleUp: 1,
          lift: 0,
          onTap: () => onTap('Configure Avatar'),
          child: Align(
            alignment: const Alignment(-.2, 0),
            child: Text('Configure Avatar',
                style: TextStyle(
                  fontSize: (30 * u).clamp(13, 17),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [Shadow(color: const Color(0xFF06102E), offset: Offset(0, 2 * u)), Shadow(color: const Color(0xE682B4FF), blurRadius: 8 * u)],
                )),
          ),
        ),
      ),
      // bottom navigation
      navItem(38, 360, 104, 118, 9, 14, 'home', 'Home', 0),
      navItem(205, 372, 105, 106, 15, 5, 'chats', 'Chats', .25),
      navItem(575, 368, 112, 110, 15, 9, 'market', 'Market', .5),
      navItem(752, 372, 96, 106, 10, 5, 'profile', 'Profile', .75),
      navLabel(23, 'Home'),
      navLabel(197, 'Chats'),
      navLabel(380, 'Calls', color: const Color(0xFFFFE9D0), glow: true),
      navLabel(568, 'Market'),
      navLabel(740, 'Profile'),
      // Calls orb: the button itself is the reference art (chrome ring + neon ring + orange dome); only a tap target on top
      Positioned(
        left: 374 * u,
        top: 302 * u,
        width: 148 * u,
        height: 148 * u,
        child: Press(
          u: u,
          circle: true,
          scaleUp: 1.08,
          lift: 5,
          onTap: () => onTap('Calls'),
          builder: (context, g, hs) => OverflowBox(
            maxWidth: 152 * u,
            maxHeight: 152 * u,
            child: Transform.rotate(
              angle: .09 * math.sin(hs * math.pi * 3) * (1 - hs),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(<double>[
                  1 + .16 * g, 0, 0, 0, 5 * g,
                  0, 1 + .16 * g, 0, 0, 5 * g,
                  0, 0, 1 + .16 * g, 0, 5 * g,
                  0, 0, 0, 1, 0,
                ]),
                child: Image.asset('assets/images/nav-calls.webp', width: 152 * u, height: 152 * u, fit: BoxFit.fill),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ───────────────────────────────────────────────────────────── building blocks

class _Background extends StatelessWidget {
  const _Background({required this.u});
  final double u;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF070A0E),
            image: DecorationImage(
              image: const AssetImage('assets/images/carbon-tile.png'),
              repeat: ImageRepeat.repeat,
              scale: 68 / (18 * u),
              filterQuality: FilterQuality.medium,
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1),
              radius: 1.2,
              colors: [const Color(0xFFFF7A1A).withValues(alpha: .10), const Color(0x00FF7A1A)],
              stops: const [0, .6],
            ),
          ),
        ),
      ),
    ]);
  }
}

class _HeroClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = <List<double>>[
      [.003, .155], [.17, .155], [.24, .003], [.76, .003], [.83, .155], [.997, .155], [.997, .83], [.945, .997], [.055, .997], [.003, .83],
    ];
    final path = Path()..moveTo(p[0][0] * s.width, p[0][1] * s.height);
    for (final q in p.skip(1)) {
      path.lineTo(q[0] * s.width, q[1] * s.height);
    }
    return path..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.t, required this.u});
  final double t;
  final double u;

  static final List<_Spark> _sparks = () {
    final r = math.Random(7);
    return List.generate(46, (i) {
      final c = (r.nextDouble() + r.nextDouble() + r.nextDouble()) / 3;
      return _Spark(
        x: c,
        y: .3 + r.nextDouble() * .65,
        dur: 2.4 + r.nextDouble() * 3.4,
        delay: r.nextDouble() * 5,
        dx: (r.nextDouble() - .5) * 70,
        big: i % 6 == 0,
      );
    });
  }();

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in _sparks) {
      final k = ((t + s.delay) % s.dur) / s.dur;
      final op = k < .15 ? k / .15 : (1 - k) / .85;
      final x = s.x * size.width + s.dx * u * k;
      final y = s.y * size.height - k * 120 * u;
      final rad = (s.big ? 4 : 2.5) * u;
      canvas.drawCircle(
        Offset(x, y),
        rad,
        Paint()
          ..color = (s.big ? const Color(0xFFFFF0C0) : const Color(0xFFFFB45A)).withValues(alpha: op.clamp(0, 1) * .95),
      );
      canvas.drawCircle(Offset(x, y), rad * 2.4, Paint()..color = const Color(0xFFFF8A1F).withValues(alpha: op.clamp(0, 1) * .22));
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.t != t;
}

class _Spark {
  _Spark({required this.x, required this.y, required this.dur, required this.delay, required this.dx, required this.big});
  final double x, y, dur, delay, dx;
  final bool big;
}

