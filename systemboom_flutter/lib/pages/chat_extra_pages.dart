import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'chat_page.dart';
import 'order_page.dart';

String _txt(Msg m) => m.text ?? (m.extra?['name'] as String?) ?? m.type.name;

/// Search inside one conversation.
class ChatSearchPage extends StatefulWidget {
  const ChatSearchPage(this.chatId, {super.key});
  final String chatId;
  @override
  State<ChatSearchPage> createState() => _ChatSearchPageState();
}

class _ChatSearchPageState extends State<ChatSearchPage> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final s = Store.i;
    final res = q.trim().isEmpty ? <Msg>[] : s.thread(widget.chatId).where((m) => !m.deleted && m.type != MType.system && _txt(m).toLowerCase().contains(q.trim().toLowerCase())).toList();
    return PageShell(
      title: 'Search chat',
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      searchHint: 'Search this conversation',
      onSearch: (v) => setState(() => q = v),
      children: [
        if (q.trim().isEmpty) _empty(u, Icons.search_rounded, 'Search messages', 'Find messages, media, documents and links in this conversation.')
        else if (res.isEmpty) _empty(u, Icons.search_off_rounded, 'No results', 'Nothing matches “$q”.')
        else ...[
          Padding(padding: EdgeInsets.only(bottom: 12 * u), child: Text('${res.length} result${res.length > 1 ? 's' : ''}', style: ts(u, 30, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))),
          for (final m in res)
            SteelPlate(u: u, onTap: () => Navigator.of(context).maybePop(), child: Row(children: [
              Face(u: u, person: s.person(m.from), size: 90),
              SizedBox(width: 22 * u),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.from == 'me' ? 'You' : s.person(m.from).name, style: ts(u, 38, w: FontWeight.w800)), Text('${m.time} · ${_txt(m)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 30, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
            ])),
        ],
      ],
    );
  }
}

Widget _empty(double u, IconData ic, String t, String sub) => Padding(
      padding: EdgeInsets.all(50 * u),
      child: Column(children: [GoldIcon(ic, u: u, size: 150), SizedBox(height: 22 * u), Text(t, style: ts(u, 42, w: FontWeight.w800)), SizedBox(height: 10 * u), Text(sub, textAlign: TextAlign.center, style: ts(u, 32, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))]),
    );

/// Pinned messages with unpin.
class ChatPinnedPage extends StatefulWidget {
  const ChatPinnedPage(this.chatId, {super.key});
  final String chatId;
  @override
  State<ChatPinnedPage> createState() => _ChatPinnedPageState();
}

class _ChatPinnedPageState extends State<ChatPinnedPage> {
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final s = Store.i;
    final pinned = s.thread(widget.chatId).where((m) => m.pinned && !m.deleted).toList();
    return PageShell(
      title: 'Pinned messages',
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      children: [
        if (pinned.isEmpty) _empty(u, Icons.push_pin_outlined, 'No pinned messages', 'Tap any message and choose Pin to keep it here for quick access.'),
        for (final m in pinned)
          SteelPlate(u: u, child: Row(children: [
            GoldIcon(Icons.push_pin_outlined, u: u, size: 88),
            SizedBox(width: 22 * u),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(m.from == 'me' ? 'You' : s.person(m.from).name, style: ts(u, 38, w: FontWeight.w800)), Text(_txt(m), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 30, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
            Tap(onTap: () {
              s.togglePin(m);
              showToast(context, 'Unpinned');
              setState(() {});
            }, child: Icon(Icons.push_pin_rounded, size: 56 * u, color: const Color(0xFFFFB866))),
          ])),
      ],
    );
  }
}

/// Media / docs / links for a conversation.
class ChatMediaPage extends StatefulWidget {
  const ChatMediaPage(this.chatId, {super.key});
  final String chatId;
  @override
  State<ChatMediaPage> createState() => _ChatMediaPageState();
}

