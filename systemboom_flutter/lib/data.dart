import 'dart:async';

import 'package:flutter/foundation.dart';

/// Demo data + tiny in-memory store (mirrors the Next.js version's mock store).
class Person {
  const Person(this.id, this.name, {this.about, this.online = false, this.business = false, this.verified = false, this.photo});
  final String id;
  final String name;
  final String? about;
  final bool online;
  final bool business;
  final bool verified;
  final String? photo;
  String get initials => name.split(' ').map((w) => w.isEmpty ? '' : w[0]).take(2).join().toUpperCase();
}

const people = <String, Person>{
  'me': Person('me', 'Aarav Sharma', about: 'Building calm software.', online: true, verified: true, photo: 'me'),
  'sita': Person('sita', 'Sita Rai', about: 'Designer @ SYSTEMBOOM', online: true, photo: 'cf1'),
  'bibek': Person('bibek', 'Bibek Thapa', about: 'Coffee & code', photo: 'cf5'),
  'anita': Person('anita', 'Anita Gurung', about: 'Travel a lot ✈️', photo: 'cf4'),
  'maya': Person('maya', 'Maya Karki', online: true, photo: 'cf4'),
  'boom': Person('boom', 'Boom Store', about: 'Official SYSTEMBOOM merchandise', online: true, business: true, verified: true),
};

enum MType { text, image, voice, document, product, offer, order, system }

class Msg {
  Msg(this.id, this.chat, this.from, this.type, this.time, {this.text, this.status = 'read', this.reactions = const [], this.pinned = false, this.deleted = false, this.extra});
  final String id;
  final String chat;
  final String from;
  final MType type;
  final String time;
  String? text;
  String status;
  List<String> reactions;
  bool pinned;
  bool deleted;
  Map<String, Object?>? extra;
}

class Chat {
  Chat(this.id, this.title, {this.userId, this.group = false, this.unread = 0, this.private = false, this.muted = false, this.pinned = false, this.archived = false});
  final String id;
  final String title;
  final String? userId;
  final bool group;
  final bool private;
  int unread;
  bool muted;
  bool pinned;
  bool archived;
}

class Product {
  const Product(this.id, this.title, this.price, this.cat, this.seller, this.avail, this.rating, this.reviews, this.desc, this.tint);
  final String id;
  final String title;
  final int price;
  final String cat;
  final String seller;
  final String avail;
  final double rating;
  final int reviews;
  final String desc;
  final int tint;
  String? get photo => id == 'deskmat' ? 'photo-deskmat' : null;
}

const products = <Product>[
  Product('deskmat', 'SYSTEMBOOM Desk Mat — Large', 2400, 'Home', 'boom', 'In stock', 4.8, 126, 'Natural cork base with stitched edges. A calm, premium surface for your desk. 900 × 400 mm.', 0xFFE5560A),
  Product('buds', 'SYSTEMBOOM Wireless Buds', 6900, 'Tech', 'boom', 'In stock', 4.6, 210, 'Active noise cancellation, 32-hour battery, and a featherlight fit. Tuned for calls and calm listening.', 0xFF7C5CFF),
  Product('tote', 'SYSTEMBOOM Canvas Tote', 1200, 'Apparel', 'boom', 'In stock', 4.6, 84, 'Heavyweight organic cotton with an internal pocket. Everyday carry, quietly branded.', 0xFF1EA7A0),
  Product('bottle', 'Insulated Steel Bottle', 1800, 'Home', 'boom', 'Low stock', 4.7, 52, 'Keeps drinks cold 24h / hot 12h. Powder-coated, leak-proof, 750 ml.', 0xFF3B82F6),
  Product('scarf', 'Handwoven Pashmina Scarf', 3200, 'Craft', 'boom', 'In stock', 5.0, 61, 'Ethically sourced cashmere, handwoven by artisans in Kathmandu. Soft, warm, timeless.', 0xFFD94F8A),
  Product('hoodie', 'Everest Wool Hoodie', 4500, 'Apparel', 'boom', 'Made to order', 4.9, 38, 'Merino-blend, brushed interior, made to your size in 7–10 days.', 0xFF6D8F2F),
  Product('lamp', 'Walnut Desk Lamp', 5200, 'Home', 'boom', 'In stock', 4.5, 22, 'Solid walnut with a warm dimmable LED. Hand-finished, one at a time.', 0xFFC28A1A),
  Product('journal', 'Handbound Journal', 900, 'Craft', 'boom', 'In stock', 4.8, 73, 'Lokta paper, hand-stitched binding. 180 pages, lays flat.', 0xFF8B949D),
];

