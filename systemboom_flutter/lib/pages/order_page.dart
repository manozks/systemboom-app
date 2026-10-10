import 'package:flutter/material.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'chat_extra_pages.dart';
import 'chat_page.dart';

const _steps = [('confirmed', 'Order confirmed', Icons.check_rounded), ('shipped', 'Shipped', Icons.inventory_2_outlined), ('out_for_delivery', 'Out for delivery', Icons.local_shipping_outlined), ('delivered', 'Delivered', Icons.check_rounded)];
const _order = ['pending_payment', 'confirmed', 'shipped', 'out_for_delivery', 'delivered', 'completed'];

Color statusColor(String s) => switch (s) {
      'pending_payment' => const Color(0xFFFFB02E),
      'confirmed' => const Color(0xFF5AB8F2),
      'shipped' => const Color(0xFFA78BFA),
      'out_for_delivery' => const Color(0xFFFF9A3A),
      _ => const Color(0xFF35D07F),
    };

String statusLabel(String s) {
  final t = s.replaceAll('_', ' ');
  return t[0].toUpperCase() + t.substring(1);
}

class OrderPage extends StatefulWidget {
  const OrderPage(this.id, {super.key});
  final String id;
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String method = 'eSewa';
  int stars = 5;
  bool paying = false;
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
    final o = s.orders.firstWhere((x) => x.id == widget.id);
    final p = products.firstWhere((x) => x.id == o.productId);
    final idx = _order.indexOf(o.status);
    final canReview = o.status == 'delivered' && !o.reviewed;
    const methods = [('eSewa', Icons.smartphone_rounded), ('Khalti', Icons.account_balance_wallet_outlined), ('Card', Icons.credit_card_rounded), ('Cash on delivery', Icons.attach_money_rounded)];

