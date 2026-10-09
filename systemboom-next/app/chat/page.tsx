'use client';

import { Suspense, useEffect, useMemo, useRef, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Check, CheckCheck, Copy, Download, Edit3, FileText, Link2, Lock, MapPin, Mic, MoreVertical, Paperclip, Phone, Pin, Play, Plus, Send, Smile, Star, Trash2, User as UserIcon, Video, X, ShoppingBag, Tag, Package, Clock, ChevronLeft, Image as ImageIcon, Camera, ShoppingCart } from 'lucide-react';
import { PageShell, ChromeBtn } from '@/components/PageShell';
import { Avatar, Banner, Btn, Dialog, IBtn, ProdImg, Sheet, gradFor } from '@/components/kit';
import { conversationTitle, isE2EE, useConversation, useMessages, useStore, useProducts } from '@/lib/data/store';
import { clockTime, dayLabel, money } from '@/lib/data/format';
import type { Message } from '@/lib/data/types';
import { Art, At, K, Press, U, img, useToast } from '@/lib/ui';
import { photoOf } from '@/lib/photo';

const EMOJI = ['👍', '❤️', '😂', '😮', '🙏', '🔥'];
function Face({ id, name, size = 112, business, anon, group }: { id: string; name: string; size?: number; business?: boolean; anon?: boolean; group?: boolean }) {
  const ph = anon || group ? null : photoOf(id, business);
  return ph
    ? <img className="photo" src={img(ph)} alt={name} draggable={false} style={{ width: U(size), height: U(size) }} />
    : <Avatar name={name} size={size} anon={anon} group={group} />;
}

function Ticks({ s }: { s: Message['status'] }) {
  const st = { width: U(28), height: U(28) };
  if (s === 'read') return <CheckCheck style={{ ...st, color: '#ff8a2a' }} />;
  if (s === 'delivered') return <CheckCheck style={st} />;
  if (s === 'sending') return <Clock style={st} />;
  if (s === 'failed') return <X style={{ ...st, color: '#ff6a5a' }} />;
  return <Check style={st} />;
}