class _ChatMediaPageState extends State<ChatMediaPage> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final docs = Store.i.thread(widget.chatId).where((m) => m.type == MType.document).toList();
    return PageShell(
      title: 'Media, links & docs',
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      tabs: ['Media 0', 'Docs ${docs.length}', 'Links 0'],
      tab: tab,
      onTab: (i) => setState(() => tab = i),
      children: [
        if (tab == 1 && docs.isNotEmpty)
          for (final m in docs) SteelPlate(u: u, child: Row(children: [GoldIcon(Icons.description_outlined, u: u, size: 88), SizedBox(width: 22 * u), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${m.extra?['name']}', style: ts(u, 38, w: FontWeight.w800)), Text('${m.extra?['ext']} · ${m.extra?['size']} · ${m.time}', style: ts(u, 30, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))]))]))
        else
          _empty(u, tab == 0 ? Icons.image_outlined : tab == 1 ? Icons.description_outlined : Icons.link_rounded, tab == 0 ? 'No media yet' : tab == 1 ? 'No documents' : 'No links', 'Items shared in this chat will appear here.'),
      ],
    );
  }
}

/// Pre-creation state of a direct chat: pick Standard / Private, then say hello.
class DraftChatPage extends StatefulWidget {
  const DraftChatPage(this.userId, {super.key, this.privateIntent = false});
  final String userId;
  final bool privateIntent;
  @override
  State<DraftChatPage> createState() => _DraftChatPageState();
}

class _DraftChatPageState extends State<DraftChatPage> {
  late bool priv = widget.privateIntent;
  final _t = TextEditingController();
  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  void _send() {
    final t = _t.text.trim();
    if (t.isEmpty) return;
    final c = Store.i.openOrCreate(widget.userId, private: priv);
    Store.i.send(c.id, MType.text, text: t);
    Navigator.of(context).pushReplacement(PageRouteBuilder<void>(pageBuilder: (_, _, _) => ConversationPage(c.id), transitionDuration: const Duration(milliseconds: 600), transitionsBuilder: (_, a, _, ch) => FadeTransition(opacity: a, child: ch)));
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final p = Store.i.person(widget.userId);
    Widget opt(String l, String desc, IconData ic, bool on, VoidCallback f) => Padding(
          padding: EdgeInsets.only(bottom: 12 * u),
          child: SteelPlate(u: u, onTap: () => setState(f), margin: EdgeInsets.zero, child: Row(children: [
            GoldIcon(ic, u: u, size: 88),
            SizedBox(width: 24 * u),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: ts(u, 42, w: FontWeight.w800)), Text(desc, style: ts(u, 30, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
            Container(width: 52 * u, height: 52 * u, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: on ? const Color(0xFFFF9A3A) : const Color(0xFF8B949D), width: 5 * u), color: on ? const Color(0xFFFF9A3A) : Colors.transparent)),
          ])),
        );
    return PageShell(
      title: p.name,
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      bottomPad: 330,
      footer: FootBar(u: u, child: Row(children: [
        Expanded(child: GlassWell(u: u, radius: 60, pad: EdgeInsets.symmetric(horizontal: 34 * u, vertical: 20 * u), child: TextField(controller: _t, onSubmitted: (_) => _send(), cursorColor: const Color(0xFFFFB866), style: TextStyle(color: Colors.white, fontSize: 36 * u), decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: priv ? 'Private message' : 'Message', hintStyle: TextStyle(color: const Color(0xFF8896A6), fontSize: 36 * u))))),
        SizedBox(width: 14 * u),
        RoundBtn(u: u, icon: Icons.send_rounded, hot: true, onTap: _send),
      ])),
      children: [
        Center(child: Face(u: u, person: p, size: 200, online: p.online)),
        Center(child: Padding(padding: EdgeInsets.only(top: 14 * u, bottom: 28 * u), child: Text('Choose how this conversation is protected, then say hello.', textAlign: TextAlign.center, style: ts(u, 32, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const [])))),
        opt('Standard', 'Secured in transit and at rest', Icons.chat_bubble_outline_rounded, !priv, () => priv = false),
        opt('Private', 'End-to-end encrypted — only participants’ devices can read it', Icons.lock_outline_rounded, priv, () => priv = true),
        Center(child: Text('Privacy type can’t be changed after this conversation starts.', textAlign: TextAlign.center, style: ts(u, 28, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))),
      ],
    );
  }
}

/// Anonymous: public key details (verify / block / report).
class AnonKeyPage extends StatefulWidget {
  const AnonKeyPage(this.id, {super.key});
  final String id;
  @override
  State<AnonKeyPage> createState() => _AnonKeyPageState();
}

