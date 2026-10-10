import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'chat_page.dart';

const _teal = Color(0xFF14A09A);

/// Hue-rotates the orange art to teal.
class TealTint extends StatelessWidget {
  const TealTint({super.key, required this.child});
  final Widget child;

  static List<double> _hue(double deg) {
    final r = deg * math.pi / 180, c = math.cos(r), s = math.sin(r);
    return [
      .213 + c * .787 - s * .213, .715 - c * .715 - s * .715, .072 - c * .072 + s * .928, 0, 0,
      .213 - c * .213 + s * .143, .715 + c * .285 + s * .140, .072 - c * .072 - s * .283, 0, 0,
      .213 - c * .213 - s * .787, .715 - c * .715 + s * .715, .072 + c * .928 + s * .072, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) => ColorFiltered(colorFilter: ColorFilter.matrix(_hue(150)), child: child);
}

Widget _tealBtn(double u, String label, IconData ic, VoidCallback f, {bool enabled = true}) => TealTint(child: ArtBtn(u: u, label: label, icon: ic, orange: true, minH: 176, fontPx: 52, onTap: f, enabled: enabled));

Widget _banner(double u, String text) => Nine('plate-green', px: sizeGreen, slice: 44, u: u, minH: 130 * u, pad: EdgeInsets.fromLTRB(50 * u, 30 * u, 50 * u, 30 * u), child: Row(children: [
      Container(width: 70 * u, height: 70 * u, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2EE8A0), width: 5 * u), boxShadow: [BoxShadow(color: const Color(0xFF2EE8A0).withValues(alpha: .7), blurRadius: 12 * u)]), child: Icon(Icons.lock_outline_rounded, size: 40 * u, color: const Color(0xFF4FF0B0))),
      SizedBox(width: 26 * u),
      Expanded(child: Text(text, style: ts(u, 36, w: FontWeight.w400, h: 1.3, sh: const []))),
    ]));

class AnonymousPage extends StatefulWidget {
  const AnonymousPage({super.key});
  @override
  State<AnonymousPage> createState() => _AnonymousPageState();
}

class _AnonymousPageState extends State<AnonymousPage> {
  Store get s => Store.i;

  @override
  void initState() {
    super.initState();
    s.addListener(_c);
  }

  @override
  void dispose() {
    s.removeListener(_c);
    super.dispose();
  }

  void _c() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final me = s.me;
    final chats = s.chats.where((c) => c.anon).toList();
    Widget tile(String l, IconData ic, VoidCallback f) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 7 * u),
            child: Tap(
              onTap: f,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 22 * u),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30 * u),
                  gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF27303C), Color(0xFF0B1116)]),
                  border: Border.all(color: const Color(0xFFAAB3BB), width: 4 * u),
                  boxShadow: [BoxShadow(color: const Color(0xFF28E6D7).withValues(alpha: .4), blurRadius: 16 * u)],
                ),
                child: Column(children: [Icon(ic, size: 60 * u, color: const Color(0xFFB6FFF4), shadows: [Shadow(color: const Color(0xFF28E6D7), blurRadius: 8 * u)]), SizedBox(height: 8 * u), Text(l, style: ts(u, 24, w: FontWeight.w700, c: const Color(0xFFB6FFF4)))]),
              ),
            ),
          ),
        );

    return PageShell(
      title: 'Anonymous',
      active: 'home',
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 330,
      children: [
        SteelPlate(u: u, pad: EdgeInsets.fromLTRB(48 * u, 30 * u, 48 * u, 30 * u), child: Row(children: [
          Face(u: u, person: Person('me', me.name), size: 130, tint: _teal),
          SizedBox(width: 26 * u),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Active identity', style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const [])), Text(me.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 42, w: FontWeight.w800)), Text(me.session, style: ts(u, 30, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
          Icon(Icons.masks_outlined, size: 64 * u, color: const Color(0xFF4FF0E0), shadows: [Shadow(color: const Color(0xFF28E6D7), blurRadius: 8 * u)]),
        ])),
        SizedBox(height: 14 * u),
        Row(children: [
          tile('Scan', Icons.qr_code_scanner_rounded, () => pushScreen(context, const AnonScanPage())),
          tile('My QR', Icons.qr_code_2_rounded, () => pushScreen(context, const AnonQrPage())),
          tile('Identities', Icons.manage_accounts_outlined, () => pushScreen(context, const AnonIdentitiesPage())),
          tile('New group', Icons.group_add_outlined, () => showToast(context, 'Anonymous group — coming soon')),
        ]),
        SizedBox(height: 22 * u),
        _banner(u, 'Anonymous conversations are always end-to-end encrypted. Contacts see only a temporary name and your public key.'),
        OLabel('Anonymous chats', u: u),
        for (final c in chats)
          SteelPlate(
            u: u,
            onTap: () => pushScreen(context, ConversationPage(c.id)),
            child: Row(children: [
              Face(u: u, person: c.group ? Person(c.id, c.title) : s.person(c.userId), size: 104, tint: _teal, online: c.userId != null && s.person(c.userId).online),
              SizedBox(width: 26 * u),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 42, w: FontWeight.w800)), Text(_last(c), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
              if (c.unread > 0) Container(width: 46 * u, height: 46 * u, alignment: Alignment.center, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE11D1D)), child: Text('${c.unread}', style: ts(u, 26, w: FontWeight.w800))),
              SizedBox(width: 10 * u),
              Icon(Icons.chevron_right_rounded, size: 52 * u, color: const Color(0xFFE8EDF1)),
            ]),
          ),
      ],
    );
  }

  String _last(Chat c) {
    final m = s.last(c.id);
    if (m == null) return '';
    return m.type == MType.document ? '📄 ${m.extra?['name']}' : (m.text ?? m.type.name);
  }
}

