import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'call_page.dart';
import 'chat_info_page.dart';
import 'chat_extra_pages.dart';
import 'notifications_page.dart';
import 'offer_page.dart';
import 'order_page.dart';
import 'product_page.dart';

const _emoji = ['👍', '❤️', '😂', '😮', '🙏', '🔥'];

Widget bellBtn(BuildContext context, double u) => ChromeBtn(
      u: u,
      gold: true,
      badge: Store.i.unreadNotifs > 0 ? '${Store.i.unreadNotifs + 10}' : null,
      onTap: () => pushScreen(context, const NotificationsPage()),
      child: Icon(Icons.notifications_none_rounded, size: 46 * u, color: const Color(0xFFFFD27A)),
    );

class ConversationPage extends StatefulWidget {
  const ConversationPage(this.chatId, {super.key});
  final String chatId;
  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _scroll = ScrollController();
  final _input = TextEditingController();
  String? _quote;
  Msg? _editing;
  int _lastCount = 0;

  Store get s => Store.i;
  bool get _anon => s.chat(widget.chatId).anon;
  static const _teal = <double>[-.2, .1, .85, 0, 0, .3, .8, -.1, 0, 0, .9, .35, -.25, 0, 0, 0, 0, 0, 1, 0];

  @override
  void initState() {
    super.initState();
    s.addListener(_changed);
    s.chat(widget.chatId).unread = 0;
  }

