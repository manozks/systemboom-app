import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:systemboom_app/data.dart';
import 'package:systemboom_app/kit.dart';
import 'package:systemboom_app/main.dart';
import 'package:systemboom_app/pages/anon_pages.dart';
import 'package:systemboom_app/pages/call_page.dart';
import 'package:systemboom_app/pages/calls_page.dart';
import 'package:systemboom_app/pages/chat_extra_pages.dart';
import 'package:systemboom_app/pages/chat_info_page.dart';
import 'package:systemboom_app/pages/chat_page.dart';
import 'package:systemboom_app/pages/chats_page.dart';
import 'package:systemboom_app/pages/design_page.dart';
import 'package:systemboom_app/pages/market_page.dart';
import 'package:systemboom_app/pages/more_pages.dart';
import 'package:systemboom_app/pages/notifications_page.dart';
import 'package:systemboom_app/pages/offer_page.dart';
import 'package:systemboom_app/pages/order_page.dart';
import 'package:systemboom_app/pages/product_page.dart';
import 'package:systemboom_app/pages/profile_page.dart';

/// Phone-size smoke test: every page must build with device insets (notch / home indicator)
/// without layout overflows or other exceptions.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final f = FontLoader('Figtree')..addFont(Future.value(ByteData.sublistView(File('assets/fonts/Figtree.ttf').readAsBytesSync())));
    await f.load();
  });
  final s = Store.i;
  final oid = s.orders.isNotEmpty ? s.orders.first.id : null;
  final pages = <String, Widget Function()>{
    'Home': () => const HomePage(),
    'Chats': () => const ChatsPage(),
    'Archived': () => const ChatsPage(archived: true),
    'Conversation': () => const ConversationPage('c_sita'),
    'Group conversation': () => const ConversationPage('c_team'),
    'Chat info': () => const ChatInfoPage('c_sita'),
    'Group info': () => const ChatInfoPage('c_team'),
    'Chat search': () => const ChatSearchPage('c_sita'),
    'Pinned': () => const ChatPinnedPage('c_sita'),
    'Media': () => const ChatMediaPage('c_sita'),
    'Draft chat': () => const DraftChatPage('sita'),
    'New chat': () => const NewChatPage(),
    'Calls': () => const CallsPage(),
    'Call': () => const CallPage('Sita Rai', video: true),
    'Market': () => const MarketPage(),
    'Product': () => const ProductPage('deskmat'),
    'Offer': () => const OfferPage('c_boom', productId: 'deskmat'),
    'Create order': () => const CreateOrderPage('deskmat', 'c_boom'),
    'Orders': () => const OrdersPage(),
    if (oid != null) 'Order': () => OrderPage(oid),
    if (oid != null) 'Track': () => OrderTrackPage(oid),
    if (oid != null) 'Review': () => OrderReviewPage(oid),
    'Profile': () => const ProfilePage(),
    'Settings': () => const SettingsPage(),
    'Settings privacy': () => const SettingsPage(section: 'privacy'),
    'Settings devices': () => const SettingsPage(section: 'devices'),
    'Notifications': () => const NotificationsPage(),
    'Design': () => const DesignPage(),
    'Welcome': () => const WelcomePage(),
    'Anonymous': () => const AnonymousPage(),
    'Anon identities': () => const AnonIdentitiesPage(),
    'Anon QR': () => const AnonQrPage(),
    'Anon scan': () => const AnonScanPage(),
    'Anon key': () => const AnonKeyPage('anon-me'),
    'Anon chats': () => const AnonChatsPage(),
  };

  const devices = {
    'Android 360x800': (Size(360, 800), EdgeInsets.fromLTRB(0, 24, 0, 48)),
    'iPhone 390x844': (Size(390, 844), EdgeInsets.fromLTRB(0, 47, 0, 34)),
    'Small 320x568': (Size(320, 568), EdgeInsets.fromLTRB(0, 20, 0, 0)),
  };

  for (final d in devices.entries) {
    for (final p in pages.entries) {
      testWidgets('${d.key} · ${p.key}', (tester) async {
        final (size, pad) = d.value;
        tester.view.physicalSize = size * 3;
        tester.view.devicePixelRatio = 3;
        tester.view.padding = FakeViewPadding(top: pad.top * 3, bottom: pad.bottom * 3);
        tester.view.viewPadding = FakeViewPadding(top: pad.top * 3, bottom: pad.bottom * 3);
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Figtree'), home: p.value()));
        for (var i = 0; i < 4; i++) {
          await tester.pump(const Duration(milliseconds: 300));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('Action sheet builds on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Figtree'),
      home: Builder(builder: (c) => Scaffold(body: Center(child: TextButton(onPressed: () => showActions(c, title: 'Sita Rai', items: [ActItem('View info', Icons.info_outline, () {}), ActItem('Delete conversation', Icons.delete_outline, () {}, danger: true)]), child: const Text('open'))))),
    ));
    await tester.tap(find.text('open'));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Delete conversation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Splash: fuse burns, blasts and opens the app', (tester) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Figtree'), home: const SplashPage()));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 300)); // 3.6 s > burn + blast
    }
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
    expect(find.byType(SplashPage), findsNothing); // moved on to the home page
  });
}
