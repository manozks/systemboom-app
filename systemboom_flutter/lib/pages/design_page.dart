import 'package:flutter/material.dart';

import '../shell.dart';
import '../ui.dart';

class DesignPage extends StatefulWidget {
  const DesignPage({super.key});

  @override
  State<DesignPage> createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  int icon = 0;
  int btn = 0;

  static const _brand = <(String, String, Color, Color, Color)>[
    ('Primary', '#FF8A00', Color(0xFFFFB24A), Color(0xFFFF8A00), Color(0xFFB85A00)),
    ('Secondary', '#00B2FF', Color(0xFF5ACBFF), Color(0xFF0A5CFF), Color(0xFF0A2E9A)),
    ('Accent', '#A855F7', Color(0xFFC98BFF), Color(0xFF8A3CE8), Color(0xFF4A168A)),
    ('Success', '#22C55E', Color(0xFF6BE69A), Color(0xFF16A04A), Color(0xFF0A5A24)),
    ('Danger', '#EF4444', Color(0xFFFF8A8A), Color(0xFFE02020), Color(0xFF8A0A0A)),
    ('Warning', '#F59E0B', Color(0xFFFFD36A), Color(0xFFF59E0B), Color(0xFFA85E00)),
    ('Neutral', '#94A3B8', Color(0xFFC6D0DE), Color(0xFF6A7686), Color(0xFF2F3744)),
  ];

  static const _icons = <IconData>[
    Icons.home_outlined, Icons.chat_bubble_outline_rounded, Icons.phone_rounded, Icons.shopping_cart_outlined, Icons.person_outline_rounded, Icons.settings_rounded, Icons.notifications_rounded,
    Icons.favorite_border_rounded, Icons.search_rounded, Icons.tune_rounded, Icons.place_outlined, Icons.photo_camera_outlined, Icons.mail_outline_rounded, Icons.more_horiz_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    return PageShell(
      title: 'Design System',
      headerArt: 'hdr-calls',
      active: 'profile',
      right: ChromeBtn(u: u, gold: true, onTap: () => showToast(context, 'Design tokens'), child: Icon(Icons.palette_outlined, size: 46 * u, color: const Color(0xFFFFD27A))),
      children: [
        _colors(u),
        _typography(u),
        _buttons(context, u),
        _icons14(u),
        Padding(padding: EdgeInsets.only(top: 14 * u), child: Center(child: Text('Build once. Reuse everywhere. Consistency is a feature. — DS-003', textAlign: TextAlign.center, style: TextStyle(fontSize: (26 * u).clamp(10, 12), color: const Color(0xFF7F8E9E), decoration: TextDecoration.none)))),
      ],
    );
  }