    return PageShell(
      title: 'Order',
      active: 'market',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: (!o.paid || canReview || o.status == 'shipped' || o.status == 'out_for_delivery' || o.status == 'confirmed') ? 400 : 80,
      footer: !o.paid
          ? FootBar(u: u, child: ArtBtn(u: u, label: paying ? 'Processing…' : method == 'Cash on delivery' ? 'Confirm order' : 'Pay ${money(o.total)}', icon: Icons.shopping_bag_outlined, orange: true, minH: 190, fontPx: 62, onTap: paying ? null : () {
            setState(() => paying = true);
            Future<void>.delayed(const Duration(milliseconds: 1600), () {
              if (!mounted) return;
              s.pay(o, method);
              setState(() => paying = false);
              showToast(context, 'Payment confirmed');
            });
          }, enabled: !paying))
          : canReview
              ? FootBar(u: u, child: ArtBtn(u: u, label: 'Leave a review', icon: Icons.star_rounded, orange: true, minH: 190, fontPx: 62, onTap: () => pushScreen(context, OrderReviewPage(o.id))))
              : (o.status == 'shipped' || o.status == 'out_for_delivery' || o.status == 'confirmed')
                  ? FootBar(u: u, child: ArtBtn(u: u, label: 'Track delivery', icon: Icons.local_shipping_outlined, orange: true, minH: 190, fontPx: 62, onTap: () => pushScreen(context, OrderTrackPage(o.id))))
                  : null,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(6 * u, 0, 6 * u, 10 * u),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Order ${o.id.substring(o.id.length - 6).toUpperCase()}', style: ts(u, 46, c: const Color(0xFF9FC6FF), w: FontWeight.w400, sh: const [])),
              Text('12:04 AM - Boom Store', style: ts(u, 42, c: const Color(0xFFA9C3F5), w: FontWeight.w400, sh: const [])),
            ]),
            StatusArt(u: u, text: statusLabel(o.status), color: statusColor(o.status)),
          ]),
        ),
        SteelPlate(u: u, pad: EdgeInsets.fromLTRB(44 * u, 36 * u, 54 * u, 36 * u), child: Row(children: [
          ProdTile(u: u, p: p),
          SizedBox(width: 26 * u),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.title, style: ts(u, 42, w: FontWeight.w800, h: 1.15)), SizedBox(height: 8 * u), Text('${money(o.unit)} × ${o.qty}', style: ts(u, 36, c: const Color(0xFF7FB0FF), w: FontWeight.w500, sh: const []))])),
          Text(money(o.sub), style: ts(u, 44, w: FontWeight.w800)),
        ])),
        SteelPlate(u: u, pad: EdgeInsets.fromLTRB(54 * u, 40 * u, 54 * u, 34 * u), child: Column(children: [
          _line(u, 'Subtotal', money(o.sub)),
          _line(u, 'Delivery', money(o.fee)),
          Container(height: 2 * u, margin: EdgeInsets.only(top: 12 * u), color: const Color(0x33FFFFFF)),
          Padding(padding: EdgeInsets.only(top: 18 * u), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Total', style: ts(u, 54, w: FontWeight.w900)), Text(money(o.total), style: ts(u, 54, w: FontWeight.w900, c: const Color(0xFFFFB02E)))])),
        ])),
        OLabel('Deliver to', u: u),
        SteelPlate(u: u, minH: 120, pad: EdgeInsets.symmetric(horizontal: 50 * u, vertical: 32 * u), child: Row(children: [Icon(Icons.location_on_rounded, size: 54 * u, color: const Color(0xFFFFB02E)), SizedBox(width: 26 * u), Text('Baneshwor, Kathmandu', style: ts(u, 42, w: FontWeight.w400, sh: const []))])),
        if (!o.paid) ...[
          OLabel('Payment method', u: u),
          Wrap(spacing: 10 * u, runSpacing: 14 * u, children: [
            for (final m in methods)
              SizedBox(
                width: (941 * u - 52 * u - 10 * u) / 2,
                child: ArtBtn(u: u, label: m.$1, icon: m.$2, orange: method == m.$1, minH: 144, fontPx: 44, onTap: () => setState(() => method = m.$1)),
              ),
          ]),
          SizedBox(height: 24 * u),
          Nine('plate-green', px: sizeGreen, slice: 44, u: u, minH: 150 * u, pad: EdgeInsets.fromLTRB(50 * u, 34 * u, 50 * u, 34 * u), child: Row(children: [
            Container(width: 76 * u, height: 76 * u, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2EE8A0), width: 5 * u), boxShadow: [BoxShadow(color: const Color(0xFF2EE8A0).withValues(alpha: .7), blurRadius: 12 * u)]), child: Icon(Icons.info_outline_rounded, size: 52 * u, color: const Color(0xFF4FF0B0))),
            SizedBox(width: 28 * u),
            Expanded(child: Text('Payment details stay private — only a confirmation is shared in chat.', style: ts(u, 38, w: FontWeight.w400, h: 1.3, sh: const []))),
          ])),
        ] else ...[
          OLabel('Tracking · Boom Express', u: u),
          SteelPlate(u: u, child: Column(children: [
            for (final st in _steps)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 14 * u),
                child: Row(children: [
                  Container(width: 54 * u, height: 54 * u, decoration: BoxDecoration(shape: BoxShape.circle, color: idx >= _order.indexOf(st.$1) ? const Color(0xFFE5560A) : const Color(0xFF0A0F15), border: Border.all(color: idx >= _order.indexOf(st.$1) ? const Color(0xFFFFD9A0) : const Color(0xFF4A5560), width: 4 * u), boxShadow: [if (idx >= _order.indexOf(st.$1)) BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .7), blurRadius: 12 * u)]), child: Icon(st.$3, size: 32 * u, color: Colors.white)),
                  SizedBox(width: 24 * u),
                  Text(st.$2, style: ts(u, 40, w: FontWeight.w800)),
                ]),
              ),
          ])),
        ],
        SizedBox(height: 24 * u),
        ArtBtn(u: u, label: 'Open conversation', icon: Icons.chat_bubble_outline_rounded, minH: 120, fontPx: 38, onTap: () => pushScreen(context, ConversationPage(o.chat))),
      ],
    );
  }

  Widget _line(double u, String a, String b) => Padding(padding: EdgeInsets.symmetric(vertical: 10 * u), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a, style: ts(u, 42, w: FontWeight.w400, sh: const [])), Text(b, style: ts(u, 42, w: FontWeight.w400, sh: const []))]));
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final s = Store.i;
    return PageShell(
      title: 'My Orders',
      active: 'market',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      children: [
        for (final o in s.orders)
          SteelPlate(u: u, onTap: () => pushScreen(context, OrderPage(o.id)), child: Row(children: [
            ProdTile(u: u, p: products.firstWhere((p) => p.id == o.productId), w: 110, h: 100),
            SizedBox(width: 24 * u),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(o.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(u, 40, w: FontWeight.w800)), Text('Boom Store · ${money(o.total)}', style: ts(u, 32, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
            Text(statusLabel(o.status), style: ts(u, 30, w: FontWeight.w800, c: statusColor(o.status))),
          ])),
      ],
    );
  }
}

