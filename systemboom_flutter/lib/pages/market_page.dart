import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../shell.dart';
import '../ui.dart';

class _Item {
  const _Item(this.title, this.kind, this.cat, this.place, this.price, this.photo);
  final String title;
  final String kind;
  final String cat;
  final String place;
  final String price;
  final String photo;
}

const _items = <_Item>[
  _Item('iPhone 14 Pro', 'Mobile Phone', 'Electronics', 'Kathmandu', 'Rs. 145,000', 'prod1'),
  _Item('Toyota Land Cruiser', 'Car', 'Vehicles', 'Kathmandu', 'Rs. 1,75,00,000', 'prod2'),
  _Item('Modern House', 'Property', 'Property', 'Lalitpur', 'Rs. 3,50,00,000', 'prod3'),
  _Item('MacBook Pro', 'Laptop', 'Electronics', 'Kathmandu', 'Rs. 2,40,000', 'prod4'),
];

const _cats = <(String, IconData)>[
  ('All', Icons.grid_view_rounded),
  ('Electronics', Icons.desktop_windows_outlined),
  ('Vehicles', Icons.directions_car_filled_outlined),
  ('Property', Icons.home_outlined),
  ('Services', Icons.build_outlined),
  ('Jobs', Icons.work_outline_rounded),
];

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  int cat = 0;
  String q = '';
  final Set<int> liked = {};
  String? sort;
  String? place;
  String? range;

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    var list = _items.where((p) {
      if (cat > 0 && p.cat != _cats[cat].$1) return false;
      if (place != null && p.place != place) return false;
      if (q.isNotEmpty && !('${p.title} ${p.kind}').toLowerCase().contains(q.toLowerCase())) return false;
      return true;
    }).toList();
    if (sort == 'Name') list.sort((a, b) => a.title.compareTo(b.title));

    return PageShell(
      title: 'Marketplace',
      titleSize: 56,
      headerArt: 'hdr-calls',
      active: 'market',
      right: ChromeBtn(u: u, gold: true, onTap: () => showToast(context, 'Orders'), child: Icon(Icons.view_in_ar_outlined, size: 46 * u, color: const Color(0xFFFFD27A))),
      children: [
        _search(u),
        SizedBox(height: 22 * u),
        _catRow(u),
        SizedBox(height: 22 * u),
        _filterBar(context, u),
        SizedBox(height: 22 * u),
        for (final p in list) _card(context, u, p),
        if (list.isEmpty) Padding(padding: EdgeInsets.all(60 * u), child: const Center(child: Text('No listings found', style: TextStyle(color: Color(0xFF8896A6), decoration: TextDecoration.none)))),
      ],
    );
  }

  // ───────── search (same art as Calls)
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
                  decoration: InputDecoration(border: InputBorder.none, isCollapsed: true, hintText: 'Search listings', hintStyle: TextStyle(color: const Color(0xFFD3DBE4), fontSize: (27 * k).clamp(11, 16))),
                ),
              ),
              Icon(Icons.mic_none_rounded, size: 40 * k, color: Colors.white),
              SizedBox(width: 34 * k),
            ]),
          ),
        ]),
      );
    });
  }

  // ───────── category keys: the reference art (six glass keys) with a glowing orange key that slides to the selection
  Widget _catRow(double u) {
    const slots = <(double, double)>[(4, 150), (154, 292), (298, 436), (442, 580), (585, 724), (728, 864)];
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 867;
      return SizedBox(
        height: 132 * k,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(child: Image.asset('assets/images/cat-base.webp', fit: BoxFit.fill)),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutBack,
            left: (slots[cat].$1 - 2) * k,
            top: 0,
            width: (slots[0].$2 - slots[0].$1 + 4) * k,
            height: 132 * k,
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(26 * k), boxShadow: [BoxShadow(color: const Color(0xFFFF7814).withValues(alpha: .55), blurRadius: 18 * k)]),
              child: Image.asset('assets/images/cat-key.webp', fit: BoxFit.fill),
            ),
          ),
          for (var i = 0; i < _cats.length; i++)
            Positioned(
              left: slots[i].$1 * k,
              top: 0,
              width: (slots[i].$2 - slots[i].$1) * k,
              height: 132 * k,
              child: Press(
                u: u,
                radius: 26,
                lift: 0,
                scaleUp: 1.0,
                shine: false,
                onTap: () => setState(() => cat = i),
                builder: (context, g, s) => Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(26 * k), color: Colors.white.withValues(alpha: cat == i ? 0 : .07 * g.clamp(0.0, 1.0))),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Transform.translate(
                      offset: Offset(0, -6 * k * math.sin(s * math.pi)),
                      child: Icon(_cats[i].$2, size: 58 * k, color: cat == i ? const Color(0xFFFFC66E) : const Color(0xFFE5EAF0)),
                    ),
                    SizedBox(height: 8 * k),
                    Text(_cats[i].$1, style: TextStyle(fontSize: (24 * k).clamp(10, 15), fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.none)),
                  ]),
                ),
              ),
            ),
        ]),
      );
    });
  }

  // ───────── Location / Sort by / Price Range / filters: reference art with live icons + labels
  Widget _filterBar(BuildContext context, double u) {
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 858;
      Widget zone(double x0, double x1, IconData icon, String label, VoidCallback onTap, {bool chevron = true}) => Positioned(
            left: x0 * k,
            top: 14 * k,
            width: (x1 - x0) * k,
            height: 62 * k,
            child: Press(
              u: u,
              radius: 999,
              lift: 1,
              scaleUp: 1.02,
              shine: false,
              onTap: onTap,
              builder: (context, g, s) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * k),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Colors.white.withValues(alpha: .08 * g.clamp(0.0, 1.0))),
                child: Row(children: [
                  Transform.translate(offset: Offset(0, -3 * k * math.sin(s * math.pi)), child: Icon(icon, size: 32 * k, color: Colors.white)),
                  SizedBox(width: 10 * k),
                  if (chevron) ...[
                    Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: (23 * k).clamp(9, 14), fontWeight: FontWeight.w600, color: Colors.white, decoration: TextDecoration.none))),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 32 * k, color: Colors.white),
                  ],
                ]),
              ),
            ),
          );
      return SizedBox(
        height: 90 * k,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(child: Image.asset('assets/images/filter-bar.webp', fit: BoxFit.fill)),
          zone(22, 258, Icons.place_rounded, place ?? 'Location', () => setState(() => place = place == null ? 'Kathmandu' : (place == 'Kathmandu' ? 'Lalitpur' : null))),
          zone(270, 494, Icons.swap_vert_rounded, sort ?? 'Sort by', () => setState(() => sort = sort == null ? 'Name' : null)),
          zone(508, 748, Icons.sell_rounded, range ?? 'Price Range', () {
            setState(() => range = range == null ? 'Any price' : null);
            showToast(context, 'Price range');
          }),
          Positioned(
            left: 760 * k,
            top: 12 * k,
            width: 76 * k,
            height: 66 * k,
            child: Press(
              u: u,
              radius: 22,
              lift: 1,
              scaleUp: 1.08,
              shine: false,
              onTap: () => showToast(context, 'Filters'),
              builder: (context, g, s) => Center(child: Transform.rotate(angle: .25 * math.sin(s * math.pi * 2) * (1 - s), child: Icon(Icons.tune_rounded, size: 42 * k, color: Colors.white))),
            ),
          ),
        ]),
      );
    });
  }

  // ───────── listing card (reference layout: photo | details | heart + menu + glowing Buy Now)
  Widget _card(BuildContext context, double u, _Item p) {
    final idx = _items.indexOf(p);
    final fav = liked.contains(idx);
    return LayoutBuilder(builder: (context, c) {
      const k = 1.0; // designed at 865 x 174 and scaled to fit
      final scale = c.maxWidth / 865;
      return Padding(
        padding: EdgeInsets.only(bottom: 14 * u),
        child: SizedBox(
          height: 232 * scale,
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(
              width: 865,
              height: 232,
              child: Press(
            u: u,
            radius: 34,
            lift: 3,
            onTap: () => showToast(context, p.title),
            builder: (context, g, s) => Stack(clipBehavior: Clip.none, children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30 * k),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 26, offset: const Offset(0, 18)), BoxShadow(color: const Color(0xFFFF8C32).withValues(alpha: .32), blurRadius: 30)],
                  ),
                  child: Stack(fit: StackFit.passthrough, children: [
                    Positioned.fill(child: Image.asset('assets/images/cta-blank-wide.webp', fit: BoxFit.fill)),
                    Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * k), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white.withValues(alpha: .14), Colors.white.withValues(alpha: 0), const Color(0xFFFF9A3A).withValues(alpha: .14)], stops: const [0, .5, 1]))))),
                  ]),
                ),
              ),
              // photo in a gold-edged frame with rounded corners
              Positioned(
                left: 48 * k,
                top: 46 * k,
                width: 216 * k,
                height: 140 * k,
                child: Container(
                  padding: EdgeInsets.all(3.5 * k),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22 * k),
                    gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFFFE2A8), Color(0xFFD98A2E), Color(0xFF5A3510), Color(0xFFFFD58A)]),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 7 * k, offset: Offset(0, 5 * k)), BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .4), blurRadius: 12 * k)],
                  ),
                  child: ClipRRect(borderRadius: BorderRadius.circular(19 * k), child: Image.asset('assets/images/${p.photo}.webp', fit: BoxFit.cover)),
                ),
              ),
              Positioned(
                left: 296 * k,
                top: 44 * k,
                right: 262 * k,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: (29 * k), fontWeight: FontWeight.w800, color: Colors.white, decoration: TextDecoration.none)),
                  SizedBox(height: 2 * k),
                  Text(p.kind, style: TextStyle(fontSize: (23 * k), fontWeight: FontWeight.w400, color: const Color(0xFFE6EDF5), decoration: TextDecoration.none)),
                  SizedBox(height: 4 * k),
                  Row(children: [
                    Icon(Icons.place_outlined, size: 24 * k, color: Colors.white),
                    SizedBox(width: 6 * k),
                    Text(p.place, style: TextStyle(fontSize: (21 * k), color: Colors.white, decoration: TextDecoration.none)),
                  ]),
                  SizedBox(height: 4 * k),
                  GradText(p.price, colors: const [Color(0xFFFFE2A8), Color(0xFFFFB53A), Color(0xFFFF9A1A)], stops: const [0, .5, 1], style: TextStyle(fontSize: (28 * k), height: 1.1, fontWeight: FontWeight.w900, decoration: TextDecoration.none), shadow: const Color(0xFF3B1A04), u: u),
                ]),
              ),
              Positioned(
                right: 44 * k,
                top: 44 * k,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Press(
                    u: u,
                    radius: 20,
                    lift: 0,
                    scaleUp: 1.25,
                    shine: false,
                    onTap: () => setState(() => fav ? liked.remove(idx) : liked.add(idx)),
                    child: Padding(padding: EdgeInsets.all(8 * k), child: Icon(fav ? Icons.favorite_rounded : Icons.favorite_border_rounded, size: 40 * k, color: fav ? const Color(0xFFFF5A6D) : Colors.white)),
                  ),
                  SizedBox(width: 14 * k),
                  Press(
                    u: u,
                    radius: 20,
                    lift: 0,
                    scaleUp: 1.25,
                    shine: false,
                    onTap: () => showToast(context, 'More options'),
                    child: Padding(padding: EdgeInsets.all(8 * k), child: Icon(Icons.more_vert_rounded, size: 40 * k, color: Colors.white)),
                  ),
                ]),
              ),
              Positioned(
                right: 46 * k,
                bottom: 48 * k,
                width: 210 * k,
                height: 66 * k,
                child: Press(
                  u: u,
                  radius: 999,
                  lift: 2,
                  scaleUp: 1.06,
                  shine: false,
                  onTap: () => showToast(context, 'Chatting with the seller about ${p.title}'),
                  child: Image.asset('assets/images/buy-btn.webp', fit: BoxFit.fill),
                ),
              ),
            ]),
              ),
            ),
          ),
        ),
      );
    });
  }
}
