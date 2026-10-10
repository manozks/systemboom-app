import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data.dart' as d;
import '../kit.dart' show pushScreen;
import '../shell.dart';
import 'chat_page.dart';
import 'more_pages.dart';
import '../ui.dart';

class _Chat {
  const _Chat(this.id, this.name, this.initials, this.color, this.preview, this.time, this.unread, {this.online = false, this.photo, this.group = false, this.mic = false, this.logo});
  final String id;
  final String name;
  final String initials;
  final Color color;
  final String preview;
  final String time;
  final int unread;
  final bool online;
  final String? photo;
  final bool group;
  final bool mic;
  final String? logo;
}

List<_Chat> get _chats => [
      for (final c in d.Store.i.chats.where((c) => !c.anon))
        () {
          final peer = c.userId == null ? null : d.people[c.userId];
          final last = d.Store.i.last(c.id);
          final txt = last == null ? '' : switch (last.type) {
                d.MType.voice => 'Voice message',
                d.MType.document => '📄 ${last.extra?['name']}',
                d.MType.product => '🛍 Product',
                d.MType.offer => '💬 Offer',
                d.MType.order => '📦 Order update',
                _ => last.text ?? '',
              };
          return _Chat(c.id, c.title, peer?.initials ?? '', const Color(0xFFC9801F), txt, last?.time ?? '', c.unread, online: peer?.online ?? false, photo: peer?.photo, group: c.group, mic: last?.type == d.MType.voice);
        }(),
    ];

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  int tab = 0;
  String q = '';

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final items = _chats.where((c) {
      if (tab == 1 && c.unread == 0) return false;
      if (tab == 2 && !c.group) return false;
      if (q.isNotEmpty && !('${c.name} ${c.preview}').toLowerCase().contains(q.toLowerCase())) return false;
      return true;
    }).toList();

    return PageShell(
      title: 'Chats',
      headerArt: 'hdr-calls',
      active: 'chats',
      right: ChromeBtn(u: u, gold: true, badge: '14', onTap: () => pushScreen(context, const NotificationsLazy()), child: Icon(Icons.notifications_none_rounded, size: 46 * u, color: const Color(0xFFFFD27A))),
      children: [
        _search(u),
        SizedBox(height: 22 * u),
        _tabs(u),
        SizedBox(height: 26 * u),
        _newChat(context, u),
        Padding(
          padding: EdgeInsets.fromLTRB(8 * u, 34 * u, 6 * u, 16 * u),
          child: Row(children: [
            Expanded(child: Text('RECENT CHATS', style: TextStyle(fontSize: (40 * u).clamp(14, 20), fontWeight: FontWeight.w800, letterSpacing: .4, color: Colors.white, decoration: TextDecoration.none))),
            Press(
              u: u,
              radius: 20,
              lift: 0,
              scaleUp: 1.05,
              shine: false,
              onTap: () => showToast(context, 'See all chats'),
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
        if (items.isEmpty) Padding(padding: EdgeInsets.all(60 * u), child: const Center(child: Text('No conversations found', style: TextStyle(color: Color(0xFF8896A6), decoration: TextDecoration.none)))),
      ],
    );
  }

  Widget _newChat(BuildContext context, double u) {
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 856;
      return SizedBox(
        height: 215 * k,
        child: Press(
          u: u,
          radius: 34,
          lift: 3,
          onTap: () => pushScreen(context, const NewChatPage()).then((_) => setState(() {})),
          builder: (context, g, s) => Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: Image.asset('assets/images/cta.webp', fit: BoxFit.fill)),
            Positioned(
              left: 40 * k,
              top: 24 * k,
              width: 168 * k,
              height: 168 * k,
              child: Transform.rotate(
                angle: .1 * math.sin(s * math.pi * 3) * (1 - s),
                child: Container(
                  padding: EdgeInsets.all(9 * k),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(colors: [Colors.white, Color(0xFF8B949D), Color(0xFF2A3138), Color(0xFFD8DEE3), Color(0xFF5B656E), Colors.white, Color(0xFF9AA3AB), Color(0xFF2A3138), Colors.white]),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .6), blurRadius: 26 * k), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 12 * k, offset: Offset(0, 8 * k))],
                  ),
                  child: Container(
                    padding: EdgeInsets.all(14 * k),
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(0, -.3), colors: [Color(0xFF3A2410), Color(0xFF0A0604)])),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF8A2A), width: 5 * k),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .9), blurRadius: 16 * k), BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .7), blurRadius: 16 * k, blurStyle: BlurStyle.inner)],
                        gradient: const RadialGradient(center: Alignment(0, -.5), colors: [Color(0xFF5A2A0A), Color(0xFF140A04)]),
                      ),
                      child: Center(child: Icon(Icons.chat_bubble_rounded, size: 72 * k, color: const Color(0xFFFFC978), shadows: [Shadow(color: const Color(0xFFFF8C28), blurRadius: 14 * k)])),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 244 * k,
              top: 38 * k,
              right: 190 * k,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                GradText(
                  'New Chat',
                  colors: const [Color(0xFFFFF0D2), Color(0xFFFFCF8F), Color(0xFFFF9A3A), Color(0xFFFFD199)],
                  stops: const [0, .35, .6, 1],
                  style: TextStyle(fontSize: (60 * k).clamp(22, 32), fontWeight: FontWeight.w800, height: 1.1, decoration: TextDecoration.none),
                  shadow: const Color(0xFF3B1A04),
                  u: u,
                ),
                SizedBox(height: 6 * k),
                Text('Message a friend, a group or a store.', style: TextStyle(fontSize: (30 * k).clamp(12, 17), height: 1.2, color: Colors.white, decoration: TextDecoration.none)),
              ]),
            ),
            Positioned(
              left: 676 * k,
              top: 42 * k,
              width: 132 * k,
              height: 132 * k,
              child: Center(child: Transform.translate(offset: Offset(10 * k * math.sin(s * math.pi), 0), child: Icon(Icons.arrow_forward_rounded, size: 60 * k, color: Colors.white, shadows: const [Shadow(color: Color(0xCC5A1400), offset: Offset(0, 2), blurRadius: 2)]))),
            ),
          ]),
        ),
      );
    });
  }

  Widget _search(double u) {
    return LayoutBuilder(builder: (context, c) {
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
                  onChanged: (v) => setState(() => q = v),
                  cursorColor: const Color(0xFFFFB866),
                  style: TextStyle(color: Colors.white, fontSize: (27 * k).clamp(12, 17)),
                  decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: 'Search conversations', hintStyle: TextStyle(color: const Color(0xFFD3DBE4), fontSize: (27 * k).clamp(11, 16))),
                ),
              ),
              SizedBox(width: 34 * k),
            ]),
          ),
        ]),
      );
    });
  }

  Widget _tabs(double u) {
    const names = ['All', 'Unread', 'Groups'];
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 856;
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
                for (var i = 0; i < names.length; i++)
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
                        child: Center(child: Text(names[i], style: TextStyle(fontSize: (27 * k).clamp(12, 17), fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.none))),
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

  Widget _row(BuildContext context, double u, _Chat c) {
    return RowCard(
      u: u,
      minHeight: 126,
      onTap: () => pushScreen(context, ConversationPage(c.id)).then((_) => setState(() {})),
      leading: _ChatFace(u: u, chat: c),
      title: c.name,
      titleColors: const [Color(0xFFFFFFFF), Color(0xFFFFF2DC), Color(0xFFE8C99A)],
      subtitle: Row(children: [
        if (c.mic) Padding(padding: EdgeInsets.only(right: 8 * u), child: Icon(Icons.mic_rounded, size: 34 * u, color: Colors.white)),
        Flexible(child: Text(c.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: (31 * u).clamp(11, 15), fontWeight: FontWeight.w500, color: Colors.white, decoration: TextDecoration.none))),
      ]),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(c.time, style: TextStyle(fontSize: (29 * u).clamp(10, 14), fontWeight: FontWeight.w500, color: const Color(0xFFE9EEF3), decoration: TextDecoration.none)),
          if (c.unread > 0) ...[SizedBox(height: 8 * u), RedBadge(text: '${c.unread}', size: 50 * u)],
        ]),
        SizedBox(width: 10 * u),
        Icon(Icons.chevron_right_rounded, size: 46 * u, color: const Color(0xFFD5DCE4)),
      ]),
    );
  }
}