class Order {
  Order(this.id, this.chat, this.productId, this.title, this.unit, this.qty, this.fee, {this.status = 'pending_payment', this.paid = false, this.method = '', this.reviewed = false});
  final String id;
  final String chat;
  final String productId;
  final String title;
  final int unit;
  final int qty;
  final int fee;
  String status;
  bool paid;
  String method;
  bool reviewed;
  int get sub => unit * qty;
  int get total => sub + fee;
}

class Notif {
  Notif(this.id, this.kind, this.title, this.body, this.time, {this.read = false, this.chat});
  final String id;
  final String kind;
  final String title;
  final String body;
  final String time;
  bool read;
  final String? chat;
}

String money(num n) {
  final s = n.round().toString();
  if (s.length <= 3) return 'Rs $s';
  final last = s.substring(s.length - 3);
  var rest = s.substring(0, s.length - 3);
  final b = StringBuffer();
  for (var i = 0; i < rest.length; i++) {
    if (i > 0 && (rest.length - i) % 2 == 0) b.write(',');
    b.write(rest[i]);
  }
  return 'Rs $b,$last';
}

class Store extends ChangeNotifier {
  Store._() {
    _seed();
  }
  static final Store i = Store._();

  final chats = <Chat>[];
  final msgs = <Msg>[];
  final orders = <Order>[];
  final notifs = <Notif>[];
  final typing = <String, bool>{};
  int _n = 1000;
  String id() => 'x${_n++}';

  void _seed() {
    chats.addAll([
      Chat('c_sita', 'Sita Rai', userId: 'sita', unread: 2),
      Chat('c_boom', 'Boom Store', userId: 'boom', unread: 1),
      Chat('c_bibek', 'Bibek Thapa', userId: 'bibek'),
      Chat('c_team', 'Design Team', group: true, unread: 3),
      Chat('c_anita', 'Anita Gurung', userId: 'anita'),
    ]);
    Msg m(String c, String f, MType t, String time, {String? text, String s = 'read', List<String> r = const [], bool pin = false, Map<String, Object?>? x}) =>
        Msg(id(), c, f, t, time, text: text, status: s, reactions: r, pinned: pin, extra: x);
    msgs.addAll([
      m('c_sita', 'sita', MType.text, '05:45 AM', text: 'Morning! Did you get a chance to look at the new home screen?'),
      m('c_sita', 'me', MType.text, '05:49 AM', text: 'Yes — the calm spacing is exactly right. Shipping it.'),
      m('c_sita', 'sita', MType.text, '05:51 AM', text: 'Love that 🙌', r: ['❤️']),
      m('c_sita', 'sita', MType.voice, '06:45 AM', x: {'d': '0:14'}),
      m('c_sita', 'me', MType.text, '06:48 AM', text: 'Great summary. Let me fold that into the spec.'),
      m('c_sita', 'sita', MType.text, '08:07 AM', text: 'Which one feels most “SYSTEMBOOM” to you?'),
      m('c_sita', 'me', MType.text, '08:36 AM', text: 'The indigo one. It reads trustworthy without being cold.'),
      m('c_sita', 'sita', MType.text, '08:41 AM', text: 'Agreed. I’ll update the tokens 👇'),
      m('c_boom', 'boom', MType.text, 'Yesterday', text: 'Hi Aarav! Thanks for reaching out. How can we help today?'),
      m('c_boom', 'me', MType.text, 'Yesterday', text: 'Hey! Interested in the desk mat — is the large size in stock?'),
      m('c_boom', 'boom', MType.product, 'Yesterday', x: {'pid': 'deskmat'}),
      m('c_boom', 'boom', MType.text, 'Yesterday', text: 'Yes! Large is in stock. Free delivery inside the valley.'),
      m('c_bibek', 'bibek', MType.text, '02:45 AM', text: 'Sending over the deck for tomorrow'),
      m('c_bibek', 'bibek', MType.document, '02:46 AM', x: {'name': 'Q3-Review.pptx', 'size': '2.4 MB', 'ext': 'PPTX'}),
      m('c_team', 'sita', MType.text, '08:15 AM', text: 'Rojan: can you own the icon audit?'),
      m('c_anita', 'anita', MType.text, 'Mon', text: 'Landing at 9, call you after!'),
    ]);
    notifs.addAll([
      Notif('n1', 'message', 'Sita Rai', 'Agreed. I’ll update the tokens 👇', '08:41 AM', chat: 'c_sita'),
      Notif('n2', 'mention', 'Design Team', 'Rojan mentioned you: “can you own the icon au…', '08:15 AM', chat: 'c_team'),
      Notif('n3', 'reaction', 'Aama', 'reacted 😍 to your message', '05:45 AM'),
      Notif('n4', 'missed_call', 'Prakash Sharma', 'Missed voice call', 'Yesterday', read: true),
      Notif('n5', 'group_invite', 'Boom Sellers', 'You were added to the group', '2 Oct', read: true),
      Notif('n6', 'order', 'Boom Store', 'Item shipped · Boom Express', '03:45 AM', read: true, chat: 'c_boom'),
    ]);
    orders.add(Order('ord_demo', 'c_boom', 'deskmat', 'SYSTEMBOOM Desk Mat — Large', 2250, 2, 0, status: 'shipped', paid: true, method: 'eSewa'));
  }