  // ───────── brand colours: the reference art (plate + glossy orbs) with live title, caption, names and hex codes
  Widget _colors(double u) {
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 853;
      return Padding(
        padding: EdgeInsets.only(top: 22 * u, bottom: 34 * u),
        child: SizedBox(
          height: 230 * k,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(36 * k), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 14 * u, offset: Offset(0, 10 * u)), BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .4), blurRadius: 20 * u)]),
              child: Image.asset('assets/images/brand-colors.webp', fit: BoxFit.fill),
            )),
            Positioned(left: 32 * k, top: 22 * k, child: Text('Brand Colors', style: TextStyle(fontSize: 31 * k, fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none))),
            Positioned(right: 30 * k, top: 28 * k, child: Text('Primary • Secondary • Status • Neutral', style: TextStyle(fontSize: 22 * k, color: Colors.white, decoration: TextDecoration.none))),
            for (var i = 0; i < _brand.length; i++)
              Positioned(
                left: (22 + i * 114.0) * k,
                top: 60 * k,
                width: 114 * k,
                height: 126 * k,
                child: Press(
                  u: u,
                  radius: 20,
                  lift: 3,
                  scaleUp: 1.04,
                  shine: false,
                  onTap: () => showToast(context, '${_brand[i].$1} ${_brand[i].$2}'),
                  builder: (context, g, s) => Column(children: [
                    SizedBox(height: 84 * k),
                    FittedBox(fit: BoxFit.scaleDown, child: Text(_brand[i].$1, maxLines: 1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white, decoration: TextDecoration.none))),
                    FittedBox(fit: BoxFit.scaleDown, child: Text(_brand[i].$2, maxLines: 1, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _brand[i].$3, decoration: TextDecoration.none))),
                  ]),
                ),
              ),
          ]),
        ),
      );
    });
  }

  // ───────── typography: the reference art (plate + framed "Aa" tile) with live headings, caption and size table
  Widget _typography(double u) {
    const spec = <(String, String, FontWeight)>[
      ('Heading 1', '28 / Bold', FontWeight.w800),
      ('Heading 2', '24 / SemiBold', FontWeight.w700),
      ('Heading 3', '20 / SemiBold', FontWeight.w700),
      ('Heading 4', '16 / Medium', FontWeight.w500),
      ('Body Text', '14 / Regular', FontWeight.w400),
      ('Caption', '12 / Regular', FontWeight.w400),
    ];
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 853;
      Widget h(String t, double size, FontWeight w, double top) => Positioned(
            left: 36 * k,
            top: top * k,
            child: GradText(t, colors: const [Colors.white, Color(0xFFE2E7EE), Color(0xFF8E98A4)], stops: const [0, .5, 1], style: TextStyle(fontSize: size * k, fontWeight: w, height: 1.1, decoration: TextDecoration.none), shadow: const Color(0xFF05080C), u: u),
          );
      return Padding(
        padding: EdgeInsets.only(bottom: 18 * u),
        child: SizedBox(
          height: 278 * k,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(36 * k), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 14 * u, offset: Offset(0, 10 * u)), BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .4), blurRadius: 20 * u)]),
              child: Image.asset('assets/images/typography.webp', fit: BoxFit.fill),
            )),
            Positioned(left: 34 * k, top: 22 * k, child: Text('Typography', style: TextStyle(fontSize: 29 * k, fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none))),
            Positioned(right: 36 * k, top: 28 * k, child: Text('Font Family: Poppins (Recommended)', style: TextStyle(fontSize: 21 * k, color: Colors.white, decoration: TextDecoration.none))),
            h('Heading 1', 48, FontWeight.w900, 66),
            h('Heading 2', 38, FontWeight.w800, 120),
            h('Heading 3', 28, FontWeight.w700, 164),
            h('Heading 4', 21, FontWeight.w500, 199),
            Positioned(left: 36 * k, top: 226 * k, child: Text('Body Text', style: TextStyle(fontSize: 18 * k, color: Colors.white, decoration: TextDecoration.none))),
            for (var i = 0; i < spec.length; i++)
              Positioned(
                left: 566 * k,
                top: (66 + i * 31.5) * k,
                width: 262 * k,
                child: Press(
                  u: u,
                  radius: 10,
                  lift: 0,
                  scaleUp: 1.03,
                  shine: false,
                  onTap: () => showToast(context, '${spec[i].$1} · ${spec[i].$2}'),
                  child: Row(children: [
                    SizedBox(width: 124 * k, child: Text(spec[i].$1, maxLines: 1, style: TextStyle(fontSize: 19 * k, fontWeight: spec[i].$3, color: Colors.white, decoration: TextDecoration.none))),
                    Text(spec[i].$2, maxLines: 1, style: TextStyle(fontSize: 18 * k, color: const Color(0xFFE6ECF3), decoration: TextDecoration.none)),
                  ]),
                ),
              ),
          ]),
        ),
      );
    });
  }

  // ───────── buttons: the reference art (plate + four glowing keys) with live title, caption and labels
  Widget _buttons(BuildContext context, double u) {
    const names = ['Primary', 'Secondary', 'Outline', 'Ghost'];
    const xs = <(double, double)>[(30, 218), (236, 422), (440, 622), (640, 822)];
    const cols = <Color>[Color(0xFFFFB866), Color(0xFFBFD8FF), Colors.white, Colors.white];
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 853;
      return Padding(
        padding: EdgeInsets.only(bottom: 18 * u),
        child: SizedBox(
          height: 153 * k,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * k), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 14 * u, offset: Offset(0, 10 * u)), BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .4), blurRadius: 20 * u)]),
              child: Image.asset('assets/images/buttons-panel.webp', fit: BoxFit.fill),
            )),
            Positioned(left: 32 * k, top: 18 * k, child: Text('Buttons', style: TextStyle(fontSize: 28 * k, fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none))),
            Positioned(right: 30 * k, top: 24 * k, child: Text('Primary • Secondary • Outline • Ghost', style: TextStyle(fontSize: 21 * k, color: Colors.white, decoration: TextDecoration.none))),
            for (var i = 0; i < 4; i++)
              Positioned(
                left: xs[i].$1 * k,
                top: 64 * k,
                width: (xs[i].$2 - xs[i].$1) * k,
                height: 70 * k,
                child: Press(
                  u: u,
                  radius: 999,
                  lift: 3,
                  scaleUp: 1.05,
                  onTap: () {
                    setState(() => btn = i);
                    showToast(context, names[i]);
                  },
                  child: Center(child: Text(names[i], style: TextStyle(fontSize: 26 * k, fontWeight: FontWeight.w600, color: cols[i], decoration: TextDecoration.none))),
                ),
              ),
          ]),
        ),
      );
    });
  }

  // ───────── icons: the reference art (plate + 14 glass keys) with live title, caption, icons and a sliding orange key
  Widget _icons14(double u) {
    const xs = <double>[36, 150, 266, 380, 494, 608, 722];
    const rowY = <double>[62, 150];
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 853;
      final sel = icon;
      return SizedBox(
        height: 239 * k,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(child: DecoratedBox(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * k), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 14 * u, offset: Offset(0, 10 * u)), BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .4), blurRadius: 20 * u)]),
            child: Image.asset('assets/images/icons-panel.webp', fit: BoxFit.fill),
          )),
          Positioned(left: 32 * k, top: 16 * k, child: Text('Icons', style: TextStyle(fontSize: 28 * k, fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none))),
          Positioned(right: 30 * k, top: 22 * k, child: Text('Navigation • Action • System', style: TextStyle(fontSize: 21 * k, color: Colors.white, decoration: TextDecoration.none))),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            left: (xs[sel % 7] - 8) * k,
            top: (rowY[sel ~/ 7] - 6) * k,
            width: 108 * k,
            height: 88 * k,
            child: Image.asset('assets/images/icon-key.webp', fit: BoxFit.fill),
          ),
          for (var i = 0; i < _icons.length; i++)
            Positioned(
              left: xs[i % 7] * k,
              top: rowY[i ~/ 7] * k,
              width: 92 * k,
              height: 76 * k,
              child: Press(
                u: u,
                radius: 24,
                lift: 2,
                scaleUp: 1.05,
                shine: false,
                onTap: () => setState(() => icon = i),
                builder: (context, g, s) => Center(child: Transform.scale(scale: 1 + .15 * (s < .5 ? s * 2 : (1 - s) * 2), child: Icon(_icons[i], size: 42 * k, color: sel == i ? const Color(0xFFFFC66E) : Colors.white))),
              ),
            ),
        ]),
      );
    });
  }
}
