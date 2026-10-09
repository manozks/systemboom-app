'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Archive, BellOff, Lock, Pin, Search, Trash2, Image as ImageIcon } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Banner, Dialog, Field, gradFor } from '@/components/kit';
import { conversationTitle, isE2EE, isPrivateMode, useConversation, useMessages, useStore } from '@/lib/data/store';
import { clockTime } from '@/lib/data/format';
import { photoOf } from '@/lib/photo';
import { Art, At, K, U, img } from '@/lib/ui';

const initials = (n: string) => n.split(/\s+/).map((w) => w[0]).slice(0, 2).join('').toUpperCase();
const HUES = ['#14a09a', '#7c5cff', '#d94f8a', '#3b82f6', '#c28a1a', '#6d8f2f', '#e5560a'];
const hueOf = (s: string) => HUES[[...s].reduce((a, c) => a + c.charCodeAt(0), 0) % HUES.length];

function Switch2({ on, onChange, label }: { on: boolean; onChange: () => void; label: string }) {
  return <button role="switch" aria-checked={on} aria-label={label} className={`iswitch${on ? ' on' : ''}`} onClick={onChange}><i /></button>;
}

function Label({ text }: { text: string }) {
  return (
    <div style={{ margin: `${U(30)} ${U(-26)} ${U(8)}` }}>
      <Art w={941} h={48} src="info-label">
        <At x={60} y={24} style={{ transform: 'translateY(-50%)', fontSize: K(25), fontWeight: 800, letterSpacing: '0.16em', color: '#d3d8de', textShadow: `0 ${K(2)} ${K(3)} rgba(0,0,0,.9)` }}>{text}</At>
      </Art>
    </div>
  );
}