  Chat chat(String id) => chats.firstWhere((c) => c.id == id);
  List<Msg> thread(String chat) => msgs.where((m) => m.chat == chat).toList();
  Msg? last(String chat) {
    final t = thread(chat);
    return t.isEmpty ? null : t.last;
  }

  int get unreadNotifs => notifs.where((n) => !n.read).length;

  Chat openOrCreate(String userId, {bool private = false}) {
    final found = chats.where((c) => c.userId == userId && c.private == private);
    if (found.isNotEmpty) return found.first;
    final p = people[userId]!;
    final c = Chat(id(), p.name, userId: userId, private: private);
    chats.insert(0, c);
    notifyListeners();
    return c;
  }

  static const _replies = ['Got it 👍', 'Sounds good!', 'Thanks for letting me know.', 'Perfect, that works for me.', 'Let me check and get back to you.', '😄 agreed'];

  void send(String chat, MType t, {String? text, Map<String, Object?>? x, String? replyTo}) {
    final msg = Msg(id(), chat, 'me', t, 'Now', text: text, status: 'sent', extra: x);
    msgs.add(msg);
    notifyListeners();
    Timer(const Duration(milliseconds: 700), () {
      msg.status = 'delivered';
      notifyListeners();
    });
    final c = this.chat(chat);
    if (t == MType.text && c.userId != null) {
      Timer(const Duration(milliseconds: 1200), () {
        typing[chat] = true;
        notifyListeners();
      });
      Timer(const Duration(milliseconds: 2600), () {
        typing[chat] = false;
        msg.status = 'read';
        msgs.add(Msg(id(), chat, c.userId!, MType.text, 'Now', text: _replies[msgs.length % _replies.length], status: 'delivered'));
        notifyListeners();
      });
    }
  }

  void react(Msg m, String e) {
    m.reactions = m.reactions.contains(e) ? (List.of(m.reactions)..remove(e)) : [...m.reactions, e];
    notifyListeners();
  }

  void remove(Msg m) {
    m.deleted = true;
    m.text = null;
    notifyListeners();
  }

  void togglePin(Msg m) {
    m.pinned = !m.pinned;
    notifyListeners();
  }

  void touch() => notifyListeners();

  void sendOffer(String chat, Product p, int price, int qty, String note) {
    final msg = Msg(id(), chat, 'me', MType.offer, 'Now', status: 'sent', extra: {'pid': p.id, 'price': price, 'qty': qty, 'note': note, 'state': 'pending'});
    msgs.add(msg);
    notifyListeners();
    Timer(const Duration(milliseconds: 1900), () {
      msg.extra!['state'] = 'accepted';
      final c = this.chat(chat);
      msgs.add(Msg(id(), chat, c.userId ?? 'boom', MType.text, 'Now', text: 'Deal 🤝 ${money(price)} × $qty works for me. Tap “Create order” when you’re ready.', status: 'delivered'));
      notifyListeners();
    });
  }

  Order createOrder(String chat, Product p, int unit, int qty) {
    final o = Order('ord_${id()}', chat, p.id, p.title, unit, qty, 150);
    orders.insert(0, o);
    msgs.add(Msg(this.id(), chat, 'me', MType.system, 'Now', text: 'Order created · ${money(o.total)}'));
    msgs.add(Msg(this.id(), chat, 'me', MType.order, 'Now', status: 'sent', extra: {'oid': o.id}));
    notifyListeners();
    return o;
  }

  void pay(Order o, String method) {
    if (o.paid) return;
    o.paid = true;
    o.method = method;
    o.status = 'confirmed';
    msgs.add(Msg(id(), o.chat, 'me', MType.system, 'Now', text: 'Payment confirmed ✓'));
    notifyListeners();
    const steps = [('shipped', 'Item shipped · Boom Express', 4500), ('out_for_delivery', 'Out for delivery', 9000), ('delivered', 'Delivered ✓', 13500)];
    for (final s in steps) {
      Timer(Duration(milliseconds: s.$3), () {
        o.status = s.$1;
        msgs.add(Msg(id(), o.chat, 'boom', MType.system, 'Now', text: s.$2));
        notifyListeners();
      });
    }
  }

  void review(Order o) {
    o.reviewed = true;
    o.status = 'completed';
    notifyListeners();
  }
}
