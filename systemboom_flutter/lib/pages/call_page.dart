import 'dart:async';

import 'package:flutter/material.dart';

import '../kit.dart';
import '../shell.dart';

class CallPage extends StatefulWidget {
  const CallPage(this.name, {super.key, this.video = false, this.photo});
  final String name;
  final bool video;
  final String? photo;
  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  int secs = -2;
  bool mute = false, spk = true, video = false, ended = false;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    video = widget.video;
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!ended && mounted) setState(() => secs++);
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  void _end() {
    setState(() => ended = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final w = u * 941;
    final k = w / 941;
    final ringing = secs < 0 && !ended;
    final status = ended ? 'Call ended · ${_fmt(secs < 0 ? 0 : secs)}' : ringing ? (video ? 'Video calling…' : 'Calling…') : _fmt(secs);
    final initials = widget.name.split(' ').map((p) => p.isEmpty ? '' : p[0]).take(2).join().toUpperCase();
    Widget btn(double x, IconData ic, bool on, VoidCallback f, {bool red = false}) => Positioned(
          left: (x - 92) * k,
          top: (990 - 92) * k,
          width: 184 * k,
          height: 184 * k,
          child: Tap(onTap: f, child: Icon(ic, size: 84 * k, color: red ? const Color(0xFFFFE0B0) : on ? const Color(0xFFFFB866) : Colors.white, shadows: [Shadow(color: (on || red) ? const Color(0xE6FF8C1E) : const Color(0x59FFFFFF), blurRadius: 10 * k)])),
        );
    return Scaffold(
      backgroundColor: const Color(0xFF05070A),
      body: Center(
        child: SizedBox(
          width: w,
          height: 1365 * k,
          child: Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: Image.asset('assets/images/call-bg.webp', fit: BoxFit.fill)),
            if (ringing) Positioned(left: 175 * k, top: 50 * k, width: 590 * k, height: 590 * k, child: _Ping(k: k)),
            Positioned(
              left: 262 * k,
              top: 137 * k,
              width: 416 * k,
              height: 416 * k,
              child: ClipOval(
                child: widget.photo != null
                    ? Image.asset('assets/images/${widget.photo}.webp', fit: BoxFit.cover)
                    : Center(child: Text(initials, style: TextStyle(fontSize: 190 * k, fontWeight: FontWeight.w900, color: Colors.white, decoration: TextDecoration.none, shadows: [Shadow(color: const Color(0xE6FF9628), blurRadius: 14 * k)]))),
              ),
            ),
            Positioned(left: 40 * k, right: 40 * k, top: 690 * k, child: Center(child: Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: (widget.name.length > 14 ? 78 : 98) * k, fontWeight: FontWeight.w900, color: Colors.white, decoration: TextDecoration.none)))),
            Positioned(left: 0, right: 0, top: 800 * k, child: Center(child: Text(status, style: TextStyle(fontSize: 50 * k, fontWeight: FontWeight.w600, color: ended ? const Color(0xFFFF9A8F) : const Color(0xFFFFB347), decoration: TextDecoration.none, shadows: [Shadow(color: const Color(0xE6FF8C1E), blurRadius: 14 * k)])))),
            btn(155, mute ? Icons.mic_off_rounded : Icons.mic_none_rounded, mute, () => setState(() => mute = !mute)),
            btn(365, spk ? Icons.volume_up_rounded : Icons.volume_off_rounded, spk, () => setState(() => spk = !spk)),
            btn(575, video ? Icons.videocam_rounded : Icons.videocam_off_rounded, video, () => setState(() => video = !video)),
            btn(785, Icons.call_end_rounded, false, _end, red: true),
          ]),
        ),
      ),
    );
  }
}

class _Ping extends StatefulWidget {
  const _Ping({required this.k});
  final double k;
  @override
  State<_Ping> createState() => _PingState();
}

class _PingState extends State<_Ping> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Opacity(opacity: .75 * (1 - _c.value), child: Transform.scale(scale: .85 + .5 * _c.value, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFF9632), width: 6 * widget.k))))),
      );
}
