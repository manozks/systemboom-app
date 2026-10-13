import 'package:flutter/material.dart';

import 'kit.dart';
import 'shell.dart';

/// Celestial emoji: each planet replaces a standard emoji key (kept as the stored value).
class Celestial {
  final String key, asset, name, label;
  final Color glow; // halo colour in the picker
  const Celestial(this.key, this.asset, this.name, this.label, this.glow);
  String get path => 'assets/images/celestial/$asset.webp';
}

const celestials = [
  Celestial('❤️', 'venus', 'Venus', 'Love', Color(0xFFFF6FA3)),
  Celestial('🔥', 'sun', 'Sun', 'Joy', Color(0xFFFFB02E)),
  Celestial('😂', 'meteors', 'Meteor Shower', 'Laugh', Color(0xFFFF7A2A)),
  Celestial('😮', 'comet', 'Comet', 'Wow', Color(0xFF4FA8FF)),
  Celestial('👍', 'jupiter', 'Jupiter', 'Celebrate', Color(0xFFFFA860)),
  Celestial('🙏', 'saturn', 'Saturn', 'Support', Color(0xFFFFD27A)),
  Celestial('🌙', 'moon', 'Moon', 'Touched', Color(0xFFA9C4FF)),
  Celestial('🤔', 'mercury', 'Mercury', 'Curious', Color(0xFFFFB84D)),
];

Celestial? celestialFor(String key) {
  for (final c in celestials) {
    if (c.key == key) return c;
  }
  return null;
}

Widget celestialIcon(String key, double size, {double fallbackFont = 26}) {
  final c = celestialFor(key);
  if (c == null) return Text(key, style: TextStyle(fontSize: fallbackFont, decoration: TextDecoration.none));
  return Image.asset(c.path, width: size, height: size, fit: BoxFit.contain);
}

/// Text with celestial emoji keys rendered as planet images.
Widget celestialText(String text, TextStyle style, double iconSize) {
  final keys = celestials.map((c) => RegExp.escape(c.key)).join('|');
  final re = RegExp(keys);
  if (!re.hasMatch(text)) return Text(text, style: style);
  final spans = <InlineSpan>[];
  var i = 0;
  for (final m in re.allMatches(text)) {
    if (m.start > i) spans.add(TextSpan(text: text.substring(i, m.start)));
    spans.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: celestialIcon(m.group(0)!, iconSize)));
    i = m.end;
  }
  if (i < text.length) spans.add(TextSpan(text: text.substring(i)));
  return Text.rich(TextSpan(children: spans), style: style);
}

/// 4×2 picker: glowing ringed planets in the ornate sheet panel. Calls [onPick] with the emoji key.
Future<void> showCelestialPicker(BuildContext context, void Function(String key) onPick) {
  return showArtSheet<void>(context, (c) {
    final u = c.u;
    Widget cell(Celestial e) => Tap(
          onTap: () {
            Navigator.pop(c);
            onPick(e.key);
          },
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              width: 176 * u,
              height: 176 * u,
              child: Stack(alignment: Alignment.center, children: [
                // coloured halo so each planet glows off the dark panel
                Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: e.glow.withValues(alpha: .55), blurRadius: 34 * u, spreadRadius: 2 * u)]))),
                Positioned.fill(child: Image.asset('assets/images/ring63-emoji.webp', fit: BoxFit.fill)),
                Image.asset(e.path, width: 124 * u, height: 124 * u, fit: BoxFit.contain),
              ]),
            ),
            SizedBox(height: 10 * u),
            FittedBox(fit: BoxFit.scaleDown, child: Text(e.name.toUpperCase(), maxLines: 1, style: ts(u, 23, c: e.glow.withValues(alpha: .95), w: FontWeight.w800, ls: 23 * u * .06))),
            SizedBox(height: 2 * u),
            Text(e.label, style: ts(u, 38, w: FontWeight.w900)),
          ]),
        );
    return Container(
      margin: EdgeInsets.only(bottom: 20 * u),
      child: Center(
        heightFactor: 1,
        child: ArtFrame(
          u: u,
          title: 'React',
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final e in celestials.sublist(0, 4)) Expanded(child: cell(e))]),
            SizedBox(height: 30 * u),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [for (final e in celestials.sublist(4)) Expanded(child: cell(e))]),
          ]),
        ),
      ),
    );
  });
}