class AnonIdentitiesPage extends StatefulWidget {
  const AnonIdentitiesPage({super.key});
  @override
  State<AnonIdentitiesPage> createState() => _AnonIdentitiesPageState();
}

class _AnonIdentitiesPageState extends State<AnonIdentitiesPage> {
  Store get s => Store.i;
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    return PageShell(
      title: 'Identities',
      active: 'home',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 330,
      footer: FootBar(u: u, child: _tealBtn(u, 'New identity', Icons.add_rounded, () => setState(s.createIdentity))),
      children: [
        _banner(u, 'Each identity has its own temporary name, session ID and key pair. Switch anytime — contacts only know the identity you used with them.'),
        OLabel('Your identities', u: u),
        for (final a in s.identities)
          SteelPlate(
            u: u,
            onTap: () => setState(() => s.setActive(a.id)),
            child: Row(children: [
              Face(u: u, person: Person(a.id, a.name), size: 104, tint: _teal),
              SizedBox(width: 26 * u),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(a.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 42, w: FontWeight.w800)), Text('${a.session} · ${a.id == s.activeAnon ? 'Active' : 'Tap to switch'}', style: ts(u, 30, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
              if (a.id == s.activeAnon) Icon(Icons.check_rounded, size: 52 * u, color: const Color(0xFF4FF0E0)),
              if (s.identities.length > 1) ...[
                SizedBox(width: 12 * u),
                Tap(
                  onTap: () async {
                    if (await confirmDialog(context, title: 'Delete identity?', text: 'Its keys are removed from this device.')) setState(() => s.deleteIdentity(a.id));
                  },
                  child: Icon(Icons.delete_outline_rounded, size: 56 * u, color: const Color(0xFFFF6A5A)),
                ),
              ],
            ]),
          ),
        SizedBox(height: 10 * u),
        ArtBtn(u: u, label: 'Show QR & public key', icon: Icons.qr_code_2_rounded, minH: 120, fontPx: 38, onTap: () => pushScreen(context, const AnonQrPage())),
      ],
    );
  }
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.seed);
  final String seed;
  @override
  void paint(Canvas canvas, Size size) {
    const n = 29;
    final cell = size.width / n;
    var h = 2166136261;
    final on = List<bool>.filled(n * n, false);
    for (var i = 0; i < n * n; i++) {
      h ^= seed.codeUnitAt(i % seed.length) + i * 31;
      h = (h * 16777619) & 0xFFFFFFFF;
      on[i] = ((h >> 7) % 5) < 2;
    }
    bool? finder(int x, int y) {
      bool inF(int ox, int oy) => x >= ox && x < ox + 7 && y >= oy && y < oy + 7;
      bool f(int ox, int oy) {
        final dx = x - ox, dy = y - oy;
        return dx == 0 || dy == 0 || dx == 6 || dy == 6 || (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4);
      }
      if (inF(0, 0)) return f(0, 0);
      if (inF(n - 7, 0)) return f(n - 7, 0);
      if (inF(0, n - 7)) return f(0, n - 7);
      return null;
    }
    final p = Paint()..color = const Color(0xFF0A1A18);
    for (var i = 0; i < n * n; i++) {
      final x = i % n, y = i ~/ n;
      final f = finder(x, y);
      if (f ?? on[i]) canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell + .5, cell + .5), p);
    }
  }

  @override
  bool shouldRepaint(_QrPainter o) => o.seed != seed;
}