class _AnonKeyPageState extends State<AnonKeyPage> {
  bool verified = false;
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final s = Store.i;
    final own = widget.id == 'anon-me' ? s.me : s.identities.where((a) => a.id == widget.id).cast<AnonId?>().firstOrNull;
    final self = own != null;
    final person = s.person(widget.id);
    final name = own?.name ?? person.name;
    final key = own?.key ?? _hexKey(widget.id);
    final fp = own?.fingerprint ?? [for (var i = 0; i < 32; i += 4) key.substring(i, i + 4)].join(' ');
    return PageShell(
      title: 'Public key',
      active: 'home',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      children: [
        Center(child: Face(u: u, person: Person('k', name), size: 200, tint: const Color(0xFF14A09A))),
        Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 14 * u), child: Text(name, style: ts(u, 52, w: FontWeight.w900)))),
        if (verified) Center(child: Text('✓ Verified', style: ts(u, 34, c: const Color(0xFF35D07F), w: FontWeight.w800))),
        OLabel('Safety number (fingerprint)', u: u),
        SteelPlate(u: u, child: Center(child: Text(fp, style: ts(u, 32, c: const Color(0xFFFFD9A0), w: FontWeight.w400, sh: const [])))),
        if (!self) ArtBtn(u: u, label: verified ? 'Verified' : 'Mark as verified', icon: verified ? Icons.check_rounded : Icons.fingerprint_rounded, orange: !verified, minH: 130, fontPx: 40, onTap: () {
          setState(() => verified = !verified);
          showToast(context, verified ? 'Marked verified' : 'Marked unverified');
        }),
        OLabel('Public key', u: u),
        SteelPlate(u: u, child: Text(key, style: ts(u, 25, c: const Color(0xFFB6FFF4), w: FontWeight.w400, sh: const []))),
        SizedBox(height: 14 * u),
        ArtBtn(u: u, label: 'Copy public key', icon: Icons.copy_rounded, minH: 130, fontPx: 40, onTap: () {
          Clipboard.setData(ClipboardData(text: key));
          showToast(context, 'Public key copied');
        }),
        if (!self) ...[
          SizedBox(height: 20 * u),
          Row(children: [
            Expanded(child: ArtBtn(u: u, label: 'Block', icon: Icons.block_rounded, minH: 120, fontPx: 36, onTap: () => showToast(context, '$name blocked'))),
            SizedBox(width: 10 * u),
            Expanded(child: ArtBtn(u: u, label: 'Report', icon: Icons.flag_outlined, minH: 120, fontPx: 36, onTap: () => showToast(context, 'Report submitted'))),
          ]),
        ],
      ],
    );
  }

  String _hexKey(String seed) {
    var h = 2166136261;
    final b = StringBuffer();
    for (var i = 0; i < 64; i++) {
      h ^= seed.codeUnitAt(i % seed.length) + i * 131;
      h = (h * 16777619) & 0xFFFFFFFF;
      b.write('0123456789ABCDEF'[(h >> (i % 24)) & 15]);
    }
    return b.toString();
  }
}

/// Anonymous: full list with search.
class AnonChatsPage extends StatefulWidget {
  const AnonChatsPage({super.key});
  @override
  State<AnonChatsPage> createState() => _AnonChatsPageState();
}

class _AnonChatsPageState extends State<AnonChatsPage> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final s = Store.i;
    final list = s.chats.where((c) => c.anon && c.title.toLowerCase().contains(q.trim().toLowerCase())).toList();
    return PageShell(
      title: 'Anonymous chats',
      active: 'home',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      searchHint: 'Search anonymous chats',
      onSearch: (v) => setState(() => q = v),
      children: [
        if (list.isEmpty) _empty(u, Icons.qr_code_scanner_rounded, q.isEmpty ? 'No anonymous chats yet' : 'No matches', 'Scan a QR code to connect with someone privately.'),
        for (final c in list)
          SteelPlate(u: u, onTap: () => pushScreen(context, ConversationPage(c.id)).then((_) => setState(() {})), child: Row(children: [
            Face(u: u, person: c.group ? Person(c.id, c.title) : s.person(c.userId), size: 104, tint: const Color(0xFF14A09A)),
            SizedBox(width: 24 * u),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(c.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 42, w: FontWeight.w800)), Text(s.last(c.id)?.text ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
            Icon(Icons.chevron_right_rounded, size: 52 * u, color: const Color(0xFFE8EDF1)),
          ])),
      ],
    );
  }
}

