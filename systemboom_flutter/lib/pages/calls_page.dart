import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shell.dart';
import '../ui.dart';

enum CallKind { incoming, missed, outgoing, video }

class _Call {
  const _Call(this.name, this.initials, this.color, this.kind, this.when, {this.duration, this.fav = false, this.photo});
  final String? photo;
  final String name;
  final String initials;
  final Color color;
  final CallKind kind;
  final String when;
  final String? duration;
  final bool fav;
}

const _calls = <_Call>[
  _Call('Priya Mehta', 'PM', Color(0xFFC03A8A), CallKind.incoming, 'Incoming Call • 2 mins ago', duration: '5:24', fav: true, photo: 'face1'),
  _Call('Rohit Verma', 'RV', Color(0xFF2F6A8A), CallKind.missed, 'Missed Call • 1 hour ago', photo: 'face2'),
  _Call('Sneha Kapoor', 'SK', Color(0xFF2F8A6A), CallKind.outgoing, 'Outgoing Call • 3 hours ago', duration: '12:36', fav: true, photo: 'face3'),
  _Call('Amit Singh', 'AS', Color(0xFF6A4FC8), CallKind.video, 'Video Call • Yesterday', duration: '25:18', photo: 'face4'),
  _Call('Boom Store', 'BS', Color(0xFF7A4FC8), CallKind.incoming, 'Incoming Call • Yesterday', duration: '2:05'),
  _Call('Deepa Karki', 'DK', Color(0xFFC9801F), CallKind.missed, 'Missed Call • 2 days ago'),
];

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  int tab = 0; // 0 recent, 1 missed, 2 favourites
  String q = '';

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final items = _calls.where((c) {
      if (tab == 1 && c.kind != CallKind.missed) return false;
      if (tab == 2 && !c.fav) return false;
      if (q.isNotEmpty && !c.name.toLowerCase().contains(q.toLowerCase())) return false;
      return true;
    }).toList();

    return PageShell(
      title: 'Calls',
      headerArt: 'hdr-calls',
      active: 'calls',
      right: ChromeBtn(u: u, gold: true, badge: '14', onTap: () => showToast(context, 'Notifications'), child: Icon(Icons.notifications_none_rounded, size: 46 * u, color: const Color(0xFFFFD27A))),
      children: [
        _search(u),
        SizedBox(height: 22 * u),
        _tabs(u),
        SizedBox(height: 26 * u),
        _makeCall(context, u),
        Padding(
          padding: EdgeInsets.fromLTRB(8 * u, 34 * u, 6 * u, 16 * u),
          child: Row(children: [
            Expanded(child: Text('RECENT CALLS', style: TextStyle(fontSize: (40 * u).clamp(14, 20), fontWeight: FontWeight.w800, letterSpacing: .4, color: Colors.white, decoration: TextDecoration.none))),
            Press(
              u: u,
              radius: 20,
              lift: 0,
              scaleUp: 1.05,
              shine: false,
              onTap: () => showToast(context, 'See all calls'),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * u, vertical: 6 * u),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('See All', style: TextStyle(fontSize: (33 * u).clamp(12, 16), fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.none)),
                  Icon(Icons.chevron_right_rounded, size: 40 * u, color: Colors.white),
                ]),
              ),
            ),
          ]),
        ),
        for (final c in items) _row(context, u, c),
        if (items.isEmpty) Padding(padding: EdgeInsets.all(60 * u), child: const Center(child: Text('No calls found', style: TextStyle(color: Color(0xFF8896A6), decoration: TextDecoration.none)))),
      ],
    );
  }

  // ─────────────────────────── search with mic
  Widget _search(double u) {
    // The bar is the reference art itself (chrome rim, steel-blue glass, orange glints) with its icons / hint removed;
    // the live search icon, text field and mic sit on top.
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final k = w / 851;
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
                  onChanged: (v) => setState(() => q = v),
                  cursorColor: const Color(0xFFFFB866),
                  style: TextStyle(color: Colors.white, fontSize: (27 * k).clamp(12, 17)),
                  decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: 'Search contacts, numbers or start a call...', hintStyle: TextStyle(color: const Color(0xFFD3DBE4), fontSize: (27 * k).clamp(11, 16))),
                ),
              ),
              Icon(Icons.mic_none_rounded, size: 40 * k, color: Colors.white),
              SizedBox(width: 34 * k),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _tabs(double u) {
    final defs = <(String, IconData, Color)>[
      ('Recent', Icons.schedule_rounded, Colors.white),
      ('Missed', Icons.phone_missed_rounded, const Color(0xFFFF4A3D)),
      ('Favorites', Icons.star_rounded, const Color(0xFFFFC24A)),
    ];
    // The strip is the reference art itself (chrome frame, dark glass panes, glowing orange key) with the labels removed;
    // the orange key slides to the selected tab and live icons / text sit on top.
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final k = w / 856;
      return SizedBox(
        height: 82 * k,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(child: Image.asset('assets/images/tabs-base.webp', fit: BoxFit.fill)),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            left: (8 + 280.0 * tab) * k,
            top: 0,
            width: 280 * k,
            height: 82 * k,
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * k), boxShadow: [BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .6), blurRadius: 18 * k)]),
              child: Image.asset('assets/images/tabs-key.webp', fit: BoxFit.fill),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * k),
              child: Row(children: [
                for (var i = 0; i < defs.length; i++)
                  Expanded(
                    child: Press(
                      u: u,
                      radius: 30,
                      lift: 0,
                      scaleUp: 1.0,
                      shine: false,
                      onTap: () => setState(() => tab = i),
                      builder: (context, g, s) => Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * k), color: Colors.white.withValues(alpha: tab == i ? 0 : .07 * g.clamp(0.0, 1.0))),
                        child: Center(
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(defs[i].$2, size: 38 * k, color: defs[i].$3),
                            SizedBox(width: 14 * k),
                            Text(defs[i].$1, style: TextStyle(fontSize: (27 * k).clamp(12, 17), fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.none)),
                          ]),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ]),
      );
    });
  }

  // ─────────────────────────── "Make a Call" hero card
  Widget _makeCall(BuildContext context, double u) {
    // Reference art (steel plate, glowing ring + orb) with its text removed; ring and orb are separate sprites that animate.
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final k = w / 852;
      return SizedBox(
        height: 222 * k,
        child: Press(
          u: u,
          radius: 34,
          lift: 3,
          onTap: () => showToast(context, 'Make a call'),
          builder: (context, g, s) => Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: Image.asset('assets/images/makecall-bg.webp', fit: BoxFit.fill)),
            Positioned(
              left: 34 * k,
              top: 16 * k,
              width: 192 * k,
              height: 192 * k,
              child: Transform.rotate(angle: .12 * math.sin(s * math.pi * 3) * (1 - s), child: Image.asset('assets/images/makecall-ring.webp', fit: BoxFit.fill)),
            ),
            Positioned(
              left: 300 * k,
              top: 50 * k,
              right: 176 * k,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GradText(
                  'Make a Call',
                  colors: const [Color(0xFFFFF0D2), Color(0xFFFFD39A), Color(0xFFFF9A3A), Color(0xFFFFD199)],
                  stops: const [0, .35, .62, 1],
                  style: TextStyle(fontSize: (58 * k).clamp(22, 34), fontWeight: FontWeight.w800, height: 1.1, decoration: TextDecoration.none),
                  shadow: const Color(0xFF3B1A04),
                  u: u,
                ),
                SizedBox(height: 8 * k),
                Text('Connect with anyone, anywhere in the world.', style: TextStyle(fontSize: (29 * k).clamp(12, 18), height: 1.22, color: Colors.white, decoration: TextDecoration.none)),
              ]),
            ),
            Positioned(
              left: 682 * k,
              top: 46 * k,
              width: 132 * k,
              height: 132 * k,
              child: Transform.scale(scale: 1 + .05 * g.clamp(0.0, 1.0), child: Image.asset('assets/images/makecall-orb.webp', fit: BoxFit.fill)),
            ),
          ]),
        ),
      );
    });
  }

  // ─────────────────────────── call rows
  Widget _row(BuildContext context, double u, _Call c) {
    final (IconData icon, Color ic, Color ring) = switch (c.kind) {
      CallKind.incoming => (Icons.south_west_rounded, const Color(0xFF35E07F), const Color(0xFF2FD070)),
      CallKind.missed => (Icons.phone_missed_rounded, const Color(0xFFFF4A3D), const Color(0xFFFF5A4D)),
      CallKind.outgoing => (Icons.north_east_rounded, const Color(0xFF4FC3FF), const Color(0xFF4FA8FF)),
      CallKind.video => (Icons.videocam_rounded, const Color(0xFFC77DFF), const Color(0xFF7A6AFF)),
    };
    final video = c.kind == CallKind.video;
    return RowCard(
      u: u,
      minHeight: 118,
      onTap: () => showToast(context, 'Calling ${c.name}'),
      leading: _Face(u: u, photo: c.photo, initials: c.initials, color: c.color, ring: ring),
      title: c.name,
      subtitle: Row(children: [
        Icon(icon, size: 36 * u, color: ic),
        SizedBox(width: 12 * u),
        Flexible(child: Text(c.when, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: (28 * u).clamp(10, 14), fontWeight: FontWeight.w500, color: Colors.white, decoration: TextDecoration.none))),
      ]),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (c.duration != null) Text(c.duration!, style: TextStyle(fontSize: (31 * u).clamp(11, 15), fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.none)),
        SizedBox(width: 14 * u),
        _CallBtn(u: u, video: video, onTap: () => showToast(context, '${video ? 'Video call' : 'Calling'} · ${c.name}')),
        SizedBox(width: 4 * u),
        Press(
          u: u,
          radius: 20,
          lift: 0,
          scaleUp: 1.2,
          shine: false,
          onTap: () => showToast(context, 'More options'),
          child: Padding(padding: EdgeInsets.all(6 * u), child: Icon(Icons.more_vert_rounded, size: 42 * u, color: Colors.white)),
        ),
      ]),
    );
  }
}

