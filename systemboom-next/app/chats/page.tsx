'use client';

import { Suspense, useMemo, useRef, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { conversationTitle, isE2EE, latestMessage, useConversationList, useStore } from '@/lib/data/store';
import { listTime } from '@/lib/data/format';
import type { Message } from '@/lib/data/types';
import { Archive, ArchiveRestore, Bell, BellOff, CheckCheck, MessageCircle, MoreVertical, Mic, Pin, Settings2, Trash2, Users } from 'lucide-react';
import { ActionSheet, Dialog, Empty } from '@/components/kit';
import type { Conversation } from '@/lib/data/types';
import { PageShell } from '@/components/PageShell';
import { ListHeading, SearchBar, SegTabs } from '@/components/Controls';
import { Art, At, K, Press, img, useToast } from '@/lib/ui';

type Chat = { id: string; name: string; initials: string; preview: string; time: string; unread: number; online?: boolean; group?: boolean; mic?: boolean; pinned?: boolean; muted?: boolean; typing?: boolean; archived?: boolean };

const preview = (m?: Message) => {
  if (!m) return 'No messages yet';
  if (m.deleted) return 'Message deleted';
  switch (m.type) {
    case 'text': return m.text ?? '';
    case 'image': return '📷 ' + (m.image?.caption ?? 'Photo');
    case 'video': return '🎬 Video';
    case 'voice': return 'Voice message';
    case 'document': return '📄 ' + (m.document?.name ?? 'Document');
    case 'contact': return '👤 Contact';
    case 'location': return '📍 Location';
    case 'product': return '🛍 ' + (m.product?.title ?? 'Product');
    case 'link': return '🔗 ' + (m.link?.title ?? 'Link');
    case 'offer': return '💬 Offer';
    case 'order': return '📦 Order update';
    default: return m.text ?? '';
  }
};

function ChatsScreen() {
  const toast = useToast();
  const router = useRouter();
  const archivedView = useSearchParams().get('archived') === '1';
  const store = useStore();
  const { state } = store;
  const list = useConversationList({ archived: archivedView });
  const archivedList = useConversationList({ archived: true });
  const [q, setQ] = useState('');
  const [tab, setTab] = useState(0);
  const [menuFor, setMenuFor] = useState<Conversation | null>(null);
  const [deleteFor, setDeleteFor] = useState<Conversation | null>(null);
  const [topMenu, setTopMenu] = useState(false);
  const timer = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);
  const archivedCount = archivedList.length;
  const source = !archivedView && q.trim() ? [...list, ...archivedList] : list;
  const CHATS: Chat[] = useMemo(() => source.map((c) => {
    const name = conversationTitle(c, state.users);
    const last = latestMessage(c, state.messages);
    const u = c.userId ? state.users[c.userId] : undefined;
    const who = c.kind === 'group' && last && last.type !== 'system' ? `${last.authorId === 'me' ? 'You' : state.users[last.authorId]?.name?.split(' ')[0]}: ` : '';
    return { id: c.id, name, initials: name.split(' ').map((w) => w[0]).slice(0, 2).join('').toUpperCase(), preview: state.typing[c.id] ? 'typing…' : (isE2EE(c) ? '🔒 ' : '') + (last ? who + preview(last) : 'Tap to start chatting'), time: last ? listTime(last.createdAt) : '', unread: c.unread, online: u?.presence === 'online', group: c.kind === 'group', mic: last?.type === 'voice', pinned: c.pinned, muted: c.muted, typing: state.typing[c.id], archived: c.archived };
  }), [source, state.users, state.messages, state.typing]);
  const items = useMemo(
    () => CHATS.filter((c) => (tab === 1 ? c.unread > 0 : tab === 2 ? !!c.group : true) && c.name.toLowerCase().includes(q.trim().toLowerCase())),
    [q, tab, CHATS],
  );
  const conv = (id: string) => state.conversations.find((c) => c.id === id)!;
  const press = (id: string) => ({
    onPointerDown: () => { timer.current = setTimeout(() => setMenuFor(conv(id)), 520); },
    onPointerUp: () => clearTimeout(timer.current),
    onPointerLeave: () => clearTimeout(timer.current),
    onContextMenu: (e: React.MouseEvent) => { e.preventDefault(); setMenuFor(conv(id)); },
  });

  return (
    <PageShell title={archivedView ? 'Archived' : 'Chats'} active="chats" dock={!archivedView}>
      <SearchBar value={q} onChange={setQ} placeholder="Search conversations" />
      <div style={{ height: 'calc(22 * var(--u))' }} />
      <SegTabs index={tab} onChange={setTab} items={[{ label: 'All' }, { label: 'Unread' }, { label: 'Groups' }]} />
      <div style={{ height: 'calc(26 * var(--u))' }} />

      {!archivedView && <Press onClick={() => router.push('/new-chat/')} style={{ borderRadius: 'calc(34 * var(--u))' }}>
        <Art w={856} h={215} src="cta" style={{ filter: 'drop-shadow(0 10px 12px rgba(0,0,0,.7)) drop-shadow(0 0 16px rgba(255,120,30,.35))' }}>
          <At x={40} y={24} w={168} h={168}>
            <div className="chrome-ring ring-spin" style={{ width: '100%', height: '100%', padding: K(9), boxShadow: `0 0 ${K(26)} rgba(255,122,26,.6)` }}>
              <div style={{ width: '100%', height: '100%', borderRadius: '50%', background: 'radial-gradient(circle at 50% 35%,#3a2410,#0a0604)', padding: K(14) }}>
                <div style={{ width: '100%', height: '100%', borderRadius: '50%', border: `${K(5)} solid #ff8a2a`, boxShadow: `0 0 ${K(16)} #ff7814, inset 0 0 ${K(16)} #ff7814`, display: 'grid', placeItems: 'center', color: '#ffc978' }}>
                  <MessageCircle style={{ width: '48%', height: '48%', fill: '#ffc978' }} strokeWidth={1.5} />
                </div>
              </div>
            </div>
          </At>
          <At x={244} y={38} r={190} style={{ left: K(244) }}>
            <div className="gold-text" style={{ fontSize: K(60), fontWeight: 800, lineHeight: 1.1 }}>New Chat</div>
            <div style={{ fontSize: K(30), lineHeight: 1.2, marginTop: K(6) }}>Message a friend, a group or a store.</div>
          </At>
        </Art>
      </Press>}

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: 'calc(34 * var(--u)) calc(8 * var(--u)) calc(16 * var(--u))' }}>
        <span style={{ fontSize: 'calc(40 * var(--u))', fontWeight: 800, letterSpacing: '.4px' }}>{archivedView ? 'ARCHIVED CHATS' : 'RECENT CHATS'}</span>
        <button className="rowmenu" aria-label="More options" onClick={() => setTopMenu(true)}><MoreVertical style={{ width: '60%', height: '60%' }} /></button>
      </div>
      {!archivedView && archivedCount > 0 && tab === 0 && !q && (
        <button className="mp dark lr" onClick={() => router.push('/chats/?archived=1')}>
          <span className="iico"><Archive /></span><span className="grow"><span className="lr-t">Archived</span></span><span className="cstat">{archivedCount}</span>
        </button>
      )}
      {items.map((c) => (
        <Press key={c.id} onClick={() => { store.markRead(c.id); router.push(`/chat/?id=${c.id}`); }} style={{ marginBottom: 'calc(14 * var(--u))', borderRadius: 'calc(34 * var(--u))' }} {...press(c.id)}>
          <Art w={856} h={150} src="cta-blank-wide" style={{ filter: 'drop-shadow(0 8px 10px rgba(0,0,0,.65)) drop-shadow(0 0 14px rgba(255,140,50,.28))' }}>
            <At x={44} y={20} w={110} h={110}>
              <div className="gold-ring" style={{ width: '100%', height: '100%', padding: K(5), boxShadow: `0 0 ${K(14)} rgba(255,122,26,0.6)` }}>
                <div style={{ width: '100%', height: '100%', borderRadius: '50%', background: '#0a0604', padding: K(3), overflow: 'hidden' }}>
                  {(
                    <div style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', background: 'radial-gradient(circle at 50% 30%,#4a2a10,#0e0804)', color: '#ffe2b8', fontWeight: 900, fontSize: K(34), textShadow: `0 0 ${K(8)} #ff8c28` }}>
                      {c.group ? <Users style={{ width: '54%', height: '54%' }} strokeWidth={1.8} /> : c.initials}
                    </div>
                  )}
                </div>
              </div>
              {c.online && <span style={{ position: 'absolute', right: 0, bottom: K(2), width: K(30), height: K(30), borderRadius: '50%', background: '#22c55e', border: `${K(3.5)} solid #0d1117`, boxShadow: '0 0 8px #22c55eaa' }} />}
            </At>
            <At x={190} y={34} r={220} style={{ left: K(190) }}>
              <div style={{ fontSize: K(37), fontWeight: 800, lineHeight: 1.15, background: 'linear-gradient(180deg,#fff,#fff2dc,#e8c99a)', WebkitBackgroundClip: 'text', backgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>{c.name}</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: K(8), marginTop: K(8), fontSize: K(29) }}>
                {c.mic && <Mic style={{ width: K(32), height: K(32), flex: 'none' }} />}
                <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', color: c.typing ? '#5dff9a' : undefined }}>{c.preview}</span>
              </div>
            </At>
            <At x={0} y={26} w={170} style={{ right: K(66), left: 'auto', textAlign: 'right' }}>
              <div style={{ fontSize: K(26), color: '#e9eef3', display: 'flex', gap: K(8), justifyContent: 'flex-end', alignItems: 'center' }}>{c.pinned && <Pin style={{ width: K(26), height: K(26), color: '#ffb866' }} />}{c.muted && <BellOff style={{ width: K(26), height: K(26), color: '#9fb0c2' }} />}{c.time}</div>
              {c.unread > 0 && <span className="badge" style={{ display: 'inline-grid', marginTop: K(8), minWidth: K(48), height: K(48), padding: `0 ${K(10)}`, fontSize: K(26) }}>{c.unread}</span>}
            </At>
            <At x={0} y={44} w={56} h={62} style={{ right: K(10), left: 'auto' }}><span role="button" aria-label="Conversation options" onClick={(e) => { e.stopPropagation(); setMenuFor(conv(c.id)); }} style={{ display: 'grid', placeItems: 'center', width: '100%', height: '100%' }}><MoreVertical style={{ width: '90%', height: '90%' }} strokeWidth={2} /></span></At>
          </Art>
        </Press>
      ))}
      {items.length === 0 && (
        <Empty icon={tab === 2 && !q ? <Users /> : <MessageCircle />}
          title={q ? 'No matches' : archivedView ? 'No archived chats' : tab === 1 ? 'You’re all caught up' : tab === 2 ? 'No group chats yet' : 'No conversations yet'}
          sub={q ? 'Try a different name or keyword.' : archivedView ? 'Chats you archive will appear here, out of the way but never lost.' : tab === 1 ? 'Every conversation is read. Enjoy the calm.' : tab === 2 ? 'Create a group to collaborate with several people.' : 'Start your first conversation — everything begins with a chat.'} />
      )}

      <ActionSheet open={!!menuFor} onClose={() => setMenuFor(null)} title={menuFor ? conversationTitle(menuFor, state.users) : undefined}
        actions={menuFor ? [
          { label: menuFor.pinned ? 'Unpin' : 'Pin', icon: <Pin />, onSelect: () => { store.togglePin(menuFor.id); toast(menuFor.pinned ? 'Unpinned' : 'Pinned to top'); } },
          { label: menuFor.muted ? 'Unmute' : 'Mute', icon: menuFor.muted ? <Bell /> : <BellOff />, onSelect: () => { store.toggleMute(menuFor.id); toast(menuFor.muted ? 'Unmuted' : 'Muted'); } },
          { label: menuFor.unread ? 'Mark as read' : 'Mark as unread', icon: <CheckCheck />, onSelect: () => (menuFor.unread ? store.markRead(menuFor.id) : store.markUnread(menuFor.id)) },
          { label: menuFor.archived ? 'Unarchive' : 'Archive', icon: menuFor.archived ? <ArchiveRestore /> : <Archive />, onSelect: () => { store.toggleArchive(menuFor.id); toast(menuFor.archived ? 'Unarchived' : 'Archived'); } },
          { label: 'Delete conversation', icon: <Trash2 />, danger: true, onSelect: () => setDeleteFor(menuFor) },
        ] : []} />
      <ActionSheet open={topMenu} onClose={() => setTopMenu(false)}
        actions={[
          { label: 'New group', icon: <Users />, onSelect: () => router.push('/new-group/') },
          { label: archivedView ? 'Back to chats' : 'Archived chats', icon: <Archive />, onSelect: () => router.push(archivedView ? '/chats/' : '/chats/?archived=1') },
          { label: 'Settings', icon: <Settings2 />, onSelect: () => router.push('/settings/') },
        ]} />
      <Dialog open={!!deleteFor} onClose={() => setDeleteFor(null)} title="Delete conversation?"
        text={deleteFor?.kind === 'group' ? 'Removes the group from your list only. The group continues.' : 'Removes it from your chat list only.'}
        onConfirm={() => { if (deleteFor) { store.deleteConversation(deleteFor.id); toast('Conversation removed from your chat list'); } setDeleteFor(null); }} />
    </PageShell>
  );
}

export default function Page() { return <Suspense><ChatsScreen /></Suspense>; }
