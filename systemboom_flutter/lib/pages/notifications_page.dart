import 'package:flutter/material.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'chat_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Store get s => Store.i;

  IconData _icon(String k) => switch (k) {
        'message' => Icons.chat_bubble_outline_rounded,
        'mention' => Icons.alternate_email_rounded,
        'reaction' => Icons.favorite_border_rounded,
        'missed_call' => Icons.phone_missed_rounded,
        'group_invite' => Icons.person_add_alt_1_outlined,
        _ => Icons.inventory_2_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final unread = s.unreadNotifs;
    return PageShell(
      title: 'Notifications',
      active: 'profile',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 80,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(6 * u, 4 * u, 6 * u, 14 * u),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$unread unread', style: ts(u, 46, w: FontWeight.w400, c: const Color(0xFFCFE0FF))),
            Tap(
              enabled: unread > 0,
              onTap: () => setState(() {
                for (final n in s.notifs) {
                  n.read = true;
                }
              }),
              child: Nine('notif-btn', px: sizeBtnSmall, slice: 40, u: u, minH: 104 * u, pad: EdgeInsets.symmetric(horizontal: 40 * u, vertical: 22 * u), child: Row(mainAxisSize: MainAxisSize.min, children: [Text('Mark all read', style: ts(u, 42, w: FontWeight.w700)), Icon(Icons.chevron_right_rounded, size: 44 * u, color: Colors.white)])),
            ),
          ]),
        ),
        for (var i = 0; i < s.notifs.length; i++)
          Rise(
            i: i,
            child: Padding(
              padding: EdgeInsets.only(bottom: 14 * u),
              child: Tap(
                onTap: () {
                  setState(() => s.notifs[i].read = true);
                  final c = s.notifs[i].chat;
                  if (c != null) pushScreen(context, ConversationPage(c));
                },
                child: Nine('notif-card', px: sizeNotif, slice: 60, u: u, minH: 210 * u, pad: EdgeInsets.fromLTRB(40 * u, 34 * u, 70 * u, 34 * u),
                    child: Row(children: [
                      _ring(u, _icon(s.notifs[i].kind)),
                      SizedBox(width: 26 * u),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Expanded(child: Text(s.notifs[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 54, w: FontWeight.w800))),
                            if (!s.notifs[i].read) Container(width: 20 * u, height: 20 * u, margin: EdgeInsets.only(right: 10 * u), decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF7A1A), boxShadow: [BoxShadow(color: const Color(0xFFFF7A1A), blurRadius: 10 * u)])),
                            Text(s.notifs[i].time, style: ts(u, 36, c: const Color(0xFF9FC6FF), w: FontWeight.w500, sh: const [])),
                          ]),
                          SizedBox(height: 8 * u),
                          Text(s.notifs[i].body, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 38, c: const Color(0xFFB9CBF2), w: FontWeight.w400, sh: const [])),
                        ]),
                      ),
                    ])),
              ),
            ),
          ),
      ],
    );
  }

  Widget _ring(double u, IconData ic) => Container(
        width: 146 * u,
        height: 146 * u,
        padding: EdgeInsets.all(9 * u),
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: const SweepGradient(colors: [Colors.white, Color(0xFFAEB7C0), Color(0xFF3A424A), Color(0xFFCFD6DC), Color(0xFF69737C), Colors.white]), boxShadow: [BoxShadow(color: const Color(0xFFFF821E).withValues(alpha: .35), blurRadius: 14 * u), BoxShadow(color: Colors.black.withValues(alpha: .75), blurRadius: 8 * u, offset: Offset(0, 6 * u))]),
        child: DecoratedBox(
          decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(center: Alignment(0, -.4), colors: [Color(0xFF2B1A08), Color(0xFF0A0603)]), border: Border.all(color: const Color(0xF2FF8C28), width: 3.5 * u)),
          child: Center(child: Icon(ic, size: 70 * u, color: const Color(0xFFFFA83A), shadows: [Shadow(color: const Color(0xF2FF961E), blurRadius: 8 * u)])),
        ),
      );
}
