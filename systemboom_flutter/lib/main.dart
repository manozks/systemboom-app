import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/services.dart';

import 'pages/more_pages.dart' show SplashPage;
import 'kit.dart' show HoverLoop, RingSweep, pushScreen;
import 'pages/chat_page.dart' show NotificationsLazy;
import 'orb_menu.dart';
import 'shell.dart';
import 'ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light, // Android
    statusBarBrightness: Brightness.dark, // iOS (light text on dark UI)
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  ));
  runApp(const SystemBoomApp());
}

/// Art decoded up front (started while the splash plays) so the first screens don't pop images in one by one.
const kPrecacheImages = [
      'hdr-home.webp', 'logo-lockup.webp', 'greeting.webp', 'cta.webp', 'card-base-blue.webp', 'card-base-dark.webp',
      'ico-chat-ref.webp', 'ico-call-ref.webp', 'ico-mk.webp', 'ico-an.webp', 'ico-ds.webp', 'cta-blank-wide.webp', 'ai-nav.webp',
      'nav-calls.webp', 'hero-header.webp', 'dock.webp', 'hdr-calls.webp', 'brand-colors.webp', 'typography.webp', 'cta-new.webp', 'greeting-new.webp', 'buttons-panel.webp', 'icons-panel.webp', 'icon-key.webp', 'search-bar.webp', 'tabs-base.webp', 'tabs-key.webp', 'carbon-tile.webp', 'profile.webp', 'cf1.webp', 'cf2.webp', 'cf4.webp', 'cf5.webp', 'me.webp', 'chat-bubble.webp', 'chat-bubble-out.webp', 'chat-bar.webp', 'plate-row.webp', 'btn-steel.webp', 'btn-orange.webp', 'info-row.webp', 'info-chip-on.webp', 'info-chip-off.webp', 'notif-card.webp', 'ring63-act.webp', 'ring63-emoji.webp', 'share-ring.webp', 'ring63-red.webp', 'plate-title.webp', 'plate-tab.webp', 'pframe-photo.webp', 'plate-green.webp', 'pill-status.webp', 'photo-deskmat.webp', 'doc-thumb.webp', 'call-bg.webp', 'info-ring.webp', 'info-cta-orange.webp', 'info-cta-red.webp', 'info-label.webp', 'notif-btn.webp', 'dialog-bg.webp', 'celestial/venus.webp', 'celestial/sun.webp', 'celestial/meteors.webp', 'celestial/comet.webp', 'celestial/jupiter.webp', 'celestial/saturn.webp', 'celestial/moon.webp', 'celestial/mercury.webp', 'asheet-frame.webp', 'asheet-row.webp', 'asheet-row-red.webp', 'panel-frame.webp',
];

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
      home: const SplashPage(),
    );
  }
}

/// Reference artboard is 941 units wide; every size below is expressed in
/// those units and scaled by [u] (= stage width / 941), exactly like the web version.
const double kStageW = 941;
const double kStageH = 2097;

