'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Archive, BellOff, Ban, Crown, Flag, Lock, LogOut, Megaphone, Phone, Pin, PinOff, Search, ShieldCheck, Trash2, UserPlus, Video, Image as ImageIcon } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Banner, Btn, Dialog, Field, gradFor } from '@/components/kit';
import { conversationTitle, isE2EE, isPrivateMode, useConversation, useMessages, useStore } from '@/lib/data/store';
import { clockTime } from '@/lib/data/format';
import { photoOf } from '@/lib/photo';
import { Art, At, K, U, img, useToast } from '@/lib/ui';

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
  const [confirm, setConfirm] = useState<null | 'block' | 'leave' | 'delete'>(null);
  const toast = useToast();
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
  const myRole = conv.participants?.find((p) => p.userId === store.me)?.role;
  const canAdmin = myRole === 'owner' || myRole === 'admin';
  const callBase = `/call/?chat=${id}`;

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

      <div className="grid2" style={{ gridTemplateColumns: 'repeat(3,1fr)', margin: `${U(6)} 0 ${U(22)}` }}>
        <Btn kind="steel" size="sm" icon={<Phone />} onClick={() => router.push(`${callBase}&kind=voice`)}>Audio</Btn>
        <Btn kind="steel" size="sm" icon={<Video />} onClick={() => router.push(`${callBase}&kind=video`)}>Video</Btn>
        <Btn kind="steel" size="sm" icon={<Search />} onClick={() => router.push(`/chat-search/?id=${id}`)}>Search</Btn>
      </div>
      {user?.about && !anon && <div className="mp dark lr" style={{ marginBottom: U(20) }}><span className="grow"><span className="lr-s">About</span><span className="lr-t" style={{ fontWeight: 500 }}>{user.about}</span></span></div>}
      {!isE2EE(conv) && !anon && <div style={{ marginBottom: U(20) }}><Banner icon={<ShieldCheck />}><b>Standard conversation.</b> Secured in transit and at rest. Privacy is permanent for this conversation.</Banner></div>}
      {isE2EE(conv) && <div style={{ marginBottom: U(20) }}><Banner tone="ok" icon={<Lock />}>{anon ? 'Anonymous environment — always end-to-end encrypted.' : 'Private mode — end-to-end encrypted.'}</Banner></div>}
      {conv.kind === 'private' && !anon && !isPrivateMode(conv) && conv.userId && (
        <button className="icta orange" onClick={() => router.push(`/chat/?id=${store.continuePrivately(conv.userId!)}`)}><Lock />Continue privately</button>
      )}

      <Label text="SETTINGS" />
      {([['Mute notifications', <BellOff key="m" />, !!conv.muted, () => store.toggleMute(id)], ['Pin conversation', <Pin key="p" />, !!conv.pinned, () => store.togglePin(id)], ['Archive', <Archive key="a" />, !!conv.archived, () => store.toggleArchive(id)]] as [string, React.ReactNode, boolean, () => void][]).map(([l, ic, on, fn]) => (
        <div key={l} className="irow"><span className="iico">{ic}</span><span className="isep" /><span className="grow irow-t">{l}</span><Switch2 on={on} onChange={fn} label={l} /></div>
      ))}

      {conv.kind === 'group' && canAdmin && (
        <div className="irow"><span className="iico"><Megaphone /></span><span className="isep" /><span className="grow"><span className="irow-t" style={{ display: 'block' }}>Announcement mode</span><span style={{ fontSize: U(30), color: '#9db4e0' }}>Only admins can post</span></span><Switch2 on={!!conv.announcementMode} onChange={() => { store.setAnnouncementMode(id, !conv.announcementMode); toast(!conv.announcementMode ? 'Announcement mode on — only admins can post' : 'Announcement mode off'); }} label="Announcement mode" /></div>
      )}

      {conv.kind === 'group' && (<>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <Label text={`MEMBERS ${conv.participants?.length ?? 0}`} />
          {canAdmin && <Btn kind="ghost" size="sm" icon={<UserPlus />} onClick={() => toast('Add members (prototype)')}>Add</Btn>}
        </div>
        {conv.participants?.map((p) => (
          <div key={p.userId} className="irow"><Avatar name={users[p.userId]?.name ?? '?'} size={104} presence={users[p.userId]?.presence} /><span className="isep" /><span className="grow"><span className="irow-t" style={{ display: 'block' }}>{p.userId === store.me ? 'You' : users[p.userId]?.name}</span>{users[p.userId]?.about && <span style={{ fontSize: U(30), color: '#9db4e0' }}>{users[p.userId]?.about}</span>}</span>{p.role !== 'member' && <span className="pill" style={{ ['--t' as string]: p.role === 'owner' ? '#ffb02e' : '#5ab8f2' }}>{p.role === 'owner' ? <><Crown /> Owner</> : 'Admin'}</span>}</div>
        ))}
      </>)}

      <Label text="SHARED" />
      <div className="ichips">
        {([['media', `Media ${media.length}`], ['pinned', `Pinned ${pinned.length}`], ['search', 'Search']] as const).map(([k, l]) => (
          <button key={k} className={`ichip ${tab === k ? 'on' : 'off'}`} onClick={() => (k === 'search' ? router.push(`/chat-search/?id=${id}`) : setTab(k))}>{l}</button>
        ))}
      </div>
      <div style={{ minHeight: U(260) }}>
        {tab === 'media' && (media.length
          ? <div className="grid2">{media.map((m) => <div key={m.id} className="pimg" style={{ height: U(260), borderRadius: U(26), background: gradFor(m.image?.url ?? m.video?.thumb ?? 'grad-1') }}><ImageIcon style={{ opacity: 0.6, width: '26%', height: '26%' }} /></div>)}</div>
          : <div className="iempty"><span className="itile"><ImageIcon /></span><span>No shared media yet</span></div>)}
        {tab === 'pinned' && (pinned.length
          ? pinned.map((m) => <div key={m.id} className="irow"><span className="iico"><Pin /></span><span className="isep" /><span className="grow"><span className="irow-t ellip" style={{ display: 'block', fontSize: U(38) }}>{m.text ?? m.image?.caption ?? m.type}</span><span style={{ fontSize: U(28), color: '#9db4e0' }}>{clockTime(m.createdAt)}</span></span><button aria-label="Unpin message" onClick={() => { store.togglePinMessage(m.id); toast('Unpinned'); }}><PinOff style={{ width: U(50), height: U(50), color: '#ffb866' }} /></button></div>)
          : <div className="iempty"><span className="itile"><Pin /></span><span>No pinned messages</span></div>)}
        {tab === 'search' && (<>
          <Field><input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search in this chat" /></Field>
          <div style={{ height: U(14) }} />
          {hits.map((m) => <div key={m.id} className="irow"><span className="iico"><Search /></span><span className="isep" /><span className="grow"><span className="irow-t ellip" style={{ display: 'block', fontSize: U(38) }}>{m.text}</span><span style={{ fontSize: U(28), color: '#9db4e0' }}>{clockTime(m.createdAt)}</span></span></div>)}
          {q && !hits.length && <div className="iempty"><span>No matches</span></div>}
        </>)}
      </div>

      <div className="grid2" style={{ gridTemplateColumns: '1fr 1fr', marginBottom: U(6) }}>
        <Btn kind="ghost" size="sm" icon={<Pin />} onClick={() => router.push(`/chat-pinned/?id=${id}`)}>Pinned</Btn>
        <Btn kind="ghost" size="sm" icon={<ImageIcon />} onClick={() => router.push(`/chat-media/?id=${id}`)}>Media, links & docs</Btn>
      </div>
      {conv.kind === 'private' && !anon ? (
        <div className="grid2" style={{ gridTemplateColumns: '1fr 1fr', marginTop: U(16) }}>
          <Btn kind="ghost" size="sm" icon={<Ban />} onClick={() => setConfirm('block')}>Block {user?.name?.split(' ')[0]}</Btn>
          <Btn kind="ghost" size="sm" icon={<Flag />} onClick={() => toast(`Report submitted for ${user?.name}`)}>Report</Btn>
        </div>
      ) : conv.kind === 'group' ? (
        <div style={{ marginTop: U(16) }}><Btn kind="ghost" block size="sm" icon={<LogOut />} onClick={() => setConfirm('leave')}>Leave group</Btn></div>
      ) : null}
      <button className="icta red" onClick={() => setConfirm('delete')}><Trash2 />Delete conversation</button>
      <Dialog open={!!confirm} onClose={() => setConfirm(null)}
        title={confirm === 'block' ? `Block ${user?.name?.split(' ')[0]}?` : confirm === 'leave' ? 'Leave group?' : 'Delete conversation?'}
        text={confirm === 'block' ? 'They won’t be able to message or call you.' : confirm === 'leave' ? 'You’ll stop receiving messages.' : conv.kind === 'group' ? 'Removes the group from your list only.' : `Removes it from your list only. ${title} is not affected.`}
        confirm={confirm === 'block' ? 'Block' : confirm === 'leave' ? 'Leave' : 'Delete'}
        onConfirm={() => {
          if (confirm === 'delete') { store.deleteConversation(id); toast('Conversation removed from your chat list'); }
          else toast(confirm === 'block' ? `${user?.name} blocked` : 'You left the group');
          router.replace('/chats/');
        }} />
    </PageShell>
  );
}

export default function Page() { return <Suspense><Info /></Suspense>; }
