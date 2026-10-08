'use client';

import { useMemo, useState } from 'react';
import { ChevronRight, MessageCircle, Mic, Users } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { ListHeading, SearchBar, SegTabs } from '@/components/Controls';
import { Art, At, K, Press, img, useToast } from '@/lib/ui';

type Chat = { name: string; initials: string; preview: string; time: string; unread: number; online?: boolean; photo?: string; group?: boolean; mic?: boolean; logo?: string };

const CHATS: Chat[] = [
  { name: 'Priya Singh', initials: 'PS', preview: 'Hey! Are we still on for the meeting?', time: '08:28 AM', unread: 3, online: true, photo: 'cf1' },
  { name: 'Rohit Verma', initials: 'RV', preview: 'Shared a photo', time: '08:12 AM', unread: 1, online: true, photo: 'cf2' },
  { name: 'Project Team', initials: '', preview: 'Amit: Updated the file', time: '07:45 AM', unread: 12, group: true },
  { name: 'Neha Kapoor', initials: 'NK', preview: 'Thanks!', time: 'Yesterday', unread: 0, photo: 'cf4' },
  { name: 'Karan Mehta', initials: 'KM', preview: 'Voice message', time: 'Yesterday', unread: 0, photo: 'cf5', mic: true },
  { name: 'System Updates', initials: 'S', preview: 'New features are coming soon!', time: 'Yesterday', unread: 0, logo: 'S' },
  { name: 'Anjali Rao', initials: 'AR', preview: 'Let’s connect tomorrow.', time: 'Mon', unread: 0 },
];

export default function ChatsPage() {
  const toast = useToast();
  const [q, setQ] = useState('');
  const [tab, setTab] = useState(0);
  const items = useMemo(
    () => CHATS.filter((c) => (tab === 1 ? c.unread > 0 : tab === 2 ? c.group : true) && `${c.name} ${c.preview}`.toLowerCase().includes(q.toLowerCase())),
    [q, tab],
  );

  return (
    <PageShell title="Chats" active="chats">
      <SearchBar value={q} onChange={setQ} placeholder="Search conversations" />
      <div style={{ height: 'calc(22 * var(--u))' }} />
      <SegTabs index={tab} onChange={setTab} items={[{ label: 'All' }, { label: 'Unread' }, { label: 'Groups' }]} />
      <div style={{ height: 'calc(26 * var(--u))' }} />

      <Press onClick={() => toast('New chat')} style={{ borderRadius: 'calc(34 * var(--u))' }}>
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
      </Press>

      <ListHeading title="RECENT CHATS" onAction={() => toast('See all chats')} />
      {items.map((c) => (
        <Press key={c.name} onClick={() => toast(`Opening ${c.name}`)} style={{ marginBottom: 'calc(14 * var(--u))', borderRadius: 'calc(34 * var(--u))' }}>
          <Art w={856} h={150} src="cta-blank-wide" style={{ filter: 'drop-shadow(0 8px 10px rgba(0,0,0,.65)) drop-shadow(0 0 14px rgba(255,140,50,.28))' }}>
            <At x={44} y={20} w={110} h={110}>
              <div className="gold-ring" style={{ width: '100%', height: '100%', padding: K(5), boxShadow: `0 0 ${K(c.photo ? 8 : 14)} rgba(255,122,26,${c.photo ? 0.35 : 0.75})` }}>
                <div style={{ width: '100%', height: '100%', borderRadius: '50%', background: '#0a0604', padding: K(3), overflow: 'hidden' }}>
                  {c.photo ? (
                    <img src={img(c.photo)} alt={c.name} style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }} />
                  ) : (
                    <div style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', background: 'radial-gradient(circle at 50% 30%,#4a2a10,#0e0804)', color: '#ffe2b8', fontWeight: 900, fontSize: K(c.logo ? 60 : 34), textShadow: `0 0 ${K(8)} #ff8c28` }}>
                      {c.group ? <Users style={{ width: '54%', height: '54%' }} strokeWidth={1.8} /> : c.logo ?? c.initials}
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
                <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{c.preview}</span>
              </div>
            </At>
            <At x={0} y={26} w={170} style={{ right: K(66), left: 'auto', textAlign: 'right' }}>
              <div style={{ fontSize: K(26), color: '#e9eef3' }}>{c.time}</div>
              {c.unread > 0 && <span className="badge" style={{ display: 'inline-grid', marginTop: K(8), minWidth: K(48), height: K(48), padding: `0 ${K(10)}`, fontSize: K(26) }}>{c.unread}</span>}
            </At>
            <At x={0} y={52} w={46} h={46} style={{ right: K(18), left: 'auto' }}><ChevronRight style={{ width: '100%', height: '100%' }} strokeWidth={2} /></At>
          </Art>
        </Press>
      ))}
      {items.length === 0 && <p style={{ textAlign: 'center', color: '#8896a6', padding: 'calc(60 * var(--u))' }}>No conversations found</p>}
    </PageShell>
  );
}