/// How far (design units) the stage is pulled up now that the header is shorter: 411 (greeting y) - (header 230 + 8 gap).
const double _kStageShift = 173;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // animation clock, ticked at ~30 fps (half the frames) so the big home stage isn't rebuilt 60 times a second
  final ScrollController _sc = ScrollController();
  final ValueNotifier<double> _off = ValueNotifier<double>(0);
  late final Ticker _ticker;
  final ValueNotifier<double> _clock = ValueNotifier<double>(0);
  int _frame = 0;
  final ValueNotifier<String?> _toast = ValueNotifier<String?>(null);
  int _toastId = 0;

  @override
  void initState() {
    super.initState();
    _sc.addListener(() => _off.value = _sc.hasClients ? _sc.offset : 0);
    _ticker = createTicker((d) {
      if ((_frame++ & 1) == 0) _clock.value = (d.inMicroseconds / 1e6) % 60;
    })..start();
  }

  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precached) return;
    _precached = true;
    // decode the art up front so the first frame doesn't pop images in one by one
    for (final n in kPrecacheImages) {
      precacheImage(AssetImage('assets/images/$n'), context);
    }
  }

  @override
  void dispose() {
    _sc.dispose();
    _off.dispose();
    _ticker.dispose();
    _clock.dispose();
    _toast.dispose();
    super.dispose();
  }

  /// seconds elapsed (looping), used by every animation
  double get _t => _clock.value;

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
      'Anonymous': 'anonymous',
    };
    if (kEnableNav && label == 'Notifications') {
      pushScreen(context, const NotificationsLazy());
      return;
    }
    final r = routes[label];
    if (kEnableNav && r != null) {
      if (r == 'design' || r == 'anonymous') {
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
                controller: _sc,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: w,
                  height: (kStageH - _kStageShift) * u + MediaQuery.paddingOf(context).top,
                  child: Stack(clipBehavior: Clip.hardEdge, children: [
                    // the stage's own coordinates start 142 units lower (old, taller header); shift it up under the new, shorter one
                    Positioned(
                      left: 0,
                      right: 0,
                      top: MediaQuery.paddingOf(context).top - _kStageShift * u,
                      height: kStageH * u,
                      child: AnimatedBuilder(animation: _clock, builder: (context, _) => _Stage(u: u, t: _t, onTap: _tap, hero: false)),
                    ),
                  ]),
                ),
              ),
              // pinned header: full-bleed, stays put and shrinks as the rest of the home screen scrolls underneath it
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: ValueListenableBuilder<double>(
                  valueListenable: _off,
                  builder: (context, off, _) {
                    final cc = (off / (_Stage.shrinkDist * u)).clamp(0.0, 1.0); // linear: the header edge tracks the content scrolling up under it
                    return AnimatedBuilder(
                      animation: _clock,
                      builder: (context, _) => Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(height: MediaQuery.paddingOf(context).top, color: const Color(0xFF070A0E)),
                        _Stage(u: u, t: _t, onTap: _tap).header(cc),
                      ]),
                    );
                  },
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 120 * u + MediaQuery.paddingOf(context).bottom,
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
  const _Stage({required this.u, required this.t, required this.onTap, this.hero = true});
  final bool hero; // false: the header is drawn separately and stays pinned
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
    return ClipRect(
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(child: _Background(u: u)),
        if (hero) _hero(),
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
        // vignette (no mock-device rim: the page fills the real screen)
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
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

  /// Pinned header geometry (design units): the same metal card as the Calls page (854x209 art, full width), which
  /// collapses into a slim bar as the page scrolls.
  static const double kCmpH = 60; // height of the collapsed (slim bar) header, design units
  static const double shrinkDist = 170.3; // scroll distance (units) over which the header collapses (= its height change)

  /// Home header card: SYSTEMBOOM logo in the middle, planets orbiting it, notification bell on the right. [c] goes 0 -> 1 while scrolling.
  Widget header(double c) {
    final w = 941 * u;
    final kx = w / 854; // logical px per art unit
    final ka = kx;
    final h = 209 * kx + (kCmpH * u - 209 * kx) * c; // card height -> slim bar height
    final cx = w / 2;
    final fade = (1 - 2.4 * c).clamp(0.0, 1.0); // bell + planets go away quickly
    // a small solar system round the logo: each planet runs on its own slanted ellipse and speed; depth = sin(angle)
    List<Widget> orbit({required bool back}) {
      const planets = [
        ('mercury', 232.0, 38.0, 30.0, 125.0, 11.0, 15.0, 9.0, 0.0),
        ('venus', 232.0, 38.0, 34.0, 125.0, 11.0, 17.0, 9.0, 0.5),
        ('moon', 284.0, 48.0, 36.0, 160.0, 14.0, 17.0, 15.0, 0.2),
        ('jupiter', 336.0, 58.0, 46.0, 200.0, 16.0, 19.0, 24.0, 0.0),
        ('saturn', 336.0, 58.0, 50.0, 200.0, 16.0, 20.0, 24.0, 0.5),
      ];
      // the orbit flattens and shrinks with the header so the planets circle the small logo inside the slim bar
      final cy = 104 * ka + (kCmpH * u / 2 - 104 * ka) * c;
      final out = <Widget>[];
      for (final (name, rx0, ry0, d0, rx1, ry1, d1, period, ph) in planets) {
        final rx = (rx0 + (rx1 - rx0) * c) * ka, ry = (ry0 + (ry1 - ry0) * c) * ka, d = (d0 + (d1 - d0) * c) * ka;
        final ang = 2 * math.pi * (t / period + ph);
        final depth = math.sin(ang); // > 0: near side (in front of the logo)
        if ((depth <= 0) != back) continue;
        final sc = .8 + .3 * (depth + 1) / 2;
        out.add(Positioned(
          left: cx + rx * math.cos(ang) - d / 2,
          top: cy + ry * depth - d / 2,
          width: d,
          height: d,
          child: IgnorePointer(
            child: Transform.scale(
              scale: sc,
              child: DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0x66FFBE64), blurRadius: d * .35)]),
                child: Opacity(opacity: back ? .85 : 1, child: Image.asset('assets/images/celestial/$name.webp', fit: BoxFit.contain, filterQuality: FilterQuality.medium)),
              ),
            ),
          ),
        ));
      }
      return out;
    }

    final logoW = 440 * ka * (1 - .64 * c);
    final logoCy = 104 * ka + (kCmpH * u / 2 - 104 * ka) * c;
    return SizedBox(
      height: h,
      child: Stack(clipBehavior: Clip.hardEdge, children: [
        // gradient fade under the card (expanded state)
        Positioned.fill(child: Opacity(opacity: 1 - c, child: const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF070A0E), Color(0xFF070A0E), Color(0x00070A0E)], stops: [0, .78, 1]))))),
        // slim bar (collapsed state): dark glass with an orange hairline
        Positioned.fill(
          child: Opacity(
            opacity: (c * 1.6).clamp(0.0, 1.0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xF71A1F26), Color(0xF7090C10)]),
                boxShadow: [BoxShadow(color: const Color(0x8C000000), blurRadius: 14 * u, offset: Offset(0, 5 * u))],
              ),
            ),
          ),
        ),
        if (c < 1) Positioned(left: 0, top: 0, width: w, height: h, child: Opacity(opacity: (1 - 1.7 * c).clamp(0.0, 1.0), child: Image.asset('assets/images/hdr-home.webp', fit: BoxFit.fill, filterQuality: FilterQuality.medium))),
        ...orbit(back: true),
        // logo lock-up (transparent bomb + SYSTEMBOOM); shrinks to the top centre
        Positioned(
          left: cx - logoW / 2,
          top: logoCy - logoW * 193 / 863 / 2,
          width: logoW,
          child: IgnorePointer(child: Image.asset('assets/images/logo-lockup.webp', fit: BoxFit.fitWidth, filterQuality: FilterQuality.medium)),
        ),
        ...orbit(back: false),
        // glossy chrome rim along the bottom of the slim bar, with a sweeping light
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 7 * u,
          child: IgnorePointer(
            child: Opacity(
              opacity: (c * 2).clamp(0.0, 1.0),
              child: ClipRect(
                child: Stack(children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFFFFF), Color(0xFFDFE5EC), Color(0xFF8B95A1), Color(0xFF1B2128), Color(0xFF5D6772), Color(0xFFC3CBD4), Color(0xFFF6F9FC)], stops: [0, .16, .4, .52, .66, .84, 1]),
                        boxShadow: [BoxShadow(color: const Color(0x80FF8C1E), blurRadius: 9 * u, offset: Offset(0, 3 * u))],
                      ),
                    ),
                  ),
                  Positioned(left: 0, right: 0, top: 0, height: 7 * u * .38, child: const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xBFFFFFFF), Color(0x00FFFFFF)])))),
                  Positioned(
                    left: (((t / 5.5) % 1) * 1.4 - .3) * w,
                    top: 0,
                    bottom: 0,
                    width: w * .22,
                    child: const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0x00FFC878), Color(0xF2FFE6B4), Color(0x00FFC878)]))),
                  ),
                ]),
              ),
            ),
          ),
        ),
        // live bell: same gold chrome button as the Calls page; hidden once the header collapses
        if (c < .4)
          Positioned(
            left: cx + 343 * kx - 46 * ka,
            top: 52 * ka,
            width: 92 * ka,
            height: 92 * ka,
            child: Opacity(opacity: fade, child: ChromeBtn(u: ka, gold: true, badge: '14', onTap: () => onTap('Notifications'), child: Icon(Icons.notifications_none_rounded, size: 46 * ka, color: const Color(0xFFFFD27A)))),
          ),
      ]),
    );
  }

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
      // light orbiting the profile-photo ring
      Positioned(left: (143.7 - 92) * u, top: (102 - 92) * u, width: 184 * u, height: 184 * u, child: const RingSweep(inner: .77)),
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
      // the orange button: still at rest; hovering (or pressing) makes ripples expand, a light run round its neon ring and the arrow push forward
      Positioned(
        left: (748.5 - 70) * u,
        top: (110 - 70) * u,
        width: 140 * u,
        height: 140 * u,
        child: HoverLoop(
          builder: (context, h, v) => Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            if (h > .02) Positioned(left: -60 * u, top: -60 * u, width: 260 * u, height: 260 * u, child: IgnorePointer(child: CustomPaint(painter: _PingPainter(v * 2.6, u, h)))),
            if (h > .02) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _OrbitPainter(v, 70 * u, u, const Color(0xFFFFB347), h)))),
            IgnorePointer(
              child: SizedBox(
                width: 80 * u,
                height: 80 * u,
                child: ClipRect(
                  child: Builder(builder: (_) {
                    final push = math.pow(math.sin(math.pi * v), 2).toDouble() * h;
                    Widget arrow(double dx, double a) => Transform.translate(
                          offset: Offset(dx * u, 0),
                          child: Icon(Icons.arrow_forward_rounded, size: 52 * u, color: Colors.white.withValues(alpha: a), shadows: [Shadow(color: const Color(0xFFFFB347).withValues(alpha: a), blurRadius: 12 * u), Shadow(color: Colors.black.withValues(alpha: .35 * a), blurRadius: 3 * u, offset: Offset(0, 2 * u))]),
                        );
                    return Center(child: Stack(alignment: Alignment.center, children: [if (h > .02) arrow(-13 + 20 * push - 0, .28 * h), arrow(-2 + 6 * push + 14 * push, 1)]));
                  }),
                ),
              ),
            ),
            Positioned.fill(child: Press(u: u, circle: true, scaleUp: 1.07, onTap: () => onTap('Starting a conversation'), child: const SizedBox.expand())),
          ]),
        ),
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
          // icon tile (reference 3D glossy block): floats, shines, and a light runs around its edge
          Positioned(
            left: 36 * u,
            top: 38 * u,
            width: tileW * u,
            height: 80 * u,
            child: Transform.translate(
              offset: Offset(0, -3 * u * math.sin(t * 2 * math.pi / 1.6 + x * .01) * g.clamp(0.0, 1.0)),
              child: Wobble(s: s, child: Stack(clipBehavior: Clip.none, children: [
                if (g > .02) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _RRectRipplePainter(t, u, 22 * u, glow, g)))),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22 * u),
                    boxShadow: [BoxShadow(color: glow.withValues(alpha: .3 + .15 * g.clamp(0.0, 1.0)), blurRadius: 18 * u)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22 * u),
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset('assets/images/$tile.webp', fit: BoxFit.fill),
                      if (icon != null)
                        Center(
                          child: Transform.rotate(
                            angle: .14 * math.sin(t * 2 * math.pi / 1.2 + x) * g.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: 1 + .1 * math.sin(t * 2 * math.pi / 0.9 + y) * g.clamp(0.0, 1.0),
                              child: Icon(icon, size: 50 * u, color: Colors.white, shadows: [Shadow(color: iconColor, blurRadius: 3 * u),
                                Shadow(color: glow, blurRadius: 12 * u),
                                Shadow(color: glow.withValues(alpha: .7), blurRadius: 22 * u),
                              ]),
                            ),
                          ),
                        ),
                      if (g > .02) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _ShinePainter(((t * .8 + x * .004) % 1) * .32)))),
                    ]),
                  ),
                ),
                if (g > .02) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _OrbitPainter((t * .6 + x * .003) % 1, 22 * u, u, glow, g)))),
              ])),
            ),
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
            child: Transform.translate(
              offset: Offset(0, -3 * u * math.sin(t * 2 * math.pi / 1.6 + 1.3) * g.clamp(0.0, 1.0)),
              child: Wobble(s: s, child: Stack(clipBehavior: Clip.none, children: [
                if (g > .02) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _RRectRipplePainter(t, u, 22 * u, const Color(0xFF3FD2F2), g)))),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22 * u),
                    boxShadow: [BoxShadow(color: const Color(0xFF3FD2F2).withValues(alpha: .28 + .17 * g.clamp(0.0, 1.0)), blurRadius: 18 * u)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22 * u),
                    child: Stack(fit: StackFit.expand, children: [
                      Image.asset('assets/images/ico-ds.webp', fit: BoxFit.fill),
                      Center(
                        child: Transform.rotate(
                          angle: .14 * math.sin(t * 2 * math.pi / 1.2 + 2) * g.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 1 + .1 * math.sin(t * 2 * math.pi / 0.9 + 1) * g.clamp(0.0, 1.0),
                            child: Icon(Icons.palette_outlined, size: 44 * u, color: const Color(0xFFC9F6FF), shadows: [
                              Shadow(color: const Color(0xFF3FD2F2), blurRadius: 10 * u),
                              Shadow(color: const Color(0xB328AAFF), blurRadius: 20 * u),
                            ]),
                          ),
                        ),
                      ),
                      if (g > .02) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _ShinePainter(((t * .8 + .2) % 1) * .32)))),
                    ]),
                  ),
                ),
                if (g > .02) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _OrbitPainter((t * .6 + .3) % 1, 22 * u, u, const Color(0xFF3FD2F2), g)))),
              ])),
            ),
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
          builder: (context, g, s) => Stack(clipBehavior: Clip.none, children: [
            // breathing blue glow, a sweep of light, and a light running around the pill's edge
            Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(42 * u), boxShadow: [BoxShadow(color: const Color(0xFF5AA0FF).withValues(alpha: .06 + .3 * g.clamp(0.0, 1.0)), blurRadius: 20 * u, spreadRadius: 1 * u)])))),
            if (g > .02) Positioned.fill(child: IgnorePointer(child: ClipRRect(borderRadius: BorderRadius.circular(42 * u), child: CustomPaint(painter: _ShinePainter(((t * .7) % 1) * .32))))),
            if (g > .02) Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _OrbitPainter((t * .45) % 1, 42 * u, u, const Color(0xFF6FB6FF), g)))),
            Align(
              alignment: const Alignment(-.2, 0),
              child: Text('Configure Avatar',
                  style: TextStyle(
                    fontSize: (30 * u).clamp(13, 17),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(color: const Color(0xFF06102E), offset: Offset(0, 2 * u)), Shadow(color: const Color(0xE682B4FF), blurRadius: 8 * u)],
                  )),
            ),
          ]),
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
        child: DockOrbMenu(builder: (context, tap) => Press(
          u: u,
          circle: true,
          scaleUp: 1.08,
          lift: 5,
          onTap: tap,
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
        )),
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
              image: const AssetImage('assets/images/carbon-tile.webp'),
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