/// Create order: quantity + delivery address, then straight to the order/pay screen.
class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage(this.productId, this.chatId, {super.key, this.price, this.qty = 1});
  final String productId;
  final String chatId;
  final int? price;
  final int qty;
  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  late int qty = widget.qty;
  final _addr = TextEditingController(text: 'Baneshwor, Kathmandu 44600');
  @override
  void dispose() {
    _addr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final p = products.firstWhere((x) => x.id == widget.productId);
    final unit = widget.price ?? p.price;
    final total = unit * qty + 150;
    return PageShell(
      title: 'Create order',
      active: 'market',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 400,
      footer: FootBar(u: u, child: ArtBtn(u: u, label: 'Place order · ${money(total)}', orange: true, minH: 190, fontPx: 56, onTap: () {
        final o = Store.i.createOrder(widget.chatId, p, unit, qty);
        Navigator.of(context).pushReplacement(PageRouteBuilder<void>(pageBuilder: (_, _, _) => OrderPage(o.id), transitionDuration: const Duration(milliseconds: 600), transitionsBuilder: (_, a, _, ch) => FadeTransition(opacity: a, child: ch)));
      })),
      children: [
        SteelPlate(u: u, child: Row(children: [ProdTile(u: u, p: p), SizedBox(width: 26 * u), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, style: ts(u, 42, w: FontWeight.w800)), Text(money(unit), style: ts(u, 36, c: const Color(0xFFFFB02E), w: FontWeight.w700))]))])),
        OLabel('Quantity', u: u),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          RoundBtn(u: u, icon: Icons.remove_rounded, onTap: () => setState(() => qty = qty > 1 ? qty - 1 : 1)),
          SizedBox(width: 34 * u),
          SizedBox(width: 250 * u, child: GlassWell(u: u, pad: EdgeInsets.symmetric(vertical: 14 * u), child: Center(child: Text('$qty', style: ts(u, 84, w: FontWeight.w900))))),
          SizedBox(width: 34 * u),
          RoundBtn(u: u, icon: Icons.add_rounded, hot: true, onTap: () => setState(() => qty++)),
        ]),
        OLabel('Delivery address', u: u),
        GlassWell(u: u, child: TextField(controller: _addr, maxLines: 2, cursorColor: const Color(0xFFFFB02E), style: TextStyle(fontSize: 40 * u, color: Colors.white), decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true))),
        SizedBox(height: 26 * u),
        SteelPlate(u: u, pad: EdgeInsets.fromLTRB(54 * u, 36 * u, 54 * u, 30 * u), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Subtotal ($qty item${qty > 1 ? 's' : ''})', style: ts(u, 40, w: FontWeight.w400, sh: const [])), Text(money(unit * qty), style: ts(u, 40, w: FontWeight.w400, sh: const []))]),
          SizedBox(height: 10 * u),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Delivery', style: ts(u, 40, w: FontWeight.w400, sh: const [])), Text(money(150), style: ts(u, 40, w: FontWeight.w400, sh: const []))]),
          SizedBox(height: 16 * u),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: ts(u, 52, w: FontWeight.w900)), Text(money(total), style: ts(u, 52, w: FontWeight.w900, c: const Color(0xFFFFB02E)))]),
        ])),
      ],
    );
  }
}

/// Delivery tracking timeline.
class OrderTrackPage extends StatefulWidget {
  const OrderTrackPage(this.orderId, {super.key});
  final String orderId;
  @override
  State<OrderTrackPage> createState() => _OrderTrackPageState();
}