/// Round photo / logo / group avatar in a gold chrome ring, with a green online dot.
class _ChatFace extends StatelessWidget {
  const _ChatFace({required this.u, required this.chat});
  final double u;
  final _Chat chat;

  @override
  Widget build(BuildContext context) {
    final c = chat;
    final inner = c.photo != null
        ? Image.asset('assets/images/${c.photo}.webp', fit: BoxFit.cover)
        : Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.3), colors: [Color(0xFF4A2A10), Color(0xFF0E0804)])),
            child: c.group
                ? Icon(Icons.groups_2_rounded, size: 58 * u, color: const Color(0xFFFFE2B8), shadows: [Shadow(color: const Color(0xFFFF8C28), blurRadius: 8 * u)])
                : Text(c.logo ?? c.initials, style: TextStyle(fontSize: (60 * u).clamp(20, 30), fontWeight: FontWeight.w900, color: const Color(0xFFFFE2B8), decoration: TextDecoration.none, shadows: [Shadow(color: const Color(0xFFFF8C28), blurRadius: 8 * u)])),
          );
    final ringHot = c.photo == null;
    return SizedBox(
      width: 108 * u,
      height: 108 * u,
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(
          child: Container(
            padding: EdgeInsets.all(5 * u),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(colors: [Color(0xFFFFE2A8), Color(0xFFB9772A), Color(0xFF5A3510), Color(0xFFFFD58A), Color(0xFFB9772A), Color(0xFFFFE2A8)]),
              boxShadow: [BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: ringHot ? .75 : .35), blurRadius: (ringHot ? 14 : 8) * u), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 7 * u, offset: Offset(0, 5 * u))],
            ),
            child: Container(padding: EdgeInsets.all(3 * u), decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0A0604)), child: ClipOval(child: inner)),
          ),
        ),
        if (c.online)
          Positioned(
            right: 0,
            bottom: 2 * u,
            child: Container(width: 30 * u, height: 30 * u, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF22C55E), border: Border.all(color: const Color(0xFF0D1117), width: 3.5 * u), boxShadow: const [BoxShadow(color: Color(0xAA22C55E), blurRadius: 8)])),
          ),
      ]),
    );
  }
}