/// Diagonal band of light that sweeps across an icon tile (progress 0..1; idle for the first part of the cycle).
class _ShinePainter extends CustomPainter {
  _ShinePainter(this.p);
  final double p;
  @override
  void paint(Canvas canvas, Size size) {
    if (p > .32) return;
    final k = p / .32;
    final x = -size.width * .4 + (size.width * 1.8) * Curves.easeInOut.transform(k);
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRect(r);
    canvas.translate(x, 0);
    canvas.skew(-.35, 0);
    final band = Rect.fromLTWH(0, -4, size.width * .34, size.height + 8);
    canvas.drawRect(band, Paint()..shader = const LinearGradient(colors: [Color(0x00FFFFFF), Color(0x66FFFFFF), Color(0x00FFFFFF)]).createShader(band));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ShinePainter o) => o.p != p;
}

/// A comet of light running around the rounded edge of an icon tile.
class _OrbitPainter extends CustomPainter {
  _OrbitPainter(this.p, this.radius, this.u, this.color, [this.alpha = 1]);
  final double p, radius, u, alpha;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius((Offset.zero & size).deflate(1.5 * u), Radius.circular(radius));
    final path = Path()..addRRect(rr);
    final m = path.computeMetrics().first;
    final len = m.length;
    final head = p * len;
    final tail = len * .3;
    final hot = Color.lerp(color, Colors.white, .75)!;
    Path seg(double a, double b) {
      if (a >= 0) return m.extractPath(a, b);
      return Path()..addPath(m.extractPath(len + a, len), Offset.zero)..addPath(m.extractPath(0, b), Offset.zero);
    }
    const n = 14;
    for (var i = 0; i < n; i++) {
      final a = head - tail * (i + 1) / n, b = head - tail * i / n;
      final al = math.pow(1 - i / n, 1.6).toDouble();
      canvas.drawPath(seg(a, b), Paint()..style = PaintingStyle.stroke..strokeWidth = 3.4 * u..strokeCap = StrokeCap.round..color = hot.withValues(alpha: .9 * al * alpha.clamp(0.0, 1.0)));
    }
    final pos = m.getTangentForOffset(head)!.position;
    canvas.drawCircle(pos, 6 * u, Paint()..color = color.withValues(alpha: .8 * alpha.clamp(0.0, 1.0))..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * u));
    canvas.drawCircle(pos, 2.6 * u, Paint()..color = Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0)));
  }

  @override
  bool shouldRepaint(_OrbitPainter o) => o.p != p || o.alpha != alpha;
}