function Info() {
  const id = useSearchParams().get('id') ?? undefined;
  const router = useRouter();
  const store = useStore();
  const conv = useConversation(id);
  const msgs = useMessages(id);
  const [tab, setTab] = useState<'media' | 'pinned' | 'search'>('media');
  const [q, setQ] = useState('');
  const [del, setDel] = useState(false);
  if (!conv || !id) return <PageShell title="Chat info" active="chats" dock={false}><div className="empty">Conversation not found.</div></PageShell>;
  const users = store.state.users;
  const title = conversationTitle(conv, users);
  const user = conv.userId ? users[conv.userId] : undefined;
  const anon = conv.env === 'anonymous';
  const media = msgs.filter((m) => m.type === 'image' || m.type === 'video');
  const pinned = msgs.filter((m) => m.pinned && !m.deleted);
  const hits = q.trim() ? msgs.filter((m) => m.text?.toLowerCase().includes(q.toLowerCase())) : [];
  const photo = !anon && conv.kind === 'private' && conv.userId ? photoOf(conv.userId, user?.business) : null;
  const face = anon || user?.business ? '#14a09a' : hueOf(title);

  return (
    <PageShell title="Chat info" active="chats" dock={false} bottomPad={120}>
      {/* avatar in a riveted ring */}
      <div style={{ textAlign: 'center', padding: `${U(6)} 0 ${U(8)}` }}>
        <div style={{ position: 'relative', width: U(420), margin: '0 auto' }}>
          <div style={{ position: 'absolute', left: '50%', top: `${(148 / 300) * 100 * (300 / 310) * 1.033}%`, width: '66%', aspectRatio: '1', transform: 'translate(-50%,-50%)', borderRadius: '50%', overflow: 'hidden', background: `radial-gradient(circle at 35% 25%, ${face}, #07302e 120%)`, display: 'grid', placeItems: 'center' }}>
            {photo ? <img src={img(photo)} alt={title} draggable={false} style={{ width: '100%', height: '100%', objectFit: 'cover' }} /> : (
              <span className="chrome-text" style={{ fontSize: U(150), fontWeight: 900, letterSpacing: '-0.02em', filter: 'drop-shadow(0 3px 0 rgba(0,0,0,.5))' }}>{conv.kind === 'group' ? '👥' : initials(title)}</span>
            )}
          </div>
          <Art w={310} h={300} src="info-ring">
            {user?.presence === 'online' && <At x={228} y={232} w={46} h={46} style={{ borderRadius: '50%', background: 'radial-gradient(circle at 35% 30%, #8dffb0, #17c24a 60%, #0a7a28)', border: `${K(4)} solid #0d1117`, boxShadow: '0 0 10px #22c55e' }} />}
          </Art>
        </div>
        <div style={{ fontSize: U(76), fontWeight: 900, lineHeight: 1.1, color: '#fff', textShadow: `0 ${U(3)} ${U(5)} rgba(0,0,0,.8)`, marginTop: U(-4) }}>{title}</div>
        <div style={{ fontSize: U(36), color: '#b9c9ee', marginTop: U(6) }}>{conv.kind === 'group' ? `${conv.participants?.length ?? 0} members` : user?.about ?? user?.phone ?? 'Anonymous contact'}</div>
      </div>

      {isE2EE(conv) && <div style={{ marginBottom: U(20) }}><Banner tone="ok" icon={<Lock />}>{anon ? 'Anonymous environment — always end-to-end encrypted.' : 'Private mode — end-to-end encrypted.'}</Banner></div>}
      {conv.kind === 'private' && !anon && !isPrivateMode(conv) && conv.userId && (
        <button className="icta orange" onClick={() => router.push(`/chat/?id=${store.continuePrivately(conv.userId!)}`)}><Lock />Continue privately</button>
      )}

      <Label text="SETTINGS" />
      {([['Mute notifications', <BellOff key="m" />, !!conv.muted, () => store.toggleMute(id)], ['Pin conversation', <Pin key="p" />, !!conv.pinned, () => store.togglePin(id)], ['Archive', <Archive key="a" />, !!conv.archived, () => store.toggleArchive(id)]] as [string, React.ReactNode, boolean, () => void][]).map(([l, ic, on, fn]) => (
        <div key={l} className="irow"><span className="iico">{ic}</span><span className="isep" /><span className="grow irow-t">{l}</span><Switch2 on={on} onChange={fn} label={l} /></div>
      ))}

      {conv.kind === 'group' && (<>
        <Label text="MEMBERS" />
        {conv.participants?.map((p) => (
          <div key={p.userId} className="irow"><Avatar name={users[p.userId]?.name ?? '?'} size={104} /><span className="isep" /><span className="grow"><span className="irow-t" style={{ display: 'block' }}>{p.userId === store.me ? 'You' : users[p.userId]?.name}</span><span style={{ fontSize: U(30), color: '#9db4e0', textTransform: 'capitalize' }}>{p.role}</span></span></div>
        ))}
      </>)}

      <Label text="SHARED" />
      <div className="ichips">
        {([['media', `Media ${media.length}`], ['pinned', `Pinned ${pinned.length}`], ['search', 'Search']] as const).map(([k, l]) => (
          <button key={k} className={`ichip ${tab === k ? 'on' : 'off'}`} onClick={() => setTab(k)}>{l}</button>
        ))}
      </div>
      <div style={{ minHeight: U(260) }}>
        {tab === 'media' && (media.length
          ? <div className="grid2">{media.map((m) => <div key={m.id} className="pimg" style={{ height: U(260), borderRadius: U(26), background: gradFor(m.image?.url ?? m.video?.thumb ?? 'grad-1') }}><ImageIcon style={{ opacity: 0.6, width: '26%', height: '26%' }} /></div>)}</div>
          : <div className="iempty"><span className="itile"><ImageIcon /></span><span>No shared media yet</span></div>)}
        {tab === 'pinned' && (pinned.length
          ? pinned.map((m) => <div key={m.id} className="irow"><span className="iico"><Pin /></span><span className="isep" /><span className="grow"><span className="irow-t ellip" style={{ display: 'block', fontSize: U(38) }}>{m.text ?? m.image?.caption ?? m.type}</span><span style={{ fontSize: U(28), color: '#9db4e0' }}>{clockTime(m.createdAt)}</span></span></div>)
          : <div className="iempty"><span className="itile"><Pin /></span><span>No pinned messages</span></div>)}
        {tab === 'search' && (<>
          <Field><input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search in this chat" /></Field>
          <div style={{ height: U(14) }} />
          {hits.map((m) => <div key={m.id} className="irow"><span className="iico"><Search /></span><span className="isep" /><span className="grow"><span className="irow-t ellip" style={{ display: 'block', fontSize: U(38) }}>{m.text}</span><span style={{ fontSize: U(28), color: '#9db4e0' }}>{clockTime(m.createdAt)}</span></span></div>)}
          {q && !hits.length && <div className="iempty"><span>No matches</span></div>}
        </>)}
      </div>

      <button className="icta red" onClick={() => setDel(true)}><Trash2 />Delete conversation</button>
      <Dialog open={del} onClose={() => setDel(false)} title="Delete conversation?" text="Removes it from your history only." onConfirm={() => { store.deleteConversation(id); router.replace('/chats/'); }} />
    </PageShell>
  );
}

export default function Page() { return <Suspense><Info /></Suspense>; }