class AnonQrPage extends StatelessWidget {
  const AnonQrPage({super.key});
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final me = Store.i.me;
    return PageShell(
      title: 'My QR',
      active: 'home',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 80,
      children: [
        SteelPlate(u: u, pad: EdgeInsets.all(40 * u), child: Column(children: [
          Text(me.name, style: ts(u, 42, w: FontWeight.w800)),
          Text(me.session, style: ts(u, 30, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const [])),
          SizedBox(height: 24 * u),
          Container(width: 560 * u, height: 560 * u, padding: EdgeInsets.all(22 * u), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28 * u), boxShadow: [BoxShadow(color: const Color(0xFF28E6D7).withValues(alpha: .5), blurRadius: 28)]), child: CustomPaint(painter: _QrPainter(me.key))),
        ])),
        OLabel('Public key', u: u),
        SteelPlate(u: u, child: Text(me.key, style: ts(u, 25, c: const Color(0xFFB6FFF4), w: FontWeight.w400, sh: const []))),
        OLabel('Fingerprint', u: u),
        SteelPlate(u: u, child: Text(me.fingerprint, style: ts(u, 28, c: const Color(0xFFFFD9A0), w: FontWeight.w400, sh: const []))),
        SizedBox(height: 20 * u),
        _tealBtn(u, 'Copy public key', Icons.copy_rounded, () {
          Clipboard.setData(ClipboardData(text: me.key));
          showToast(context, 'Public key copied');
        }),
        SizedBox(height: 20 * u),
        _banner(u, 'Only share this with people you want to talk to. Your private key never leaves this device.'),
      ],
    );
  }
}

class AnonScanPage extends StatefulWidget {
  const AnonScanPage({super.key});
  @override
  State<AnonScanPage> createState() => _AnonScanPageState();
}

class _AnonScanPageState extends State<AnonScanPage> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  bool busy = false;
  final _key = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    _key.dispose();
    super.dispose();
  }

  void _pair() {
    setState(() => busy = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final c = Store.i.pairViaQR();
      Navigator.of(context).pushReplacement(PageRouteBuilder<void>(pageBuilder: (_, _, _) => ConversationPage(c.id), transitionDuration: const Duration(milliseconds: 600), transitionsBuilder: (_, a, _, ch) => FadeTransition(opacity: a, child: ch)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    return PageShell(
      title: 'Scan QR',
      active: 'home',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 80,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(40 * u), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF27303C), Color(0xFF0B1116)]), border: Border.all(color: const Color(0xFFAAB3BB), width: 6 * u), boxShadow: [BoxShadow(color: const Color(0xFF28E6D7).withValues(alpha: .45), blurRadius: 24 * u)]),
            child: Center(
              child: FractionallySizedBox(
                widthFactor: .62,
                heightFactor: .62,
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (_, _) => Stack(children: [
                    Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * u), border: Border.all(color: const Color(0xFF4FF0E0), width: 6 * u)))),
                    Align(alignment: Alignment(0, -.92 + 1.84 * _c.value), child: Container(height: 6 * u, color: const Color(0xFF4FF0E0))),
                    Center(child: Icon(Icons.qr_code_scanner_rounded, size: 200 * u, color: const Color(0x80B6FFF4))),
                  ]),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24 * u),
        _tealBtn(u, busy ? 'Exchanging keys…' : 'Simulate scan', Icons.qr_code_scanner_rounded, _pair, enabled: !busy),
        OLabel('Or paste a public key', u: u),
        GlassWell(u: u, child: TextField(controller: _key, onChanged: (_) => setState(() {}), cursorColor: const Color(0xFF4FF0E0), style: TextStyle(color: Colors.white, fontSize: 36 * u), decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: 'Public key (hex)', hintStyle: TextStyle(color: const Color(0xFF8896A6), fontSize: 36 * u)))),
        SizedBox(height: 16 * u),
        ArtBtn(u: u, label: 'Pair with key', minH: 120, fontPx: 38, enabled: _key.text.trim().length >= 16 && !busy, onTap: _pair),
        SizedBox(height: 24 * u),
        _banner(u, 'Pairing creates a new end-to-end encrypted conversation. You will see only a temporary name.'),
      ],
    );
  }
}