/// Soft rings that expand from the "start a conversation" button and fade out.
class _PingPainter extends CustomPainter {
  _PingPainter(this.t, this.u, [this.alpha = 1]);
  final double t, u, alpha;
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < 2; i++) {
      final f = ((t / 2.6) + i * .5) % 1;
      final r = 72 * u + 56 * u * Curves.easeOut.transform(f);
      canvas.drawCircle(c, r, Paint()..style = PaintingStyle.stroke..strokeWidth = 3 * u * (1 - f) + .5..color = Color.fromRGBO(255, 160, 60, .55 * (1 - f) * alpha.clamp(0.0, 1.0)));
    }
  }

  @override
  bool shouldRepaint(_PingPainter o) => o.t != t || o.alpha != alpha;
}

/// Two rounded outlines that expand from an icon tile and fade (shown while hovered).
class _RRectRipplePainter extends CustomPainter {
  _RRectRipplePainter(this.t, this.u, this.radius, this.color, this.h);
  final double t, u, radius, h;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final hot = Color.lerp(color, Colors.white, .45)!;
    for (var i = 0; i < 2; i++) {
      final f = ((t / 1.5) + i * .5) % 1;
      final e = Curves.easeOut.transform(f);
      final grow = 18 * u * e;
      final rr = RRect.fromRectAndRadius((Offset.zero & size).inflate(grow), Radius.circular(radius + grow));
      canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 3.2 * u * (1 - f) + .6..color = hot.withValues(alpha: .8 * (1 - f) * h.clamp(0.0, 1.0)));
    }
  }

  @override
  bool shouldRepaint(_RRectRipplePainter o) => o.t != t || o.h != h;
}