  @override
  void dispose() {
    s.removeListener(_changed);
    _scroll.dispose();
    _input.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic);
    });
  }

  void _send() {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    if (_editing != null) {
      s.editMsg(_editing!, t);
      _input.clear();
      setState(() => _editing = null);
      return;
    }
    s.send(widget.chatId, MType.text, text: _quote == null ? t : '↩ $_quote\n$t');
    _input.clear();
    setState(() => _quote = null);
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final chat = s.chat(widget.chatId);
    final thread = s.thread(widget.chatId);
    if (thread.length != _lastCount) {
      _lastCount = thread.length;
      _toBottom();
    }
    final peer = chat.userId == null ? null : s.person(chat.userId);
    final status = (s.typing[widget.chatId] ?? false) ? 'typing…' : chat.anon ? 'end-to-end encrypted' : chat.group ? '4 members' : (peer?.online ?? false) ? 'online now' : 'last seen recently';

    return PageShell(
      title: chat.title,
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      hideTitle: true,
      controller: _scroll,
      bottomPad: 330,
      headerExtra: (c, uu, w, h) {
        final k = w / 854;
        Widget at(double x, double y, double ww, double hh, Widget ch) => Positioned(left: x * k, top: y * k, width: ww * k, height: hh * k, child: ch);
        Widget cb(String l, IconData ic, VoidCallback f, {bool gold = true}) => ChromeBtn(u: uu, gold: gold, onTap: f, child: Icon(ic, size: 40 * uu, color: gold ? const Color(0xFFFFD27A) : const Color(0xFFDFE6EE)));
        return Stack(clipBehavior: Clip.none, children: [
          at(150, 46, 104, 104, Tap(onTap: () => chat.anon ? (chat.userId != null ? pushScreen(context, AnonKeyPage(chat.userId!)) : null) : pushScreen(context, ChatInfoPage(widget.chatId)), lift: 0, child: Face(u: uu * 1.0, person: peer ?? const Person('g', 'Team'), size: 114, online: peer?.online ?? false))),
          at(278, 56, 250, 90, Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(chat.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(uu, chat.title.length > 14 ? 30 : 38, w: FontWeight.w800)),
            SizedBox(height: 4 * uu),
            Text(status, maxLines: 1, style: ts(uu, 26, c: const Color(0xFFE6ECF3), w: FontWeight.w500)),
          ])),
          at(536, 62, 80, 80, cb('Voice call', Icons.call_rounded, () => pushScreen(context, CallPage(chat.title, photo: peer?.photo)))),
          at(624, 62, 80, 80, cb('Video call', Icons.videocam_rounded, () => pushScreen(context, CallPage(chat.title, video: true, photo: peer?.photo)))),
          at(712, 62, 80, 80, cb('More', Icons.more_vert_rounded, _headerMenu, gold: false)),
        ]);
      },
      footer: _composer(context, u),
      children: [
        for (var i = 0; i < thread.length; i++) ...[
          if (i == 0 || thread[i].time != thread[i - 1].time && _day(thread[i].time) != _day(thread[i - 1].time)) _daySep(u, _day(thread[i].time)),
          _msg(context, u, thread[i], chat),
        ],
        if (s.typing[widget.chatId] ?? false)
          Padding(padding: EdgeInsets.only(top: 10 * u), child: Row(children: [Face(u: u, person: peer!, size: 104), SizedBox(width: 16 * u), Flexible(child: _bubble(u, false, Text('● ● ●', style: ts(u, 30, c: const Color(0xFFFF8A2A)))))])),
      ],
    );
  }

  String _day(String t) => t == 'Yesterday' || t == 'Mon' || t == '2 Oct' ? t : 'Today';

  Widget _daySep(double u, String label) => Padding(
        padding: EdgeInsets.symmetric(vertical: 14 * u),
        child: Row(children: [
          Expanded(child: _line(u)),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4 * u),
            padding: EdgeInsets.symmetric(horizontal: 44 * u, vertical: 8 * u),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF5A2208), Color(0xFF2A1206), Color(0xFF1C0E06)]),
              border: Border.all(color: const Color(0xFFE5560A), width: 3.5 * u),
              boxShadow: [BoxShadow(color: const Color(0xFFFF6A1A).withValues(alpha: .8), blurRadius: 16 * u)],
            ),
            child: Text(label, style: ts(u, 30, c: const Color(0xFFFFCF9A), w: FontWeight.w600)),
          ),
          Expanded(child: _line(u)),
        ]),
      );

  Widget _line(double u) => Container(height: 3 * u, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0x00FF6A1A), Color(0xFFFF6A1A), Color(0x00FF6A1A)]), boxShadow: [BoxShadow(color: const Color(0xFFFF6A1A), blurRadius: 8 * u)]));

  Widget _bubble(double u, bool mine, Widget child) {
    final art = mine ? 'chat-bubble-out' : 'chat-bubble';
    final nine = Nine(art, px: mine ? sizeBubbleOut : sizeBubble, slice: 38, u: u, pad: EdgeInsets.fromLTRB(40 * u, 36 * u, 40 * u, 36 * u), child: child);
    return Padding(padding: EdgeInsets.all(9 * u), child: _anon ? ColorFiltered(colorFilter: const ColorFilter.matrix(_teal), child: nine) : nine);
  }

  Widget _msg(BuildContext context, double u, Msg m, Chat chat) {
    if (m.type == MType.system) {
      return Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 8 * u), child: Container(padding: EdgeInsets.symmetric(horizontal: 22 * u, vertical: 8 * u), decoration: BoxDecoration(color: const Color(0x59000000), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0x14FFFFFF))), child: Text(m.text ?? '', style: ts(u, 25, c: const Color(0xFFAAB8C8), w: FontWeight.w500)))));
    }
    final mine = m.from == 'me';
    final who = s.person(m.from);
    final face = Face(u: u, person: who, size: 104);
    final body = _body(context, u, m, mine);
    final meta = Padding(
      padding: EdgeInsets.only(top: 4 * u),
      child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start, children: [
        if (m.pinned) Icon(Icons.push_pin_outlined, size: 24 * u, color: const Color(0xFFFF8A2A)),
        Text(m.time, style: ts(u, 26, c: const Color(0xFFD9DFE6), w: FontWeight.w400, sh: const [])),
        if (mine && m.status == 'failed') ...[SizedBox(width: 8 * u), Icon(Icons.error_outline_rounded, size: 32 * u, color: const Color(0xFFFF6A5A)), SizedBox(width: 6 * u), Text('Failed · tap to retry', style: ts(u, 26, c: const Color(0xFFFF9A8F), w: FontWeight.w700, sh: const []))]
        else if (mine) ...[SizedBox(width: 8 * u), Icon(m.status == 'sent' ? Icons.done_rounded : Icons.done_all_rounded, size: 32 * u, color: m.status == 'read' ? const Color(0xFFFF6A1A) : const Color(0xFFC9D1DA))],
      ]),
    );
    final content = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [body, meta]);
    final bubble = Flexible(child: GestureDetector(onTap: m.deleted ? null : (mine && m.status == 'failed') ? () {
          if (!s.retry(m)) showToast(context, 'Still offline — check your connection');
        } : () => _actions(context, m, mine), child: _bubble(u, mine, content)));
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * u),
      child: Column(crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: mine ? [const SizedBox(width: 40), bubble, SizedBox(width: 12 * u), face] : [face, SizedBox(width: 12 * u), bubble, const SizedBox(width: 40)]),
        if (m.reactions.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: mine ? 0 : 130 * u, right: mine ? 130 * u : 0),
            child: Wrap(spacing: 8 * u, children: [for (final r in m.reactions) Tap(onTap: () => s.react(m, r), child: Container(padding: EdgeInsets.symmetric(horizontal: 18 * u, vertical: 4 * u), decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: const Color(0xFF1A140A), border: Border.all(color: const Color(0xFFC9A46A), width: 2.5 * u)), child: Text(r, style: TextStyle(fontSize: 26 * u, decoration: TextDecoration.none))))]),
          ),
      ]),
    );
  }

  Widget _body(BuildContext context, double u, Msg m, bool mine) {
    if (m.deleted) return Text('🚫 This message was deleted', style: ts(u, 32, w: FontWeight.w400));
    switch (m.type) {
      case MType.text:
        return Text(m.text ?? '', style: ts(u, 35, w: FontWeight.w400, h: 1.3, sh: const []));
      case MType.voice:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 104 * u, height: 104 * u, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0A0F2A), border: Border.all(color: const Color(0xFF3E63FF), width: 5 * u), boxShadow: [BoxShadow(color: const Color(0xFF3E63FF).withValues(alpha: .9), blurRadius: 14 * u)]), child: Icon(Icons.play_arrow_rounded, size: 56 * u, color: Colors.white)),
          SizedBox(width: 20 * u),
          for (var i = 0; i < 26; i++) Container(margin: EdgeInsets.symmetric(horizontal: 2.2 * u), width: 6 * u, height: (14 + ((i * 7) % 9) * 7) * u, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: i > 14 ? const Color(0x803E63FF) : const Color(0xFF3E63FF))),
          SizedBox(width: 18 * u),
          Text('${m.extra?['d'] ?? '0:08'}', style: ts(u, 32, w: FontWeight.w400)),
        ]);
      case MType.document:
        final ext = '${m.extra?['ext'] ?? ''}';
        return Row(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(borderRadius: BorderRadius.circular(22 * u), child: Image.asset('assets/images/doc-thumb.webp', width: 230 * u, height: 160 * u, fit: BoxFit.cover)),
          SizedBox(width: 22 * u),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (ext.startsWith('PPT')) Container(width: 62 * u, height: 70 * u, alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12 * u), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFF7A4A), Color(0xFFD9421A)])), child: Text('P', style: ts(u, 42, w: FontWeight.w900))) else Icon(Icons.description_outlined, size: 56 * u, color: const Color(0xFFFFB866)),
                SizedBox(width: 12 * u),
                Flexible(child: Text('${m.extra?['name']}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 30))),
              ]),
              Text('${m.extra?['size']} • $ext', style: ts(u, 27, c: const Color(0xFFCDD5DE), w: FontWeight.w400)),
              Align(alignment: Alignment.centerRight, child: GoldIcon(Icons.file_download_outlined, u: u, size: 84)),
            ]),
          ),
        ]);
      case MType.product:
        final p = products.firstWhere((x) => x.id == m.extra?['pid']);
        return Tap(
          onTap: () => pushScreen(context, ProductPage(p.id)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            ProdTile(u: u, p: p, w: 130, h: 120),
            SizedBox(width: 22 * u),
            Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, style: ts(u, 33, w: FontWeight.w800)), Text(money(p.price), style: ts(u, 34, w: FontWeight.w900, c: const Color(0xFFFFB02E))), Text('${p.avail} · ${people[p.seller]!.name}', style: ts(u, 24, c: const Color(0xFFCDD5DE), w: FontWeight.w400))])),
          ]),
        );
      case MType.offer:
        final p = products.firstWhere((x) => x.id == m.extra?['pid']);
        final st = '${m.extra?['state']}';
        final accepted = st == 'accepted';
        final exists = s.orders.any((o) => o.chat == m.chat && o.productId == p.id && o.unit == m.extra?['price']);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text('🏷 Your offer', style: ts(u, 32, w: FontWeight.w800)),
          Text(p.title, style: ts(u, 30, w: FontWeight.w400)),
          Text('${money(m.extra!['price'] as int)} × ${m.extra!['qty']}', style: ts(u, 38, w: FontWeight.w900)),
          SizedBox(height: 6 * u),
          Text(accepted ? '✓ Accepted' : '… Waiting for seller', style: ts(u, 28, w: FontWeight.w800, c: accepted ? const Color(0xFF8DFFB4) : const Color(0xFFFFE3B0))),
          if (accepted && mine && !exists)
            Padding(padding: EdgeInsets.only(top: 10 * u), child: ArtBtn(u: u, label: 'Create order', orange: true, minH: 110, fontPx: 34, expand: false, onTap: () => pushScreen(context, CreateOrderPage(p.id, m.chat, price: m.extra!['price'] as int, qty: m.extra!['qty'] as int)))),
        ]);
      case MType.order:
        final o = s.orders.firstWhere((x) => x.id == m.extra?['oid']);
        return Tap(
          onTap: () => pushScreen(context, OrderPage(o.id)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text('🛍 Order · ${o.title}', style: ts(u, 32, w: FontWeight.w800)),
            Text(money(o.total), style: ts(u, 36, w: FontWeight.w900)),
            Text('${o.status.replaceAll('_', ' ')} · ${o.paid ? 'paid' : 'unpaid'} →', style: ts(u, 27, w: FontWeight.w400)),
          ]),
        );
      default:
        return Text(m.text ?? '', style: ts(u, 35, w: FontWeight.w400));
    }
  }

  // ───────────────────────── composer
  Widget _composer(BuildContext context, double u) {
    final chat0 = s.chat(widget.chatId);
    final locked = chat0.group && chat0.announcement && !chat0.members.any((m) => m.$1 == 'me' && m.$2 != 'member');
    if (locked) {
      return FootBar(u: u, child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30 * u, vertical: 34 * u),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(34 * u), color: const Color(0xFF10161E), border: Border.all(color: const Color(0xFFAAB3BB), width: 4 * u)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_outline_rounded, size: 46 * u, color: const Color(0xFFFFB866)), SizedBox(width: 18 * u), Flexible(child: Text('Only admins can send messages', style: ts(u, 36, c: const Color(0xFFD3DBE4), w: FontWeight.w600, sh: const [])))]),
      ));
    }
    final w = u * 941;
    final k = w / 910;
    Widget at(double x, double y, double ww, double hh, Widget c) => Positioned(left: x * k, top: y * k, width: ww * k, height: hh * k, child: c);
    return FootBar(
      u: u,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_quote != null || _editing != null)
          Container(
            margin: EdgeInsets.only(bottom: 10 * u, left: 16 * u, right: 16 * u),
            padding: EdgeInsets.symmetric(horizontal: 24 * u, vertical: 14 * u),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(26 * u), color: const Color(0xFF0E2236), border: Border.all(color: const Color(0x66A0C8F0), width: 2.5 * u)),
            child: Row(children: [
              Expanded(child: Text(_editing != null ? 'Editing message' : 'Replying to $_quote', maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 28, c: const Color(0xFFCFE6F7), w: FontWeight.w400))),
              Tap(onTap: () => setState(() {
                _quote = null;
                if (_editing != null) _input.clear();
                _editing = null;
              }), child: Icon(Icons.close_rounded, size: 40 * u, color: Colors.white)),
            ]),
          ),
        SizedBox(
          width: w,
          height: 197 * k,
          child: Stack(children: [
            Positioned.fill(child: Image.asset('assets/images/chat-bar.webp', fit: BoxFit.fill)),
            at(33, 45, 90, 90, Tap(onTap: () => _share(context), child: Icon(Icons.attach_file_rounded, size: 46 * u, color: _g, shadows: _glow(u)))),
            at(154, 52, 390, 76, Center(child: TextField(controller: _input, onSubmitted: (_) => _send(), cursorColor: _g, style: TextStyle(color: Colors.white, fontSize: 36 * u), decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: 'Type a message...', hintStyle: TextStyle(color: const Color(0xFF8E9BAB), fontSize: 36 * u))))),
            at(549, 56, 64, 64, Tap(onTap: () => _input.text += '😊', child: Icon(Icons.emoji_emotions_outlined, size: 56 * u, color: _g, shadows: _glow(u)))),
            at(654, 52, 68, 76, Tap(onTap: () => s.send(widget.chatId, MType.voice, x: {'d': '0:06'}), child: Icon(Icons.mic_none_rounded, size: 52 * u, color: Colors.white))),
            at(765, 42, 96, 96, Tap(onTap: _send, child: Icon(Icons.send_rounded, size: 50 * u, color: _g, shadows: _glow(u)))),
          ]),
        ),
      ]),
    );
  }

  static const _g = Color(0xFFFFB866);
  List<Shadow> _glow(double u) => [Shadow(color: const Color(0xE6FF8C1E), blurRadius: 10 * u)];

  // ───────────────────────── sheets
  void _actions(BuildContext context, Msg m, bool mine) {
    final u = context.u;
    showArtSheet(context, (c) {
      Widget ring(String asset, double size, Widget child, VoidCallback f) => Tap(onTap: () {
            Navigator.pop(c);
            f();
          }, child: SizedBox(width: size * u, height: size * u, child: Stack(alignment: Alignment.center, children: [Positioned.fill(child: Image.asset('assets/images/$asset.webp', fit: BoxFit.fill)), child])));
      Widget act(String l, IconData ic, VoidCallback f, {bool red = false}) => ring(red ? 'ring63-red' : 'ring63-act', 196, Column(mainAxisSize: MainAxisSize.min, children: [Icon(ic, size: 66 * u, color: Colors.white), Text(l, style: ts(u, 38, w: FontWeight.w800))]), f);
      return Container(
        margin: EdgeInsets.all(12 * u),
        padding: EdgeInsets.fromLTRB(28 * u, 26 * u, 28 * u, 26 * u),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(44 * u),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF232A33), Color(0xFF11151B), Color(0xFF0A0D11)]),
          border: Border.all(color: const Color(0xFFC3CBD2), width: 6 * u),
          boxShadow: [BoxShadow(color: const Color(0xFFFF821E).withValues(alpha: .45), blurRadius: 34 * u)],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [for (final e in _emoji) ring('ring63-emoji', 134, Text(e, style: TextStyle(fontSize: 62 * u, decoration: TextDecoration.none)), () => s.react(m, e))]),
          Container(height: 5 * u, margin: EdgeInsets.symmetric(vertical: 18 * u), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0x00FF6A1A), Color(0xFFFF6A1A), Color(0xFFFFE0B8), Color(0xFFFF6A1A), Color(0x00FF6A1A)]), boxShadow: [BoxShadow(color: const Color(0xFFFF7A1A), blurRadius: 12 * u)])),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            act('Reply', Icons.sentiment_satisfied_alt_outlined, () => setState(() => _quote = (m.text ?? m.type.name).split('\n').last)),
            act(m.pinned ? 'Unpin' : 'Pin', Icons.push_pin_outlined, () => s.togglePin(m)),
            act('Star', Icons.star_border_rounded, () => showToast(context, 'Starred')),
            if (!m.deleted) act('Delete', Icons.delete_outline_rounded, () async {
              if (await confirmDialog(context, title: 'Delete message?', text: mine ? 'Deletes the message for everyone in the chat.' : 'Removes the message from your view.')) s.remove(m);
            }, red: true),
          ]),
          if (!m.deleted)
            Padding(
              padding: EdgeInsets.only(top: 14 * u),
              child: Wrap(alignment: WrapAlignment.center, spacing: 14 * u, children: [
                Tap(onTap: () {
                  Navigator.pop(c);
                  showToast(context, 'Forward opens a picker (prototype)');
                }, child: _pillBtn(u, Icons.forward_rounded, 'Forward')),
                if (mine && m.type == MType.text) Tap(onTap: () {
                  Navigator.pop(c);
                  setState(() {
                    _editing = m;
                    _input.text = m.text ?? '';
                  });
                }, child: _pillBtn(u, Icons.edit_outlined, 'Edit')),
              ]),
            ),
          if (m.text != null)
            Padding(
              padding: EdgeInsets.only(top: 14 * u),
              child: Center(child: SizedBox(width: 460 * u, child: ArtBtn(u: u, label: 'Copy', icon: Icons.copy_rounded, minH: 150, fontPx: 40, onTap: () {
                Navigator.pop(c);
                Clipboard.setData(ClipboardData(text: m.text!));
                showToast(context, 'Copied');
              }))),
            ),
        ]),
      );
    });
  }

  Widget _pillBtn(double u, IconData ic, String l) => Container(
        padding: EdgeInsets.symmetric(horizontal: 34 * u, vertical: 16 * u),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0xFFAAB3BB), width: 4 * u), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2B3A4D), Color(0xFF0A1018)])),
        child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(ic, size: 44 * u, color: Colors.white), SizedBox(width: 12 * u), Text(l, style: ts(u, 34, w: FontWeight.w700))]),
      );

  void _headerMenu() {
    final chat = s.chat(widget.chatId);
    if (chat.anon) {
      showActions(context, title: chat.title, items: [
        if (chat.userId != null) ActItem('View public key', Icons.key_rounded, () => pushScreen(context, AnonKeyPage(chat.userId!))),
        ActItem('Report', Icons.flag_outlined, () => showToast(context, 'Report submitted')),
        ActItem('Block', Icons.block_rounded, () {
          showToast(context, 'Identity blocked');
          Navigator.of(context).maybePop();
        }, danger: true),
        ActItem('Exit conversation', Icons.logout_rounded, () => Navigator.of(context).maybePop(), danger: true),
      ]);
      return;
    }
    showActions(context, title: chat.title, items: [
      ActItem('View info', Icons.info_outline_rounded, () => pushScreen(context, ChatInfoPage(widget.chatId))),
      if (!chat.group && !chat.private && chat.userId != null)
        ActItem('Continue privately', Icons.lock_outline_rounded, () {
          showToast(context, 'Continuing in your private conversation');
          pushScreen(context, ConversationPage(s.openOrCreate(chat.userId!, private: true).id));
        }),
      ActItem('Search in chat', Icons.search_rounded, () => pushScreen(context, ChatSearchPage(widget.chatId))),
      ActItem(chat.muted ? 'Unmute' : 'Mute', chat.muted ? Icons.notifications_none_rounded : Icons.notifications_off_outlined, () {
        s.toggleMuteChat(chat);
        showToast(context, chat.muted ? 'Muted' : 'Unmuted');
      }),
      ActItem('Delete conversation', Icons.delete_outline_rounded, () async {
        if (await confirmDialog(context, title: 'Delete conversation?', text: chat.group ? 'Removes the group from your list only.' : 'Removes it from your chat list only.') && mounted) {
          s.deleteChat(chat);
          Navigator.of(context).maybePop();
        }
      }, danger: true),
    ]);
  }

  void _share(BuildContext context) {
    final u = context.u;
    showArtSheet(context, (c) {
      Widget item(String l, Widget icon, VoidCallback f) => Tap(
            onTap: () {
              Navigator.pop(c);
              f();
            },
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(width: 250 * u, height: 250 * u, child: Stack(alignment: Alignment.center, children: [Positioned.fill(child: Image.asset('assets/images/share-ring.webp', fit: BoxFit.fill)), IconTheme(data: IconThemeData(size: 100 * u, color: const Color(0xFFF4E6D2)), child: icon)])),
              Text(l, style: ts(u, 33, w: FontWeight.w500)),
            ]),
          );
      return Container(
        margin: EdgeInsets.all(12 * u),
        padding: EdgeInsets.fromLTRB(20 * u, 34 * u, 20 * u, 22 * u),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(44 * u), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF151A21), Color(0xFF0A0D12)]), border: Border.all(color: const Color(0xFFC3CBD2), width: 6 * u), boxShadow: [BoxShadow(color: const Color(0xFFFF821E).withValues(alpha: .4), blurRadius: 36 * u)]),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Wrap(alignment: WrapAlignment.center, spacing: 6 * u, runSpacing: 10 * u, children: [
            item('Gallery', const Icon(Icons.image_outlined), () => s.send(widget.chatId, MType.text, text: '📷 Photo')),
            item('Camera', const Icon(Icons.photo_camera_outlined), () => s.send(widget.chatId, MType.text, text: '📷 Camera photo')),
            item('Document', const Icon(Icons.description_outlined), () => s.send(widget.chatId, MType.document, x: {'name': 'Notes.pdf', 'size': '1.2 MB', 'ext': 'PDF'})),
            item('Location', const Icon(Icons.location_on_outlined), () => s.send(widget.chatId, MType.text, text: '📍 Current location · Kathmandu')),
            item('Contact', const Icon(Icons.person_outline_rounded), () => s.send(widget.chatId, MType.text, text: '👤 Sita Rai · +977 9801 234 567')),
            item('Product', const Icon(Icons.add_shopping_cart_rounded), () => _pickProduct(context)),
          ]),
          if (s.chat(widget.chatId).userId != null)
            Padding(padding: EdgeInsets.only(top: 10 * u), child: ArtBtn(u: u, label: 'Make an offer', icon: Icons.sell_outlined, minH: 110, fontPx: 36, onTap: () {
              Navigator.pop(c);
              pushScreen(context, OfferPage(widget.chatId));
            })),
        ]),
      );
    });
  }

  void _pickProduct(BuildContext context) {
    final u = context.u;
    showArtSheet(context, (c) => Container(
          margin: EdgeInsets.all(12 * u),
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .72),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40 * u), gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1B2028), Color(0xFF0A0D12)]), border: Border.all(color: const Color(0xFFC3CBD2), width: 6 * u), boxShadow: [BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .4), blurRadius: 26 * u)]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(padding: EdgeInsets.symmetric(vertical: 26 * u), child: Text('Share a product', style: ts(u, 46, w: FontWeight.w800))),
            Flexible(
              child: ListView(shrinkWrap: true, padding: EdgeInsets.fromLTRB(26 * u, 0, 26 * u, 26 * u), children: [
                for (final p in products)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4 * u),
                    child: Tap(
                      onTap: () {
                        Navigator.pop(c);
                        s.send(widget.chatId, MType.product, x: {'pid': p.id});
                      },
                      child: Nine('chat-bubble', px: sizeBubble, slice: 38, u: u, pad: EdgeInsets.symmetric(horizontal: 30 * u, vertical: 26 * u), child: Row(children: [
                        ProdTile(u: u, p: p, w: 92, h: 92),
                        SizedBox(width: 24 * u),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 35, w: FontWeight.w700)), Text(money(p.price), style: ts(u, 34, w: FontWeight.w900, c: const Color(0xFFFFB02E)))])),
                      ])),
                    ),
                  ),
              ]),
            ),
          ]),
        ));
  }
}

class NotificationsLazy extends StatelessWidget {
  const NotificationsLazy({super.key});
  @override
  Widget build(BuildContext context) => const NotificationsPage();
}