/// Round photo with a gold chrome ring and a thin coloured accent (direction colour).
class _Face extends StatelessWidget {
  const _Face({required this.u, required this.photo, required this.initials, required this.color, required this.ring});
  final double u;
  final String? photo;
  final String initials;
  final Color color;
  final Color ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104 * u,
      height: 104 * u,
      padding: EdgeInsets.all(5 * u),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const SweepGradient(colors: [Color(0xFFFFE2A8), Color(0xFFB9772A), Color(0xFF5A3510), Color(0xFFFFD58A), Color(0xFFB9772A), Color(0xFFFFE2A8)]),
        boxShadow: [BoxShadow(color: ring.withValues(alpha: .75), blurRadius: 12 * u), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 7 * u, offset: Offset(0, 5 * u))],
      ),
      child: Container(
        padding: EdgeInsets.all(3 * u),
        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0A0604)),
        child: ClipOval(
          child: photo != null
              ? Image.asset('assets/images/$photo.webp', fit: BoxFit.cover)
              : Container(color: color, alignment: Alignment.center, child: Text(initials, style: TextStyle(fontSize: (34 * u).clamp(14, 18), fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none))),
        ),
      ),
    );
  }
}

/// Round call button: gold ring + gold phone, or blue neon ring + white camera for video calls.
class _CallBtn extends StatelessWidget {
  const _CallBtn({required this.u, required this.video, required this.onTap});
  final double u;
  final bool video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ring = video ? const Color(0xFF4A5CFF) : const Color(0xFFFF9A3A);
    return SizedBox(
      width: 88 * u,
      height: 88 * u,
      child: Press(
        u: u,
        circle: true,
        scaleUp: 1.12,
        lift: 3,
        onTap: onTap,
        builder: (context, g, s) => DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: video
                ? const RadialGradient(center: Alignment(-.3, -.5), colors: [Color(0xFF16206A), Color(0xFF080C30)])
                : const RadialGradient(center: Alignment(-.3, -.5), colors: [Color(0xFF3A2410), Color(0xFF0A0604)]),
            border: Border.all(color: ring, width: 4.5 * u),
            boxShadow: [BoxShadow(color: ring.withValues(alpha: .8), blurRadius: 14 * u), BoxShadow(color: ring.withValues(alpha: .55), blurRadius: 12 * u, blurStyle: BlurStyle.inner), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 6 * u, offset: Offset(0, 4 * u))],
          ),
          child: Center(
            child: Transform.rotate(
              angle: video ? 0 : .22 * math.sin(s * math.pi * 3) * (1 - s),
              child: Icon(video ? Icons.videocam_outlined : Icons.phone_rounded, size: (video ? 54 : 50) * u, color: video ? Colors.white : const Color(0xFFFFC978), shadows: [Shadow(color: ring, blurRadius: 8 * u)]),
            ),
          ),
        ),
      ),
    );
  }
}