function Body({ m, mine, onOpen }: { m: Message; mine: boolean; onOpen: (path: string) => void }) {
  const store = useStore();
  const { state } = store;
  if (m.deleted) return <i style={{ opacity: 0.7 }}>🚫 This message was deleted</i>;
  const reply = m.replyToId ? state.messages[m.replyToId] : undefined;
  const wrap = (c: React.ReactNode) => <>{reply && <div style={{ borderLeft: `${U(6)} solid #ffb866`, paddingLeft: U(14), marginBottom: U(10), opacity: 0.85, fontSize: U(26) }}>{reply.text ?? reply.type}</div>}{c}</>;
  switch (m.type) {
    case 'text': return wrap(<span>{m.text}{m.editedAt && <em style={{ opacity: 0.7, fontSize: U(22) }}> · edited</em>}</span>);
    case 'image':
      return wrap(<div><div className="pimg" style={{ width: U(520), height: U(340), borderRadius: U(22), background: gradFor(m.image?.url ?? 'grad-1') }}><Package style={{ width: '20%', height: '20%', opacity: 0.6 }} /></div>{m.image?.caption && <div style={{ marginTop: U(10) }}>{m.image.caption}</div>}</div>);
    case 'video':
      return wrap(<div className="pimg" style={{ width: U(520), height: U(300), borderRadius: U(22), background: gradFor(m.video?.thumb ?? 'grad-2') }}><Play style={{ width: '16%', height: '16%' }} /><span style={{ position: 'absolute', right: U(14), bottom: U(10), fontSize: U(24) }}>{m.video?.duration}</span></div>);
    case 'voice': {
      const w = m.voice?.waveform ?? [3, 6, 9, 5, 8, 12, 7, 4, 9, 6, 3, 8];
      const bars = Array.from({ length: 34 }, (_, i) => w[i % w.length]);
      return wrap(<div className="rowflex" style={{ gap: U(20), minWidth: U(470) }}><span className="playbtn"><Play /></span><div className="waveform" style={{ flex: 1, height: U(100) }}>{bars.map((h, i) => <i key={i} className={i > 18 ? 'off' : ''} style={{ height: U(8 + h * 6) }} />)}</div><span style={{ fontSize: U(32), whiteSpace: 'nowrap' }}>{m.voice?.duration}</span></div>);
    }
    case 'document': {
      const ext = (m.document?.ext ?? '').toUpperCase();
      return wrap(
        <div className="rowflex" style={{ gap: U(22), alignItems: 'center', width: '100%' }}>
          <img src={img('doc-thumb')} alt="" draggable={false} style={{ width: U(230), height: U(160), flex: 'none', objectFit: 'cover', borderRadius: U(22), border: `${U(3)} solid rgba(255,255,255,.25)`, boxShadow: `0 0 ${U(14)} rgba(255,130,30,.4)` }} />
          <div className="grow" style={{ minWidth: 0 }}>
            <div className="rowflex" style={{ gap: U(16), alignItems: 'flex-start' }}>
              {ext === 'PPTX' || ext === 'PPT' ? <span className="ppt" style={{ width: U(62), height: U(70), fontSize: U(42) }}>P</span> : <FileText style={{ width: U(56), height: U(56), color: '#ffb866', flex: 'none' }} />}
              <div style={{ minWidth: 0, flex: 1 }}><div style={{ fontWeight: 600, fontSize: U(30) }} className="ellip">{m.document?.name}</div><div style={{ fontSize: U(27), color: '#cdd5de', marginTop: U(4) }}>{m.document?.size} &nbsp;•&nbsp; {ext}</div></div>
            </div>
            <div style={{ textAlign: 'right', marginTop: U(8) }}><span className="dlbtn" style={{ display: 'inline-grid' }}><Download /></span></div>
          </div>
        </div>);
    }
    case 'contact':
      return wrap(<div className="rowflex"><span className="ibtn sm"><UserIcon /></span><div><div style={{ fontWeight: 800 }}>{m.contact?.name}</div><div style={{ fontSize: U(26), opacity: 0.85 }}>{m.contact?.phone}</div></div></div>);
    case 'location':
      return wrap(<div className="rowflex"><span className="ibtn sm"><MapPin /></span><div><div style={{ fontWeight: 800 }}>{m.location?.label}</div><div style={{ fontSize: U(26), opacity: 0.85 }}>{m.location?.area}</div></div></div>);
    case 'link':
      return wrap(<div><div style={{ fontWeight: 800 }}>{m.link?.title}</div><div style={{ fontSize: U(26), opacity: 0.9 }}>{m.link?.desc}</div><div className="rowflex" style={{ gap: U(8), marginTop: U(8), fontSize: U(24), opacity: 0.8 }}><Link2 style={{ width: U(26), height: U(26) }} />{m.link?.host}</div></div>);
    case 'product':
      return (
        <button className="rowflex" style={{ textAlign: 'left', minWidth: U(440) }} onClick={() => m.product?.productId && onOpen(`/product/?id=${m.product.productId}`)}>
          <ProdImg k={m.product?.image ?? 'p1'} size={120} radius={22} />
          <div className="grow"><div style={{ fontWeight: 800 }}>{m.product?.title}</div><div className="price" style={{ fontSize: U(32) }}>{m.product?.price}</div><div style={{ fontSize: U(24), opacity: 0.85 }}>{m.product?.availability} · {m.product?.seller}</div></div>
        </button>
      );
    case 'offer': {
      const o = m.offer!;
      return (
        <div style={{ minWidth: U(440) }}>
          <div className="rowflex" style={{ gap: U(10), fontWeight: 800 }}><Tag style={{ width: U(34), height: U(34) }} />{o.by === 'buyer' ? 'Your offer' : 'Seller offer'}</div>
          <div style={{ margin: `${U(8)} 0` }}>{o.title}</div>
          <div style={{ fontWeight: 900, fontSize: U(36) }}>{money(o.price)} × {o.qty}</div>
          {o.note && <div style={{ fontSize: U(26), opacity: 0.85 }}>“{o.note}”</div>}
          <div style={{ marginTop: U(10), fontSize: U(26), fontWeight: 800, color: o.status === 'accepted' ? '#8dffb4' : o.status === 'declined' ? '#ff9a8f' : '#ffe3b0' }}>
            {o.status === 'accepted' ? '✓ Accepted' : o.status === 'declined' ? '✗ Declined' : '… Waiting for seller'}
          </div>
          {o.status === 'accepted' && mine && !Object.values(state.orders).some((x) => x.conversationId === m.conversationId && x.items[0]?.productId === o.productId && x.items[0]?.unitPrice === o.price) && (
            <button className="btn primary sm" style={{ marginTop: U(14) }} onClick={(e) => {
              e.stopPropagation();
              const conv = state.conversations.find((c) => c.id === m.conversationId);
              const prod = state.products.find((p) => p.id === o.productId);
              const oid = store.createOrder({ conversationId: m.conversationId, sellerId: conv?.userId ?? prod?.sellerId ?? 'u_boom', items: [{ productId: o.productId, title: o.title, image: prod?.image ?? 'p1', unitPrice: o.price, qty: o.qty }], deliveryFee: 150, address: 'Baneshwor, Kathmandu' });
              onOpen(`/order/?id=${oid}`);
            }}>Create order</button>
          )}
        </div>
      );
    }
    case 'order': {
      const o = m.orderRef && state.orders[m.orderRef.orderId];
      if (!o) return <span>Order</span>;
      return (
        <button style={{ textAlign: 'left', minWidth: U(440) }} onClick={() => onOpen(`/order/?id=${o.id}`)}>
          <div className="rowflex" style={{ gap: U(10), fontWeight: 800 }}><ShoppingBag style={{ width: U(34), height: U(34) }} />Order · {o.items[0]?.title}</div>
          <div style={{ fontWeight: 900, fontSize: U(34), margin: `${U(6)} 0` }}>{money(o.finalPrice)}</div>
          <div style={{ fontSize: U(26), opacity: 0.9, textTransform: 'capitalize' }}>{o.status.replace(/_/g, ' ')} · {o.paymentStatus} →</div>
        </button>
      );
    }
    default: return <span>{m.text}</span>;
  }
}

