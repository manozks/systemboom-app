import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'chat_page.dart';

class OfferPage extends StatefulWidget {
  const OfferPage(this.chatId, {super.key, this.productId});
  final String chatId;
  final String? productId;
  @override
  State<OfferPage> createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  String? pid;
  int qty = 1;
  final _price = TextEditingController();
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    pid = widget.productId;
    if (pid != null) _price.text = '${products.firstWhere((p) => p.id == pid).price}';
    _price.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _price.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    if (pid == null) {
      return PageShell(
        title: 'Make an offer',
        active: 'chats',
        showDock: false,
        headerArt: 'hdr-calls',
        right: bellBtn(context, u),
        children: [
          OLabel('Choose a product', u: u),
          for (final p in products)
            SteelPlate(u: u, onTap: () => setState(() {
                  pid = p.id;
                  _price.text = '${p.price}';
                }), child: Row(children: [ProdTile(u: u, p: p), SizedBox(width: 26 * u), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, style: ts(u, 42, w: FontWeight.w800)), Text(money(p.price), style: ts(u, 36, c: const Color(0xFFFFB02E), w: FontWeight.w700))]))])),
        ],
      );
    }
    final p = products.firstWhere((x) => x.id == pid);
    final n = int.tryParse(_price.text) ?? 0;
    final valid = n > 0 && n <= p.price * 1.5;
    return PageShell(
      title: 'Make an offer',
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      bottomPad: 400,
      footer: FootBar(
        u: u,
        child: ArtBtn(u: u, label: 'Send offer · ${money(n * qty)}', icon: Icons.send_rounded, orange: true, minH: 190, fontPx: 60, enabled: valid, onTap: () {
          Store.i.sendOffer(widget.chatId, p, n, qty, _note.text.trim());
          Navigator.of(context).pushReplacement(PageRouteBuilder<void>(pageBuilder: (_, _, _) => ConversationPage(widget.chatId), transitionDuration: const Duration(milliseconds: 600), transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c)));
        }),
      ),
      children: [
        SteelPlate(u: u, child: Row(children: [
          ProdTile(u: u, p: p),
          SizedBox(width: 26 * u),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, style: ts(u, 42, w: FontWeight.w800)), Text.rich(TextSpan(children: [const TextSpan(text: 'Listed at '), TextSpan(text: money(p.price), style: const TextStyle(color: Color(0xFFFFB02E), fontWeight: FontWeight.w800))]), style: ts(u, 36, c: const Color(0xFF7FB0FF), w: FontWeight.w500, sh: const []))])),
        ])),
        OLabel('Your price per unit (Rs)', u: u),
        GlassWell(u: u, child: Row(children: [
          Icon(Icons.sell_outlined, size: 60 * u, color: const Color(0xFFFFB02E)),
          SizedBox(width: 22 * u),
          Expanded(child: TextField(controller: _price, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], cursorColor: const Color(0xFFFFB02E), style: TextStyle(fontSize: 84 * u, fontWeight: FontWeight.w900, color: const Color(0xFFFFB53A)), decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true))),
        ])),
        SizedBox(height: 12 * u),
        Row(children: [
          for (final pr in [('List price', 1.0), ('-5%', .95), ('-10%', .9), ('-15%', .85)])
            Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 5 * u), child: ArtBtn(u: u, label: pr.$1, minH: 96, fontPx: 30, onTap: () => setState(() => _price.text = '${(p.price * pr.$2).round()}')))),
        ]),
        OLabel('Quantity', u: u),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          RoundBtn(u: u, icon: Icons.remove_rounded, onTap: () => setState(() => qty = qty > 1 ? qty - 1 : 1)),
          SizedBox(width: 34 * u),
          SizedBox(width: 250 * u, child: GlassWell(u: u, pad: EdgeInsets.symmetric(vertical: 14 * u), child: Center(child: Text('$qty', style: ts(u, 84, w: FontWeight.w900))))),
          SizedBox(width: 34 * u),
          RoundBtn(u: u, icon: Icons.add_rounded, hot: true, onTap: () => setState(() => qty = qty < 20 ? qty + 1 : 20)),
        ]),
        OLabel('Note (optional)', u: u),
        GlassWell(u: u, child: SizedBox(height: 200 * u, child: TextField(controller: _note, maxLines: null, cursorColor: const Color(0xFFFFB02E), style: TextStyle(fontSize: 40 * u, color: Colors.white), decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: 'Add a friendly note', hintStyle: TextStyle(color: const Color(0xFF8896A6), fontSize: 40 * u))))),
        SizedBox(height: 26 * u),
        SteelPlate(u: u, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${money(n)} × $qty', style: ts(u, 42, w: FontWeight.w400)), Text(money(n * qty), style: ts(u, 44, w: FontWeight.w900, c: const Color(0xFFFFB02E)))])),
        if (n > p.price) Padding(padding: EdgeInsets.only(top: 14 * u), child: Container(padding: EdgeInsets.all(24 * u), decoration: BoxDecoration(borderRadius: BorderRadius.circular(28 * u), color: const Color(0xFF3A2406), border: Border.all(color: const Color(0x80FFBE5A), width: 4 * u)), child: Row(children: [Icon(Icons.warning_amber_rounded, size: 52 * u, color: const Color(0xFFFFC24A)), SizedBox(width: 20 * u), Text('Your offer is above the listed price.', style: ts(u, 36, c: const Color(0xFFFFE3B0), w: FontWeight.w400, sh: const []))]))),
      ],
    );
  }
}
