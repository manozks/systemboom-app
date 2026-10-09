import 'package:flutter/material.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'chat_page.dart';

class ChatInfoPage extends StatefulWidget {
  const ChatInfoPage(this.chatId, {super.key});
  final String chatId;
  @override
  State<ChatInfoPage> createState() => _ChatInfoPageState();
}

class _ChatInfoPageState extends State<ChatInfoPage> {
  int tab = 0;
  Store get s => Store.i;

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final chat = s.chat(widget.chatId);
    final peer = chat.userId == null ? null : people[chat.userId];
    final media = 0;
    final pinned = s.thread(chat.id).where((m) => m.pinned && !m.deleted).toList();
    final ringW = 420 * u;

    Widget row(String label, IconData ic, bool on, VoidCallback f) => Padding(
          padding: EdgeInsets.fromLTRB(6 * u, 0, 6 * u, 8 * u),
          child: Nine('info-row', px: sizeInfoRow, slice: 70, u: u, minH: 146 * u, pad: EdgeInsets.fromLTRB(58 * u, 20 * u, 58 * u, 20 * u),
              child: Row(children: [
                GoldIcon(ic, u: u),
                Container(width: 4 * u, height: 90 * u, margin: EdgeInsets.symmetric(horizontal: 24 * u), color: const Color(0x99FF8A2A)),
                Expanded(child: Text(label, style: ts(u, 46, w: FontWeight.w800))),
                MetalSwitch(u: u, on: on, onChanged: (_) => setState(f)),
              ])),
        );

    Widget chip(int i, String l) => Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 7 * u),
            child: Tap(
              onTap: () => setState(() => tab = i),
              child: Nine(tab == i ? 'info-chip-on' : 'info-chip-off', px: tab == i ? sizeChipOn : sizeChipOff, slice: 40, u: u, minH: 100 * u, pad: EdgeInsets.symmetric(horizontal: 34 * u, vertical: 18 * u), child: Center(child: Text(l, style: ts(u, 40, w: FontWeight.w700)))),
            ),
          ),
        );

    return PageShell(
      title: 'Chat info',
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 90,
      children: [
        Center(
          child: SizedBox(
            width: ringW,
            height: ringW * 300 / 310,
            child: Stack(alignment: Alignment.center, children: [
              Positioned(
                left: ringW * .17,
                top: ringW * .15,
                width: ringW * .66,
                height: ringW * .66,
                child: ClipOval(
                  child: peer?.photo != null
                      ? Image.asset('assets/images/${peer!.photo}.webp', fit: BoxFit.cover)
                      : Container(decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(-.3, -.5), colors: [Color(0xFF14A09A), Color(0xFF07302E)])), alignment: Alignment.center, child: Text(chat.group ? '👥' : (peer?.initials ?? chat.title[0]), style: ts(u, 150, w: FontWeight.w900))),
                ),
              ),
              Positioned.fill(child: Image.asset('assets/images/info-ring.webp', fit: BoxFit.fill)),
              if (peer?.online ?? false) Positioned(right: ringW * .16, bottom: ringW * .12, child: Container(width: 46 * u, height: 46 * u, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF22C55E), border: Border.all(color: const Color(0xFF0D1117), width: 4 * u), boxShadow: const [BoxShadow(color: Color(0xFF22C55E), blurRadius: 10)]))),
            ]),
          ),
        ),
        Center(child: Text(chat.title, style: ts(u, 76, w: FontWeight.w900))),
        Center(child: Text(chat.group ? '4 members' : (peer?.about ?? ''), style: ts(u, 36, c: const Color(0xFFB9C9EE), w: FontWeight.w400, sh: const []))),
        SizedBox(height: 14 * u),
        if (!chat.group && !chat.private && peer != null) CtaBtn(u: u, label: 'Continue privately', icon: Icons.lock_outline_rounded, onTap: () => pushScreen(context, ConversationPage(s.openOrCreate(peer.id, private: true).id))),
        OLabel('Settings', u: u),
        row('Mute notifications', Icons.notifications_off_outlined, chat.muted, () => chat.muted = !chat.muted),
        row('Pin conversation', Icons.push_pin_outlined, chat.pinned, () => chat.pinned = !chat.pinned),
        row('Archive', Icons.archive_outlined, chat.archived, () => chat.archived = !chat.archived),
        OLabel('Shared', u: u),
        Row(children: [chip(0, 'Media $media'), chip(1, 'Pinned ${pinned.length}'), chip(2, 'Search')]),
        SizedBox(height: 20 * u),
        if (tab == 0) _empty(u, Icons.image_outlined, 'No shared media yet'),
        if (tab == 1 && pinned.isEmpty) _empty(u, Icons.push_pin_outlined, 'No pinned messages'),
        if (tab == 1) for (final m in pinned) SteelPlate(u: u, child: Text(m.text ?? m.type.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 38, w: FontWeight.w800))),
        if (tab == 2) _empty(u, Icons.search_rounded, 'Search messages in this chat'),
        CtaBtn(
          u: u,
          label: 'Delete conversation',
          icon: Icons.delete_outline_rounded,
          red: true,
          onTap: () async {
            final nav = Navigator.of(context);
            if (await confirmDialog(context, title: 'Delete conversation?', text: 'Removes it from your history only.')) {
              s.chats.remove(chat);
              s.touch();
              nav.popUntil((r) => r.isFirst);
            }
          },
        ),
      ],
    );
  }

  Widget _empty(double u, IconData ic, String t) => Padding(
        padding: EdgeInsets.symmetric(vertical: 24 * u),
        child: Column(children: [
          Container(width: 130 * u, height: 130 * u, decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * u), gradient: const LinearGradient(colors: [Color(0xFF4A4F57), Color(0xFF1B1F25)]), border: Border.all(color: const Color(0xFF8B7A5C), width: 4 * u)), child: Icon(ic, size: 70 * u, color: const Color(0xFFE8DCC8))),
          SizedBox(height: 14 * u),
          Text(t, style: ts(u, 36, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const [])),
        ]),
      );
}