class _OrderTrackPageState extends State<OrderTrackPage> {
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
    final o = s.orders.firstWhere((x) => x.id == widget.orderId);
    const order = ['pending_payment', 'confirmed', 'shipped', 'out_for_delivery', 'delivered', 'completed'];
    const steps = [('confirmed', 'Order confirmed'), ('shipped', 'Shipped'), ('out_for_delivery', 'Out for delivery'), ('delivered', 'Delivered')];
    final idx = order.indexOf(o.status);
    return PageShell(
      title: 'Delivery tracking',
      active: 'market',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      children: [
        Container(height: 300 * u, decoration: BoxDecoration(borderRadius: BorderRadius.circular(34 * u), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2D688F), Color(0xFF12303F)]), border: Border.all(color: const Color(0xFFAAB3BB), width: 5 * u)), child: Stack(alignment: Alignment.center, children: [Icon(Icons.local_shipping_outlined, size: 120 * u, color: Colors.white), Positioned(bottom: 24 * u, child: StatusArt(u: u, text: statusLabel(o.status), color: statusColor(o.status)))])),
        SizedBox(height: 20 * u),
        SteelPlate(u: u, child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Courier', style: ts(u, 34, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const [])), Text('Boom Express', style: ts(u, 38, w: FontWeight.w800))]),
          SizedBox(height: 10 * u),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Tracking code', style: ts(u, 34, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const [])), Text('SB7731NP', style: ts(u, 38, w: FontWeight.w800))]),
        ])),
        OLabel('Progress', u: u),
        SteelPlate(u: u, child: Column(children: [
          for (final st in steps)
            Padding(padding: EdgeInsets.symmetric(vertical: 14 * u), child: Row(children: [
              Container(width: 54 * u, height: 54 * u, decoration: BoxDecoration(shape: BoxShape.circle, color: idx >= order.indexOf(st.$1) ? const Color(0xFFE5560A) : const Color(0xFF0A0F15), border: Border.all(color: idx >= order.indexOf(st.$1) ? const Color(0xFFFFD9A0) : const Color(0xFF4A5560), width: 4 * u)), child: Icon(Icons.check_rounded, size: 32 * u, color: Colors.white)),
              SizedBox(width: 24 * u),
              Text(st.$2, style: ts(u, 40, w: FontWeight.w800)),
            ])),
        ])),
        SizedBox(height: 24 * u),
        ArtBtn(u: u, label: 'Message seller', icon: Icons.chat_bubble_outline_rounded, minH: 130, fontPx: 40, onTap: () => pushScreen(context, ConversationPage(o.chat))),
        if (o.status == 'delivered' && !o.reviewed) ...[SizedBox(height: 14 * u), ArtBtn(u: u, label: 'Leave a review', icon: Icons.star_rounded, orange: true, minH: 130, fontPx: 40, onTap: () => pushScreen(context, OrderReviewPage(o.id)))],
      ],
    );
  }
}

/// Seller + product rating with feedback.
class OrderReviewPage extends StatefulWidget {
  const OrderReviewPage(this.orderId, {super.key});
  final String orderId;
  @override
  State<OrderReviewPage> createState() => _OrderReviewPageState();
}

class _OrderReviewPageState extends State<OrderReviewPage> {
  int sr = 5, pr = 5;
  final _t = TextEditingController();
  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  Widget _stars(double u, int v, ValueChanged<int> f) => Row(mainAxisSize: MainAxisSize.min, children: [for (var i = 1; i <= 5; i++) Tap(onTap: () => setState(() => f(i)), child: Icon(Icons.star_rounded, size: 66 * u, color: i <= v ? const Color(0xFFFFC24A) : const Color(0xFF4A5560)))]);

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final o = Store.i.orders.firstWhere((x) => x.id == widget.orderId);
    return PageShell(
      title: 'Leave a review',
      active: 'market',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 400,
      footer: FootBar(u: u, child: ArtBtn(u: u, label: 'Submit review', orange: true, minH: 190, fontPx: 58, onTap: () {
        Store.i.review(o);
        showToast(context, 'Thanks for your review');
        Navigator.of(context).popUntil((r) => r.isFirst);
      })),
      children: [
        Center(child: GoldIcon(Icons.inventory_2_outlined, u: u, size: 150)),
        Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 14 * u), child: Text('How was your order?', style: ts(u, 48, w: FontWeight.w800)))),
        Center(child: Text(o.title, style: ts(u, 34, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))),
        SizedBox(height: 26 * u),
        SteelPlate(u: u, pad: EdgeInsets.fromLTRB(54 * u, 36 * u, 54 * u, 36 * u), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Rate Boom Store', style: ts(u, 38, w: FontWeight.w800)), _stars(u, sr, (v) => sr = v)]),
          SizedBox(height: 24 * u),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Rate the product', style: ts(u, 38, w: FontWeight.w800)), _stars(u, pr, (v) => pr = v)]),
        ])),
        OLabel('Your feedback (optional)', u: u),
        GlassWell(u: u, child: SizedBox(height: 200 * u, child: TextField(controller: _t, maxLines: null, cursorColor: const Color(0xFFFFB02E), style: TextStyle(fontSize: 38 * u, color: Colors.white), decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: 'Share what you liked…', hintStyle: TextStyle(color: const Color(0xFF8896A6), fontSize: 38 * u))))),
      ],
    );
  }
}