function ChatScreen() {
  const id = useSearchParams().get('id') ?? undefined;
  const router = useRouter();
  const toast = useToast();
  const store = useStore();
  const conv = useConversation(id);
  const msgs = useMessages(id);
  const products = useProducts();
  const [text, setText] = useState('');
  const [sel, setSel] = useState<Message | null>(null);
  const [attach, setAttach] = useState(false);
  const [edit, setEdit] = useState<Message | null>(null);
  const [del, setDel] = useState<Message | null>(null);
  const [reply, setReply] = useState<Message | null>(null);
  const [pick, setPick] = useState(false);
  const end = useRef<HTMLDivElement>(null);

  useEffect(() => { if (id) store.markRead(id); }, [id, msgs.length]); // eslint-disable-line react-hooks/exhaustive-deps
  useEffect(() => { end.current?.scrollIntoView({ block: 'end' }); }, [msgs.length]);

  const title = conv ? conversationTitle(conv, store.state.users) : 'Chat';
  const e2ee = isE2EE(conv);
  const anon = conv?.env === 'anonymous';
  const typing = id ? store.state.typing[id] : false;

  const rows = useMemo(() => {
    const out: ({ k: 'day'; label: string } | { k: 'msg'; m: Message })[] = [];
    let last = '';
    msgs.forEach((m) => { const d = dayLabel(m.createdAt); if (d !== last) { out.push({ k: 'day', label: d }); last = d; } out.push({ k: 'msg', m }); });
    return out;
  }, [msgs]);

  if (!conv || !id) {
    return <PageShell title="Chat" active="chats" dock={false}><div className="empty">Conversation not found.</div></PageShell>;
  }

  const send = () => {
    const t = text.trim();
    if (!t) return;
    if (edit) { store.editMessage(edit.id, t); setEdit(null); }
    else store.sendMessage(id, { type: 'text', text: t, replyToId: reply?.id });
    setText(''); setReply(null);
  };

  const sendKind = (partial: Parameters<typeof store.sendMessage>[1]) => { store.sendMessage(id, partial); setAttach(false); };

  const footer = (
    <div className="composer">
      {(reply || edit) && (
        <div className="banner" style={{ marginBottom: U(14) }}>
          <Edit3 /><div className="grow ellip">{edit ? 'Editing message' : `Replying to ${reply?.text ?? reply?.type}`}</div>
          <button onClick={() => { setReply(null); setEdit(null); setText(''); }}><X style={{ width: U(36), height: U(36) }} /></button>
        </div>
      )}
      <Art w={910} h={197} src="chat-bar" className="cbar">
        <At x={33} y={45} w={90} h={90}><Press pop shine={false} label="Attach" onClick={() => setAttach(true)} style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', color: '#ffb866', filter: `drop-shadow(0 0 ${K(8)} rgba(255,140,30,.9))` }}><Paperclip style={{ width: '48%', height: '48%' }} strokeWidth={1.8} /></Press></At>
        <At x={154} y={52} w={390} h={76}><input className="cin" value={text} onChange={(e) => { setText(e.target.value); store.setDraft(id, e.target.value); }} onKeyDown={(e) => e.key === 'Enter' && send()} placeholder={e2ee ? 'Encrypted message…' : 'Type a message...'} aria-label="Message" /></At>
        <At x={549} y={56} w={64} h={64}><Press pop shine={false} label="Emoji" onClick={() => setText((t) => t + '😊')} style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', color: '#ffb866', filter: `drop-shadow(0 0 ${K(8)} rgba(255,140,30,.9))` }}><Smile style={{ width: '90%', height: '90%' }} strokeWidth={1.7} /></Press></At>
        <At x={659} y={52} w={68} h={76}><Press pop shine={false} label="Voice message" onClick={() => sendKind({ type: 'voice', voice: { duration: '0:06', waveform: [3, 7, 10, 6, 9, 4, 8, 11, 5, 7, 3, 6] } })} style={{ width: '100%', height: '100%', display: 'grid', placeItems: 'center', color: '#fff', filter: `drop-shadow(0 0 ${K(6)} rgba(255,255,255,.5))` }}><Mic style={{ width: '70%', height: '70%' }} strokeWidth={1.7} /></Press></At>
        <At x={774} y={42} w={96} h={96}><Press pop shine={false} label="Send" onClick={send} style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', color: '#ffb866', filter: `drop-shadow(0 0 ${K(10)} rgba(255,120,20,1))` }}><Send style={{ width: '52%', height: '52%' }} strokeWidth={1.9} /></Press></At>
      </Art>
    </div>
  );

  const peer = conv.userId ? store.state.users[conv.userId] : undefined;
  const status = conv.kind === 'group' ? `${conv.participants?.length ?? 0} members` : peer?.presence === 'online' ? 'online now' : peer?.lastSeen ? `last seen ${peer.lastSeen}` : 'offline';

  const mine = (m: Message) => m.authorId === store.me;

  return (
    <div className="stage">
      <header style={{ position: 'relative', zIndex: 5 }}>
        <Art w={854} h={209} src="hdr-calls">
          <At x={38} y={52} w={92} h={92}>
            <ChromeBtn label="Back" onClick={() => (window.history.length > 1 ? router.back() : router.push('/chats/'))}><ChevronLeft style={{ width: '58%', height: '58%' }} strokeWidth={2.2} /></ChromeBtn>
          </At>
          <At x={150} y={46} w={104} h={104}>
            <Press pop shine={false} label="Chat info" onClick={() => router.push(`/chat-info/?id=${id}`)} style={{ width: '100%', height: '100%', borderRadius: '50%', position: 'relative' }}>
              <div style={{ width: '100%', height: '100%' }}><Face id={conv.userId ?? conv.id} name={title} size={114.6} business={peer?.business} anon={anon} group={conv.kind === 'group'} /></div>
              {peer?.presence === 'online' && <span style={{ position: 'absolute', right: K(2), bottom: K(2), width: K(26), height: K(26), borderRadius: '50%', background: '#22c55e', border: `${K(4)} solid #0d1117`, boxShadow: '0 0 8px #22c55e' }} />}
            </Press>
          </At>
          <At x={278} y={58} w={250}>
            <div className="ellip" style={{ fontSize: K(title.length > 14 ? 30 : title.length > 9 ? 36 : 44), fontWeight: 800, color: '#fff', textShadow: `0 ${K(3)} ${K(4)} rgba(0,0,0,.8)`, lineHeight: 1.1 }}>{title}</div>
            <div className="rowflex ellip" style={{ gap: K(8), fontSize: K(26), color: '#e6ecf3', marginTop: K(6) }}>{peer?.presence === 'online' && <i style={{ width: K(18), height: K(18), borderRadius: '50%', background: '#22c55e', boxShadow: '0 0 8px #22c55e', flex: 'none' }} />}{status}</div>
          </At>
          {([[536, Phone, 'Voice call', () => router.push(`/call/?name=${encodeURIComponent(title)}`)], [624, Video, 'Video call', () => router.push(`/call/?name=${encodeURIComponent(title)}&video=1`)], [712, MoreVertical, 'More', () => router.push(`/chat-info/?id=${id}`)]] as const).map(([x, Ic, l, fn]) => (
            <At key={l} x={x} y={62} w={80} h={80}><ChromeBtn label={l} gold={l !== 'More'} onClick={fn}><Ic style={{ width: '54%', height: '54%' }} strokeWidth={1.9} /></ChromeBtn></At>
          ))}
        </Art>
      </header>
      <main style={{ padding: `${U(10)} ${U(22)} ${U(330)}` }}>
      {(e2ee || anon) && <div style={{ marginBottom: U(20) }}><Banner icon={<Lock />} tone="ok">{anon ? 'Anonymous · end-to-end encrypted. Only your device keys can read this.' : 'Private mode · end-to-end encrypted.'}</Banner></div>}
      <div className={`thread rbub${anon ? ' anon' : ''}`}>
        {rows.map((r, i) => r.k === 'day' ? <div className="daysep" key={`d${i}`}><span>{r.label}</span></div> : r.m.type === 'system' ? <div className="sysmsg" key={r.m.id}>{r.m.text}</div> : (
          <div key={r.m.id} className={`mrow${mine(r.m) ? ' me' : ''}`}>
            <Face id={r.m.authorId} name={store.state.users[r.m.authorId]?.name ?? '?'} size={104} business={store.state.users[r.m.authorId]?.business} anon={anon} />
            <div className="col">
              {!mine(r.m) && conv.kind === 'group' && <div className="t-mute" style={{ margin: `0 ${U(14)} ${U(4)}` }}>{store.state.users[r.m.authorId]?.name}</div>}
              <div className={`bubble ${mine(r.m) ? 'out' : 'in'}${anon ? ' anon' : ''}${r.m.type === 'voice' || r.m.type === 'document' ? ' wide' : ''}`} onClick={() => !r.m.deleted && setSel(r.m)} style={{ cursor: 'pointer' }}>
                <Body m={r.m} mine={mine(r.m)} onOpen={(p) => router.push(p)} />
                <div className="meta">{r.m.pinned && <Pin style={{ width: U(24), height: U(24) }} />}{r.m.starred && <Star style={{ width: U(24), height: U(24), fill: '#ffc24a', color: '#ffc24a' }} />}{clockTime(r.m.createdAt)}{mine(r.m) && <Ticks s={r.m.status} />}</div>
              </div>
              {!!r.m.reactions?.length && <div className="rowflex" style={{ gap: U(8), marginTop: U(-12), padding: `0 ${U(16)}` }}>{r.m.reactions.map((x) => <button key={x.emoji} className="pill" style={{ ['--t' as string]: '#c9a46a', height: U(46) }} onClick={() => store.react(r.m.id, x.emoji)}>{x.emoji} {x.by.length}</button>)}</div>}
              {r.m.status === 'failed' && <button className="t-mute" style={{ color: '#ff9a8f' }} onClick={() => store.retryMessage(r.m.id)}>Failed · tap to retry</button>}
            </div>
          </div>
        ))}
        {typing && <div className="mrow"><Face id={conv.userId ?? conv.id} name={title} size={104} anon={anon} group={conv.kind === 'group'} /><div className="bubble in typing"><i /><i /><i /></div></div>}
      </div>
      <div ref={end} />

      <Sheet open={!!sel} onClose={() => setSel(null)}>
        {sel && (
          <div className="msheet">
            <div className="erow">{EMOJI.map((e) => <button key={e} className="ering" aria-label={`React ${e}`} onClick={() => { store.react(sel.id, e); setSel(null); }}><span>{e}</span></button>)}</div>
            <div className="odiv" />
            <div className="arow">
              <button className="aring" onClick={() => { setReply(sel); setSel(null); }}><Smile /><b>Reply</b></button>
              <button className="aring" onClick={() => { store.togglePinMessage(sel.id); setSel(null); }}><Pin /><b>{sel.pinned ? 'Unpin' : 'Pin'}</b></button>
              <button className="aring" onClick={() => { toast(sel.starred ? 'Unstarred' : 'Starred'); setSel(null); }}><Star /><b>Star</b></button>
              {mine(sel) && <button className="aring red" onClick={() => { setDel(sel); setSel(null); }}><Trash2 /><b>Delete</b></button>}
            </div>
            {(sel.text || (mine(sel) && sel.type === 'text')) && (
              <div className="xrow">
                {sel.text && <Btn kind="ghost" size="sm" icon={<Copy />} onClick={() => { navigator.clipboard?.writeText(sel.text!); toast('Copied'); setSel(null); }}>Copy</Btn>}
                {mine(sel) && sel.type === 'text' && <Btn kind="ghost" size="sm" icon={<Edit3 />} onClick={() => { setEdit(sel); setText(sel.text ?? ''); setSel(null); }}>Edit</Btn>}
              </div>
            )}
          </div>
        )}
      </Sheet>

      <Dialog open={!!del} onClose={() => setDel(null)} title="Delete message?" text="This removes it from the conversation." onConfirm={() => { del && store.deleteMessage(del.id, true); setDel(null); }} />

      <Sheet open={attach} onClose={() => setAttach(false)} title="Share">
        <div className="rgrid">
          {([
            ['Gallery', <ImageIcon key="i" />, () => sendKind({ type: 'image', image: { url: 'grad-2', caption: 'Photo' } })],
            ['Camera', <Camera key="c" />, () => sendKind({ type: 'image', image: { url: 'grad-1', caption: 'Camera photo' } })],
            ['Document', <FileText key="d" />, () => sendKind({ type: 'document', document: { name: 'Notes.pdf', size: '1.2 MB', ext: 'PDF' } })],
            ['Location', <MapPin key="l" />, () => sendKind({ type: 'location', location: { label: 'Current location', area: 'Kathmandu' } })],
            ['Contact', <UserIcon key="u" />, () => sendKind({ type: 'contact', contact: { name: 'Sita Rai', phone: '+977 9801 234 567' } })],
            ...(anon ? [] : [['Product', <span key="p" className="cartplus"><ShoppingCart /><Plus /></span>, () => { setAttach(false); setPick(true); }]] as const),
          ] as [string, React.ReactNode, () => void][]).map(([label, icon, fn]) => (
            <button key={label} className="sring" onClick={fn}>
              <span className="ringart"><span className="glyph">{icon}</span></span>
              <span className="lbl">{label}</span>
            </button>
          ))}
        </div>
        {!anon && conv.kind === 'private' && <div style={{ marginTop: U(14) }}><Btn kind="ghost" block icon={<Tag />} onClick={() => { setAttach(false); router.push(`/offer/?chat=${id}`); }}>Make an offer</Btn></div>}
      </Sheet>

      {pick && (
        <>
          <div className="scrim" onClick={() => setPick(false)} />
          <div className="dialog pf" role="dialog" aria-label="Share a product">
            <div className="pf-title">Share a product</div>
            <div className="pf-list">
              {products.map((p) => (
                <button key={p.id} className="rowplate" onClick={() => { store.shareProduct(id, p.id); setPick(false); }}>
                  <ProdImg k={p.image} size={92} radius={22} />
                  <span className="grow" style={{ textAlign: 'left' }}><span className="pf-name ellip" style={{ display: 'block' }}>{p.title}</span><span className="price" style={{ fontSize: U(34) }}>{money(p.price)}</span></span>
                </button>
              ))}
            </div>
          </div>
        </>
      )}
      </main>
      {footer}
    </div>
  );
}

export default function Page() { return <Suspense><ChatScreen /></Suspense>; }
