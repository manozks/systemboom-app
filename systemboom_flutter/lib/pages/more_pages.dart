import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data.dart';
import '../kit.dart';
import '../main.dart' show HomePage;
import 'chat_extra_pages.dart';
import '../shell.dart';
import 'chat_page.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});
  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  bool private = false;
  String q = '';

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final list = people.values.where((p) => p.id != 'me' && p.name.toLowerCase().contains(q.toLowerCase())).toList();
    Widget mode(String l, bool on, VoidCallback f) => Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 7 * u), child: Tap(onTap: () => setState(f), child: Nine(on ? 'info-chip-on' : 'info-chip-off', px: on ? sizeChipOn : sizeChipOff, slice: 40, u: u, minH: 100 * u, pad: EdgeInsets.symmetric(horizontal: 30 * u, vertical: 18 * u), child: Center(child: Text(l, style: ts(u, 38, w: FontWeight.w700)))))));
    return PageShell(
      title: 'New Chat',
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      searchHint: 'Search contacts',
      onSearch: (v) => setState(() => q = v),
      children: [
        OLabel('Privacy mode', u: u),
        Row(children: [mode('Standard', !private, () => private = false), mode('Private (E2EE)', private, () => private = true)]),
        SizedBox(height: 18 * u),
        OLabel('Contacts', u: u),
        for (final p in list)
          SteelPlate(
            u: u,
            onTap: () {
              final wantPrivate = private && !p.business;
              final ex = Store.i.chats.where((c) => c.userId == p.id && c.private == wantPrivate && !c.anon);
              pushScreen(context, ex.isNotEmpty ? ConversationPage(ex.first.id) : DraftChatPage(p.id, privateIntent: wantPrivate));
            },
            child: Row(children: [
              Face(u: u, person: p, size: 104, online: p.online),
              SizedBox(width: 26 * u),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name + (p.verified ? ' ✓' : ''), style: ts(u, 42, w: FontWeight.w800)), Text(p.about ?? '', style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
              Icon(Icons.chevron_right_rounded, size: 52 * u, color: const Color(0xFFE8EDF1)),
            ]),
          ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.section});
  final String? section;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<String, bool> _on = {};
  final _devices = <(String, String)>[('This phone', 'Active now · Kathmandu'), ('Chrome on Windows', 'Active 2h ago · Pokhara'), ('iPad', 'Active 3d ago · Kathmandu')];

  static const _sections = [
    ('profile', 'Profile', 'Name, about, phone', Icons.person_outline_rounded),
    ('privacy', 'Privacy', 'Who can see your info', Icons.shield_outlined),
    ('security', 'Security', 'Encryption & verification', Icons.lock_outline_rounded),
    ('notifications', 'Notifications', 'Sounds, previews, mentions', Icons.notifications_none_rounded),
    ('devices', 'Linked devices', 'Where you are signed in', Icons.laptop_outlined),
    ('help', 'Help & support', 'FAQ and contact', Icons.help_outline_rounded),
  ];

  static const _toggles = {
    'privacy': ['Last seen & online', 'Read receipts', 'Profile photo', 'Group invites'],
    'security': ['Two-step verification', 'Screen lock', 'Security notifications'],
    'notifications': ['Message notifications', 'Show previews', 'Calls', 'Order updates', 'Mentions & reactions'],
  };

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final sec = widget.section;
    if (sec == null) {
      return PageShell(
        title: 'Settings',
        active: 'profile',
        showDock: false,
        headerArt: 'hdr-calls',
        right: bellBtn(context, u),
        children: [
          for (final s in _sections)
            SteelPlate(u: u, onTap: () => pushScreen(context, SettingsPage(section: s.$1)), child: Row(children: [
              GoldIcon(s.$4, u: u),
              SizedBox(width: 26 * u),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$2, style: ts(u, 42, w: FontWeight.w800)), Text(s.$3, style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
              Icon(Icons.chevron_right_rounded, size: 52 * u, color: const Color(0xFFE8EDF1)),
            ])),
          SteelPlate(u: u, child: Row(children: [
            GoldIcon(Icons.wifi_off_rounded, u: u),
            SizedBox(width: 26 * u),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Simulate offline', style: ts(u, 42, w: FontWeight.w800)), Text('Messages fail until you go back online', style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
            MetalSwitch(u: u, on: Store.i.offline, onChanged: (v) => setState(() => Store.i.offline = v)),
          ])),
          SizedBox(height: 14 * u),
          CtaBtn(u: u, label: 'Log out', icon: Icons.logout_rounded, red: true, onTap: () async {
            if (await confirmDialog(context, title: 'Log out?', text: 'You can sign back in anytime.', confirm: 'Log out') && context.mounted) pushScreen(context, const WelcomePage());
          }),
        ],
      );
    }
    final meta = _sections.firstWhere((x) => x.$1 == sec);
    final toggles = _toggles[sec] ?? const <String>[];
    return PageShell(
      title: meta.$2,
      active: 'profile',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      children: [
        for (final t in toggles)
          SteelPlate(u: u, child: Row(children: [
            Expanded(child: Text(t, style: ts(u, 42, w: FontWeight.w800))),
            MetalSwitch(u: u, on: _on[t] ?? (t != 'Group invites' && t != 'Two-step verification' && t != 'Screen lock' && t != 'Mentions & reactions'), onChanged: (v) => setState(() => _on[t] = v)),
          ])),
        if (sec == 'profile') ...[
          Center(child: Face(u: u, person: people['me']!, size: 230)),
          SizedBox(height: 26 * u),
          for (final f in [('Display name', 'Aarav Sharma'), ('About', 'Building calm software.'), ('Phone', '+977 98•• ••• 210')]) ...[
            OLabel(f.$1, u: u),
            GlassWell(u: u, child: Text(f.$2, style: ts(u, 38, w: FontWeight.w400, sh: const []))),
          ],
          SizedBox(height: 24 * u),
          ArtBtn(u: u, label: 'Save changes', orange: true, minH: 150, onTap: () => showToast(context, 'Profile saved')),
        ],
        if (sec == 'devices')
          for (final d in _devices)
            SteelPlate(u: u, child: Row(children: [
              GoldIcon(d.$1 == 'This phone' ? Icons.smartphone_rounded : Icons.laptop_outlined, u: u),
              SizedBox(width: 24 * u),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(d.$1, style: ts(u, 42, w: FontWeight.w800)), Text(d.$2, style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
              if (d.$1 != 'This phone') Tap(onTap: () async {
                if (await confirmDialog(context, title: 'Remove ${d.$1}?', text: 'It will be signed out.', confirm: 'Remove') && mounted) setState(() => _devices.remove(d));
              }, child: Icon(Icons.close_rounded, size: 56 * u, color: const Color(0xFFFF6A5A))),
            ])),
        if (sec == 'help')
          SteelPlate(u: u, child: Text('support@systemboom.app', style: ts(u, 38, w: FontWeight.w400, sh: const []))),
      ],
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    return Scaffold(
      backgroundColor: const Color(0xFF07090C),
      body: Center(
        child: SizedBox(
          width: u * 941,
          child: Stack(children: [
            const Positioned.fill(child: CarbonBg()),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 48 * u),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(36 * u), child: Image.asset('assets/images/logo-lockup.webp')),
                  SizedBox(height: 50 * u),
                  Text.rich(TextSpan(children: [const TextSpan(text: 'Chat. Call. '), TextSpan(text: 'Trade.', style: TextStyle(color: Color(0xFFFF9A3A)))]), style: ts(u, 76, w: FontWeight.w900)),
                  SizedBox(height: 20 * u),
                  Text('One calm place for conversations, calls and a marketplace — with optional end-to-end privacy.', textAlign: TextAlign.center, style: ts(u, 40, c: const Color(0xFFC3CEDB), w: FontWeight.w400, sh: const [])),
                  SizedBox(height: 50 * u),
                  ArtBtn(u: u, label: 'Continue with phone', icon: Icons.phone_rounded, orange: true, minH: 176, fontPx: 52, onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
                  SizedBox(height: 18 * u),
                  ArtBtn(u: u, label: 'Go anonymous', icon: Icons.masks_rounded, minH: 176, fontPx: 52, onTap: () => showToast(context, 'Anonymous environment')),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}


/// Launch screen: breathing logo plate + spinner, then fades into Home (tap to skip).
/// Loading screen: the bomb icon's fuse burns from the spark to the bomb, then it blows and the app opens.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  static const _start = .4, _burn = 2.2, _blast = 1.3; // seconds
  static const _total = _start + _burn + _blast;
  late final AnimationController _c = AnimationController(vsync: this, duration: Duration(milliseconds: (_total * 1000).round()))..forward().whenComplete(_next);
  bool _gone = false;
  bool _pre = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pre) return;
    _pre = true;
    for (final n in const ['bomb-icon.webp', 'carbon-tile.webp']) {
      precacheImage(AssetImage('assets/images/$n'), context);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _next() {
    if (_gone || !mounted) return;
    _gone = true;
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(
      pageBuilder: (_, _, _) => const HomePage(),
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: CurvedAnimation(parent: a, curve: Curves.easeOut), child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    return Scaffold(
      backgroundColor: const Color(0xFF07090C),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _next,
        child: Center(
          child: SizedBox(
            width: u * 941,
            child: Stack(clipBehavior: Clip.hardEdge, children: [
              const Positioned.fill(child: CarbonBg()),
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final sec = _c.value * _total;
                    final burn = ((sec - _start) / _burn).clamp(0.0, 1.0);
                    final blast = ((sec - _start - _burn) / _blast).clamp(0.0, 1.0);
                    final pop = Curves.easeOutBack.transform((sec / .6).clamp(0.0, 1.0));
                    return LayoutBuilder(builder: (context, box) {
                      final s = box.maxWidth * .9;
                      final rect = Rect.fromCenter(center: Offset(box.maxWidth / 2, box.maxHeight / 2), width: s, height: s);
                      final shake = blast > 0 ? Offset(math.sin(sec * 120) * 6, math.cos(sec * 97) * 4) * (s / 1254) : Offset.zero;
                      return Stack(children: [
                        Positioned.fromRect(
                          rect: rect.shift(shake),
                          child: Opacity(opacity: (pop * (1 - (blast * 6).clamp(0.0, 1.0))).clamp(0.0, 1.0), child: Transform.scale(scale: .82 + .18 * pop, child: Image.asset('assets/images/bomb-icon.webp', fit: BoxFit.fill, filterQuality: FilterQuality.medium))),
                        ),
                        Positioned.fill(child: IgnorePointer(child: CustomPaint(painter: _FusePainter(rect: rect.shift(shake), burn: burn, blast: blast, sec: sec)))),
                      ]);
                    });
                  },
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _FusePainter extends CustomPainter {
  _FusePainter({required this.rect, required this.burn, required this.blast, required this.sec});
  final Rect rect;
  final double burn, blast, sec;

  // Fuse centre-line in the icon's 1254x1254 space: spark end -> fuse hole.
  static const _pts = [Offset(874, 306), Offset(838, 280), Offset(805, 248), Offset(778, 214), Offset(738, 190), Offset(682, 176), Offset(627, 194), Offset(579, 218), Offset(543, 252), Offset(521, 285), Offset(513, 322), Offset(525, 348)];
  static final Path _path = () {
    final p = Path()..moveTo(_pts.first.dx, _pts.first.dy);
    for (var i = 0; i < _pts.length - 1; i++) {
      final p0 = _pts[math.max(i - 1, 0)], p1 = _pts[i], p2 = _pts[i + 1], p3 = _pts[math.min(i + 2, _pts.length - 1)];
      final c1 = p1 + (p2 - p0) / 6, c2 = p2 - (p3 - p1) / 6;
      p.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
    }
    return p;
  }();
  static final ui.PathMetric _metric = _path.computeMetrics().first;

  @override
  void paint(Canvas canvas, Size size) {
    final sc = rect.width / 1254;
    // the burnt fuse must dissolve together with the icon when the bomb blows (no floating rope left behind)
    final fade = (1 - blast * 6).clamp(0.0, 1.0);
    if (burn > 0 && fade > 0) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(255, 255, 255, fade));
      canvas.save();
      canvas.translate(rect.left, rect.top);
      canvas.scale(sc);
      final len = _metric.length;
      final done = _metric.extractPath(0, len * burn);
      Paint stroke(double w, Color c, {double blur = 0}) => Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = w
        ..color = c
        ..maskFilter = blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null;
      canvas.drawPath(done, stroke(200, const Color(0x8C0A0808), blur: 22));
      canvas.drawPath(done, stroke(74, const Color(0xFF150F0B)));
      canvas.drawPath(done, stroke(30, const Color(0xCC3A2A1E)));
      // ash where the spark used to sit
      final ash = (burn * 12).clamp(0.0, 1.0);
      canvas.drawCircle(_pts.first, 62, Paint()..shader = ui.Gradient.radial(_pts.first, 62, [Color.fromRGBO(18, 13, 10, ash), Color.fromRGBO(28, 20, 16, .9 * ash), const Color(0x001C1410)], [0, .6, 1]));
      if (burn < 1) {
        final head = _metric.getTangentForOffset(len * burn)!.position;
        final flick = 1 + .08 * math.sin(sec * 38);
        canvas.drawCircle(head, 120 * flick, Paint()..shader = ui.Gradient.radial(head, 120 * flick, const [Color(0xFFFFFFFF), Color(0xFFFFF2C0), Color(0xD9FF9A2A), Color(0x00FF5A00)], [0, .22, .5, 1]));
        canvas.drawCircle(head, 30 * flick, Paint()..color = Colors.white..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
        for (var i = 0; i < 9; i++) {
          final ph = (sec * 1.9 + i * .113) % 1;
          final a = i * 2.4 + 1;
          final d = 30 + 90 * ph;
          final o = head + Offset(math.cos(a) * d, math.sin(a) * d - 50 * ph);
          canvas.drawCircle(o, 9 * (1 - ph) + 1, Paint()..color = Color.fromRGBO(255, 179, 71, 1 - ph));
        }
      }
      canvas.restore();
      canvas.restore();
    }
    if (blast > 0) {
      final c = rect.topLeft + const Offset(525, 348) * sc;
      final k = rect.width / 400; // ~1 on a phone
      final t = blast * _SplashPageState._blast; // seconds since the blast
      // 1) bright flash that swells and fades
      final fl = (t / .32).clamp(0.0, 1.0);
      final fr = 30 * k + (rect.width * 1.5) * Curves.easeOut.transform(fl);
      final fa = t < .18 ? 1.0 : (1 - ((t - .18) / .5)).clamp(0.0, 1.0);
      if (fa > 0) {
        canvas.drawCircle(c, fr, Paint()..shader = ui.Gradient.radial(c, fr, [Color.fromRGBO(255, 255, 255, fa), Color.fromRGBO(255, 233, 168, fa), Color.fromRGBO(255, 154, 42, fa), Color.fromRGBO(255, 90, 0, .55 * fa), const Color(0x00FF5A00)], const [0, .22, .48, .68, 1]));
      }
      // 2) lava sparks flying outward with gravity, cooling from white-yellow to dark red
      double h(int i, int n) {
        final x = math.sin(i * 127.1 + n * 311.7) * 43758.5453;
        return x - x.floorToDouble();
      }
      for (var i = 0; i < 110; i++) {
        final life = .7 + h(i, 4) * .6;
        final age = t - h(i, 5) * .08;
        if (age <= 0 || age >= life) continue;
        final u = age / life; // 0..1
        final ang = h(i, 1) * math.pi * 2;
        final dist = (120 + math.pow(h(i, 2), .7) * 520) * k;
        final out = 1 - math.pow(1 - u, 2.6); // fast out, slows down
        final fall = (40 + h(i, 6) * 160) * k * u * u;
        final pos = c + Offset(math.cos(ang) * dist * out, math.sin(ang) * dist * out + fall);
        final col = u < .25
            ? Color.lerp(const Color(0xFFFFF6C8), const Color(0xFFFFB43A), u / .25)!
            : u < .7
                ? Color.lerp(const Color(0xFFFFB43A), const Color(0xFFFF6A12), (u - .25) / .45)!
                : Color.lerp(const Color(0xFFFF6A12), const Color(0xFFB3200A), (u - .7) / .3)!;
        final alpha = (1 - u * u).clamp(0.0, 1.0);
        final r = (3 + h(i, 3) * 9) * k * (1 - .65 * u);
        canvas.drawCircle(pos, r * 2.2, Paint()..color = col.withValues(alpha: .35 * alpha)..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
        canvas.drawCircle(pos, r, Paint()..color = col.withValues(alpha: alpha));
      }
    }
  }

  @override
  bool shouldRepaint(_FusePainter o) => o.burn != burn || o.blast != blast || o.sec != sec || o.rect != rect;
}
