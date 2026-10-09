import 'package:flutter/material.dart';

import '../data.dart';
import '../kit.dart';
import '../shell.dart';
import 'chat_page.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({super.key});
  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  bool private = false;
  String q = '';

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final list = people.values.where((p) => p.id != 'me' && p.name.toLowerCase().contains(q.toLowerCase())).toList();
    Widget mode(String l, bool on, VoidCallback f) => Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 7 * u), child: Tap(onTap: () => setState(f), child: Nine(on ? 'info-chip-on' : 'info-chip-off', px: on ? sizeChipOn : sizeChipOff, slice: 40, u: u, minH: 100 * u, pad: EdgeInsets.symmetric(horizontal: 30 * u, vertical: 18 * u), child: Center(child: Text(l, style: ts(u, 38, w: FontWeight.w700)))))));
    return PageShell(
      title: 'New Chat',
      active: 'chats',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      searchHint: 'Search contacts',
      onSearch: (v) => setState(() => q = v),
      children: [
        OLabel('Privacy mode', u: u),
        Row(children: [mode('Standard', !private, () => private = false), mode('Private (E2EE)', private, () => private = true)]),
        SizedBox(height: 18 * u),
        OLabel('Contacts', u: u),
        for (final p in list)
          SteelPlate(
            u: u,
            onTap: () => pushScreen(context, ConversationPage(Store.i.openOrCreate(p.id, private: private && !p.business).id)),
            child: Row(children: [
              Face(u: u, person: p, size: 104, online: p.online),
              SizedBox(width: 26 * u),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name + (p.verified ? ' ✓' : ''), style: ts(u, 42, w: FontWeight.w800)), Text(p.about ?? '', style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
              Icon(Icons.chevron_right_rounded, size: 52 * u, color: const Color(0xFFE8EDF1)),
            ]),
          ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.section});
  final String? section;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final Map<String, bool> _on = {};

  static const _sections = [
    ('profile', 'Profile', 'Name, about, phone', Icons.person_outline_rounded),
    ('privacy', 'Privacy', 'Who can see your info', Icons.shield_outlined),
    ('security', 'Security', 'Encryption & verification', Icons.lock_outline_rounded),
    ('notifications', 'Notifications', 'Sounds, previews, mentions', Icons.notifications_none_rounded),
    ('devices', 'Linked devices', 'Where you are signed in', Icons.laptop_outlined),
    ('help', 'Help & support', 'FAQ and contact', Icons.help_outline_rounded),
  ];

  static const _toggles = {
    'privacy': ['Last seen & online', 'Read receipts', 'Profile photo', 'Group invites'],
    'security': ['Two-step verification', 'Screen lock', 'Security notifications'],
    'notifications': ['Message notifications', 'Show previews', 'Calls', 'Order updates', 'Mentions & reactions'],
  };

  @override
  Widget build(BuildContext context) {
    final u = context.u;
    final sec = widget.section;
    if (sec == null) {
      return PageShell(
        title: 'Settings',
        active: 'profile',
        showDock: false,
        headerArt: 'hdr-calls',
        right: bellBtn(context, u),
        children: [
          for (final s in _sections)
            SteelPlate(u: u, onTap: () => pushScreen(context, SettingsPage(section: s.$1)), child: Row(children: [
              GoldIcon(s.$4, u: u),
              SizedBox(width: 26 * u),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$2, style: ts(u, 42, w: FontWeight.w800)), Text(s.$3, style: ts(u, 31, c: const Color(0xFF9DB4E0), w: FontWeight.w400, sh: const []))])),
              Icon(Icons.chevron_right_rounded, size: 52 * u, color: const Color(0xFFE8EDF1)),
            ])),
          SizedBox(height: 14 * u),
          CtaBtn(u: u, label: 'Log out', icon: Icons.logout_rounded, red: true, onTap: () async {
            if (await confirmDialog(context, title: 'Log out?', text: 'You can sign back in anytime.', confirm: 'Log out') && context.mounted) pushScreen(context, const WelcomePage());
          }),
        ],
      );
    }
    final meta = _sections.firstWhere((x) => x.$1 == sec);
    final toggles = _toggles[sec] ?? const <String>[];
    return PageShell(
      title: meta.$2,
      active: 'profile',
      showDock: false,
      headerArt: 'hdr-calls',
      right: bellBtn(context, u),
      children: [
        for (final t in toggles)
          SteelPlate(u: u, child: Row(children: [
            Expanded(child: Text(t, style: ts(u, 42, w: FontWeight.w800))),
            MetalSwitch(u: u, on: _on[t] ?? (t != 'Group invites' && t != 'Two-step verification' && t != 'Screen lock' && t != 'Mentions & reactions'), onChanged: (v) => setState(() => _on[t] = v)),
          ])),
        if (sec == 'profile') ...[
          Center(child: Face(u: u, person: people['me']!, size: 230)),
          SizedBox(height: 26 * u),
          for (final f in [('Display name', 'Aarav Sharma'), ('About', 'Building calm software.'), ('Phone', '+977 98•• ••• 210')]) ...[
            OLabel(f.$1, u: u),
            GlassWell(u: u, child: Text(f.$2, style: ts(u, 38, w: FontWeight.w400, sh: const []))),
          ],
          SizedBox(height: 24 * u),
          ArtBtn(u: u, label: 'Save changes', orange: true, minH: 150, onTap: () => showToast(context, 'Profile saved')),
        ],
        if (sec == 'devices' || sec == 'help')
          SteelPlate(u: u, child: Text(sec == 'devices' ? 'This phone · Active now · Kathmandu' : 'support@systemboom.app', style: ts(u, 38, w: FontWeight.w400, sh: const []))),
      ],
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final u = context.u;
    return Scaffold(
      backgroundColor: const Color(0xFF07090C),
      body: Center(
        child: SizedBox(
          width: u * 941,
          child: Stack(children: [
            const Positioned.fill(child: CarbonBg()),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 48 * u),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(36 * u), child: Image.asset('assets/images/logo-lockup.webp')),
                  SizedBox(height: 50 * u),
                  Text.rich(TextSpan(children: [const TextSpan(text: 'Chat. Call. '), TextSpan(text: 'Trade.', style: TextStyle(color: Color(0xFFFF9A3A)))]), style: ts(u, 76, w: FontWeight.w900)),
                  SizedBox(height: 20 * u),
                  Text('One calm place for conversations, calls and a marketplace — with optional end-to-end privacy.', textAlign: TextAlign.center, style: ts(u, 40, c: const Color(0xFFC3CEDB), w: FontWeight.w400, sh: const [])),
                  SizedBox(height: 50 * u),
                  ArtBtn(u: u, label: 'Continue with phone', icon: Icons.phone_rounded, orange: true, minH: 176, fontPx: 52, onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
                  SizedBox(height: 18 * u),
                  ArtBtn(u: u, label: 'Go anonymous', icon: Icons.masks_rounded, minH: 176, fontPx: 52, onTap: () => showToast(context, 'Anonymous environment')),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
