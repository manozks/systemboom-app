import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../kit.dart' show pushScreen;
import '../shell.dart';
import 'more_pages.dart';
import 'order_page.dart';
import 'chat_page.dart' show NotificationsLazy;
import '../ui.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    return PageShell(
      title: 'Profile',
      headerArt: 'hdr-calls',
      active: 'profile',
      right: ChromeBtn(u: u, gold: true, onTap: () => pushScreen(context, const SettingsPage()), child: Icon(Icons.settings_outlined, size: 46 * u, color: const Color(0xFFFFD27A))),
      children: [
        _hero(context, u),
        SizedBox(height: 18 * u),
        _stats(context, u),
        SizedBox(height: 22 * u),
        _row(context, u, Icons.receipt_long_outlined, 'My Orders', 'Track and manage your orders'),
        SizedBox(height: 2 * u),
        _row(context, u, Icons.favorite_border_rounded, 'My Wishlist', 'Products you saved'),
        SizedBox(height: 2 * u),
        _row(context, u, Icons.place_outlined, 'My Addresses', 'Manage delivery addresses'),
        SizedBox(height: 2 * u),
        _row(context, u, Icons.account_balance_wallet_outlined, 'Payments & Wallet', 'Manage payment methods'),
        SizedBox(height: 2 * u),
        _row(context, u, Icons.notifications_none_rounded, 'Notifications', 'Manage your notifications'),
        SizedBox(height: 2 * u),
        SizedBox(height: 14 * u),
        _row(context, u, Icons.settings_outlined, 'Account Settings', 'Privacy, security and preferences'),
        SizedBox(height: 2 * u),
        _row(context, u, Icons.headset_mic_outlined, 'Help & Support', 'Get help or contact us'),
        SizedBox(height: 2 * u),
        Padding(
          padding: EdgeInsets.only(top: 26 * u),
          child: Center(child: Text('SYSTEMBOOM Chat · Prototype · Phase 1 Foundation', style: TextStyle(fontSize: (26 * u).clamp(10, 12), color: const Color(0xFF7F8E9E), decoration: TextDecoration.none))),
        ),
      ],
    );
  }

  // ───────── hero: the reference art (steel plate, glowing photo ring, camera badge, Edit Profile button) + live text
  Widget _hero(BuildContext context, double u) {
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 860;
      Widget line(IconData i, String t, double top) => Positioned(
            left: 302 * k,
            top: top * k,
            child: Row(children: [
              Icon(i, size: 32 * k, color: Colors.white),
              SizedBox(width: 16 * k),
              Text(t, style: TextStyle(fontSize: 29 * k, color: Colors.white, decoration: TextDecoration.none)),
            ]),
          );
      return SizedBox(
        height: 289 * k,
        child: Press(
          u: u,
          radius: 34,
          lift: 3,
          scaleUp: 1.0,
          onTap: () => showToast(context, 'Profile details'),
          builder: (context, g, s) => Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(30 * k), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 14 * u, offset: Offset(0, 10 * u)), BoxShadow(color: const Color(0xFFFF8C32).withValues(alpha: .3), blurRadius: 18 * u)]),
              child: Image.asset('assets/images/profile-card.webp', fit: BoxFit.fill),
            )),
            Positioned(
              left: 302 * k,
              top: 34 * k,
              child: Row(children: [
                GradText('Aarav Sharma', colors: const [Color(0xFFFFFFFF), Color(0xFFFFE9C8), Color(0xFFE8A868)], stops: const [0, .5, 1], style: TextStyle(fontSize: 46 * k, fontWeight: FontWeight.w800, decoration: TextDecoration.none), shadow: const Color(0xFF2A1004), u: u),
                SizedBox(width: 14 * k),
                Container(
                  width: 42 * k,
                  height: 42 * k,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: const RadialGradient(center: Alignment(-.3, -.5), colors: [Color(0xFF7ABAFF), Color(0xFF1E6FE0)]), boxShadow: [BoxShadow(color: const Color(0xAA3C8CFF), blurRadius: 12 * k)]),
                  child: Icon(Icons.check_rounded, size: 28 * k, color: Colors.white),
                ),
              ]),
            ),
            line(Icons.mail_outline_rounded, 'aarav.sharma@example.com', 90),
            line(Icons.phone_rounded, '+977 9851416684', 128),
            line(Icons.place_outlined, 'Kathmandu, Nepal', 166),
            Positioned(right: 28 * k, top: 118 * k, child: Transform.translate(offset: Offset(8 * k * math.sin(s * math.pi), 0), child: Icon(Icons.chevron_right_rounded, size: 46 * k, color: Colors.white))),
            // tap targets over the art's camera badge and Edit Profile button
            Positioned(
              left: 186 * k,
              top: 182 * k,
              width: 74 * k,
              height: 74 * k,
              child: Press(u: u, circle: true, scaleUp: 1.12, lift: 2, shine: false, onTap: () => showToast(context, 'Change photo'), child: const SizedBox.expand()),
            ),
            Positioned(
              left: 300 * k,
              top: 204 * k,
              width: 318 * k,
              height: 66 * k,
              child: Press(u: u, radius: 999, scaleUp: 1.04, lift: 2, onTap: () => pushScreen(context, const SettingsPage(section: 'profile')), child: const SizedBox.expand()),
            ),
          ]),
        ),
      );
    });
  }

  // ───────── stats row: reference art with live icons, numbers and labels
  Widget _stats(BuildContext context, double u) {
    const data = <(IconData, String, String)>[
      (Icons.shopping_cart_outlined, '24', 'Purchases'),
      (Icons.favorite_border_rounded, '18', 'Favorites'),
      (Icons.chat_outlined, '12', 'Reviews'),
      (Icons.place_outlined, '5', 'Addresses'),
    ];
    const cols = <(double, double)>[(26, 218), (228, 422), (432, 628), (638, 832)];
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 856;
      return SizedBox(
        height: 178 * k,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(28 * k), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .7), blurRadius: 14 * u, offset: Offset(0, 10 * u)), BoxShadow(color: const Color(0xFFFF8C32).withValues(alpha: .3), blurRadius: 18 * u)]),
              child: Image.asset('assets/images/stats-card.webp', fit: BoxFit.fill),
            ),
          ),
          for (var i = 0; i < data.length; i++)
            Positioned(
              left: cols[i].$1 * k,
              top: 14 * k,
              width: (cols[i].$2 - cols[i].$1) * k,
              height: 150 * k,
              child: Press(
                u: u,
                radius: 24,
                lift: 2,
                scaleUp: 1.05,
                shine: false,
                onTap: () => _open(context, data[i].$3 == 'Purchases' ? 'My Orders' : data[i].$3),
                builder: (context, g, st) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Transform.translate(offset: Offset(0, -6 * k * math.sin(st * math.pi)), child: Icon(data[i].$1, size: 50 * k, color: Colors.white)),
                  SizedBox(height: 2 * k),
                  GradText(data[i].$2, colors: const [Color(0xFFFFE2B8), Color(0xFFFFB86A), Color(0xFFFF9A3A)], stops: const [0, .5, 1], style: TextStyle(fontSize: 44 * k, fontWeight: FontWeight.w900, height: 1.1, decoration: TextDecoration.none), shadow: const Color(0xFF3B1A04), u: u),
                  Text(data[i].$3, style: TextStyle(fontSize: 25 * k, color: Colors.white, decoration: TextDecoration.none)),
                ]),
              ),
            ),
        ]),
      );
    });
  }

  // ───────── list rows: the reference row plate + live gold icon ring, clear text and chevron
  Widget _row(BuildContext context, double u, IconData icon, String title, String sub) {
    return LayoutBuilder(builder: (context, c) {
      final k = c.maxWidth / 856;
      final h = math.max(104 * k, 70.0);
      final ring = h * .8;
      return SizedBox(
        height: h,
        child: Press(
          u: u,
          radius: 34,
          lift: 2,
          scaleUp: 1.0,
          onTap: () => _open(context, title),
          builder: (context, g, s) => Stack(clipBehavior: Clip.none, children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(28 * k), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .6), blurRadius: 8 * u, offset: Offset(0, 6 * u))]),
                child: Image.asset('assets/images/menu-row.webp', fit: BoxFit.fill),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(34 * k + 6, 0, 26 * k + 6, 0),
                child: Row(children: [
                  Container(
                    width: ring,
                    height: ring,
                    padding: EdgeInsets.all(ring * .06),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const SweepGradient(colors: [Color(0xFFFFE2A8), Color(0xFFB9772A), Color(0xFF5A3510), Color(0xFFFFD58A), Color(0xFFFFE2A8)]),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF7A1A).withValues(alpha: .55), blurRadius: 12 * k), BoxShadow(color: Colors.black.withValues(alpha: .8), blurRadius: 6 * k, offset: Offset(0, 4 * k))],
                    ),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(center: Alignment(-.3, -.5), colors: [Color(0xFF3A2410), Color(0xFF0A0604)])),
                      child: Center(child: Transform.scale(scale: 1 + .12 * math.sin(s * math.pi), child: Icon(icon, size: ring * .52, color: const Color(0xFFFFB866), shadows: [Shadow(color: const Color(0xFFFF8C28), blurRadius: 8 * k)]))),
                    ),
                  ),
                  SizedBox(width: 22 * k + 4),
                  Expanded(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: math.max(34 * k, 15.5), fontWeight: FontWeight.w800, height: 1.15, color: Colors.white, decoration: TextDecoration.none)),
                      Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: math.max(27 * k, 12.5), fontWeight: FontWeight.w400, height: 1.2, color: const Color(0xFFF2F6FA), decoration: TextDecoration.none)),
                    ]),
                  ),
                  Transform.translate(offset: Offset(8 * k * math.sin(s * math.pi), 0), child: Icon(Icons.chevron_right_rounded, size: math.max(46 * k, 26), color: Colors.white)),
                ]),
              ),
            ),
          ]),
        ),
      );
    });
  }
}


void _open(BuildContext context, String title) {
  switch (title) {
    case 'My Orders':
    case 'Payments & Wallet':
      pushScreen(context, const OrdersPage());
    case 'Notifications':
      pushScreen(context, const NotificationsLazy());
    case 'Account Settings':
      pushScreen(context, const SettingsPage());
    case 'Help & Support':
      pushScreen(context, const SettingsPage(section: 'help'));
    case 'My Addresses':
      pushScreen(context, const SettingsPage(section: 'privacy'));
    default:
      showToast(context, title);
  }
}
