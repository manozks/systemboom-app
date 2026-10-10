import 'package:flutter/material.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'chat_page.dart';
import 'offer_page.dart';
import 'chat_extra_pages.dart';
import 'order_page.dart';

class ProductPage extends StatelessWidget {
  const ProductPage(this.id, {super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final p = products.firstWhere((x) => x.id == id);
    final seller = people[p.seller]!;
    final stock = p.avail == 'In stock' ? const Color(0xFF2BFF8A) : p.avail == 'Low stock' ? const Color(0xFFFFB02E) : const Color(0xFF5AB8F2);
    Chat chat() => Store.i.openOrCreate(p.seller);

    return PageShell(
      title: 'Product',
      active: 'market',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 440,
      footer: FootBar(
        u: u,
        child: Row(children: [
          Expanded(flex: 100, child: ArtBtn(u: u, label: 'Chat', icon: Icons.chat_bubble_outline_rounded, minH: 174, fontPx: 58, onTap: () => pushScreen(context, ConversationPage(chat().id)))),
          SizedBox(width: 8 * u),
          Expanded(flex: 107, child: ArtBtn(u: u, label: 'Buy now', icon: Icons.shopping_bag_outlined, orange: true, minH: 174, fontPx: 58, onTap: () => pushScreen(context, CreateOrderPage(p.id, chat().id)))),
        ]),
      ),
      children: [
        Rise(
          child: Padding(
            padding: EdgeInsets.fromLTRB(14 * u, 14 * u, 14 * u, 26 * u),
            child: Nine('pframe-photo', px: sizePhotoFrame, slice: 80, u: u, pad: EdgeInsets.fromLTRB(42 * u, 50 * u, 38 * u, 45 * u),
                child: AspectRatio(
                  aspectRatio: 818 / 540,
                  child: p.photo != null
                      ? Image.asset('assets/images/${p.photo}.webp', fit: BoxFit.cover)
                      : DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(p.tint), const Color(0xFF10151C)])), child: Center(child: Icon(Icons.shopping_bag_outlined, size: 160 * u, color: Colors.white54))),
                )),
          ),
        ),
        Rise(i: 1, child: Padding(padding: EdgeInsets.symmetric(horizontal: 8 * u), child: Nine('plate-title', px: sizeTitle, slice: 44, u: u, minH: 113 * u, pad: EdgeInsets.symmetric(horizontal: 44 * u, vertical: 30 * u), child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text(p.title, maxLines: 1, style: ts(u, 54, w: FontWeight.w800))))))),
        Rise(
          i: 2,
          child: Padding(
            padding: EdgeInsets.fromLTRB(6 * u, 22 * u, 6 * u, 8 * u),
            child: Row(children: [
              ShaderMask(shaderCallback: (r) => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE2A8), Color(0xFFFFB53A), Color(0xFFFF9A1A)]).createShader(r), child: Text(money(p.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, decoration: TextDecoration.none).copyWith(fontSize: 92 * u))),
              SizedBox(width: 22 * u),
              Container(padding: EdgeInsets.symmetric(horizontal: 30 * u, vertical: 12 * u), decoration: BoxDecoration(borderRadius: BorderRadius.circular(99), color: const Color(0xFF07140D), border: Border.all(color: stock, width: 4 * u), boxShadow: [BoxShadow(color: stock, blurRadius: 14 * u)]), child: Text(p.avail, style: ts(u, 38, w: FontWeight.w800, c: stock))),
            ]),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6 * u),
          child: Row(children: [
            Icon(Icons.star_rounded, size: 48 * u, color: const Color(0xFFFFC24A)),
            SizedBox(width: 12 * u),
            Text(p.rating.toStringAsFixed(1), style: ts(u, 46, w: FontWeight.w800)),
            SizedBox(width: 12 * u),
            Text('(${p.reviews} reviews)', style: ts(u, 40, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const [])),
          ]),
        ),
        Padding(padding: EdgeInsets.fromLTRB(6 * u, 22 * u, 6 * u, 18 * u), child: Text(p.desc, style: ts(u, 36, c: const Color(0xFFEEF2F7), w: FontWeight.w400, h: 1.3, sh: const []))),
        Nine('plate-tab', px: sizeTab, slice: 40, u: u, minH: 88 * u, pad: EdgeInsets.fromLTRB(56 * u, 20 * u, 40 * u, 24 * u), child: Text('SELLER', style: ts(u, 31, w: FontWeight.w800, c: const Color(0xFFD3D8DE), ls: 31 * u * .2))),
        SteelPlate(u: u, onTap: () => pushScreen(context, ConversationPage(chat().id)), pad: EdgeInsets.fromLTRB(54 * u, 30 * u, 44 * u, 30 * u), child: Row(children: [
          Face(u: u, person: seller, size: 118, online: true),
          SizedBox(width: 26 * u),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${seller.name}  ✓', style: ts(u, 46, w: FontWeight.w800)), Text(seller.about ?? '', style: ts(u, 33, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
          Icon(Icons.chevron_right_rounded, size: 56 * u, color: const Color(0xFFE8EDF1)),
        ])),
        SteelPlate(u: u, pad: EdgeInsets.fromLTRB(54 * u, 30 * u, 44 * u, 30 * u), child: Row(children: [
          GoldIcon(Icons.local_shipping_outlined, u: u, size: 118),
          SizedBox(width: 26 * u),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Delivery', style: ts(u, 46, w: FontWeight.w800)), Text('Rs 150 inside the valley · 2–4 days', style: ts(u, 33, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
          Icon(Icons.chevron_right_rounded, size: 56 * u, color: const Color(0xFFE8EDF1)),
        ])),
        SizedBox(height: 12 * u),
        ArtBtn(u: u, label: 'Make an offer', icon: Icons.sell_outlined, minH: 120, fontPx: 40, onTap: () => pushScreen(context, OfferPage(chat().id, productId: p.id))),
      ],
    );
  }
}
