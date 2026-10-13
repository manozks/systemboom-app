import 'package:flutter/material.dart';

import 'kit.dart';
import 'shell.dart';

/// Celestial emoji: each planet replaces a standard emoji key (kept as the stored value).
class Celestial {
  final String key, asset, name, label;
  const Celestial(this.key, this.asset, this.name, this.label);
  String get path => 'assets/images/celestial/$asset.webp';
}

const celestials = [
  Celestial('❤️', 'venus', 'Venus', 'Love'),
  Celestial('🔥', 'sun', 'Sun', 'Joy'),
  Celestial('😂', 'meteors', 'Meteor Shower', 'Laugh'),
  Celestial('😮', 'comet', 'Comet', 'Wow'),
  Celestial('👍', 'jupiter', 'Jupiter', 'Celebrate'),
  Celestial('🙏', 'saturn', 'Saturn', 'Support'),
  Celestial('🌙', 'moon', 'Moon', 'Touched'),
  Celestial('🤔', 'mercury', 'Mercury', 'Curious'),
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

/// 4×2 picker like the reference lineup. Calls [onPick] with the emoji key.
Future<void> showCelestialPicker(BuildContext context, void Function(String key) onPick) {
  return showArtSheet<void>(context, (c) {
    final u = c.u;
    Widget cell(Celestial e) => Tap(
          onTap: () {
            Navigator.pop(c);
            onPick(e.key);
          },
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Image.asset(e.path, width: 150 * u, height: 150 * u, fit: BoxFit.contain),
            SizedBox(height: 8 * u),
            Text(e.name.toUpperCase(), textAlign: TextAlign.center, style: ts(u, 24, c: const Color(0xFFAAB8C8), w: FontWeight.w500)),
            Text(e.label, style: ts(u, 34, w: FontWeight.w800)),
          ]),
        );
    return Container(
      margin: EdgeInsets.all(12 * u),
      padding: EdgeInsets.fromLTRB(20 * u, 30 * u, 20 * u, 30 * u),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44 * u),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232A33), Color(0xFF11151B), Color(0xFF0A0D11)]),
        border: Border.all(color: const Color(0xFFC3CBD2), width: 6 * u),
        boxShadow: [BoxShadow(color: const Color(0xFFFF821E).withValues(alpha: .45), blurRadius: 34 * u)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [for (final e in celestials.sublist(0, 4)) Expanded(child: cell(e))]),
        SizedBox(height: 36 * u),
        Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [for (final e in celestials.sublist(4)) Expanded(child: cell(e))]),
      ]),
    );
  });
}
