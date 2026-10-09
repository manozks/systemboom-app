'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Box, Check, CircleDollarSign, CreditCard, Info, MapPin, MessageCircle, ShoppingBag, Smartphone, Star, Truck, Wallet } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Banner, Btn, Field, ProdImg } from '@/components/kit';
import { useOrder, useStore } from '@/lib/data/store';
import { listTime, money } from '@/lib/data/format';
import { STATUS_COLOR, statusLabel } from '@/lib/status';
import { U, img } from '@/lib/ui';

const Label = ({ children }: { children: React.ReactNode }) => <div className="olabel"><span>{children}</span></div>;

const STEPS = [['confirmed', 'Order confirmed', Check], ['shipped', 'Shipped', Box], ['out_for_delivery', 'Out for delivery', Truck], ['delivered', 'Delivered', Check]] as const;
const ORDER = ['pending_payment', 'confirmed', 'shipped', 'out_for_delivery', 'delivered', 'completed'];
const METHODS: [string, React.ReactNode][] = [['eSewa', <Smartphone key="a" />], ['Khalti', <Wallet key="b" />], ['Card', <CreditCard key="c" />], ['Cash on delivery', <CircleDollarSign key="d" />]];

function Stars({ v, onChange }: { v: number; onChange: (n: number) => void }) {
  return <div className="stars big">{[1, 2, 3, 4, 5].map((n) => <Star key={n} className={n <= v ? 'on' : ''} onClick={() => onChange(n)} />)}</div>;
}

function OrderScreen() {
  const id = useSearchParams().get('id') ?? undefined;
  const router = useRouter();
  const store = useStore();
  const o = useOrder(id);
  const [method, setMethod] = useState('eSewa');
  const [sr, setSr] = useState(5);
  const [pr, setPr] = useState(5);
  const [text, setText] = useState('');
  if (!o || !id) return <PageShell title="Order" active="market" dock={false}><div className="empty">Order not found.</div></PageShell>;
  const seller = store.state.users[o.sellerId];
  const idx = ORDER.indexOf(o.status);
  const sub = o.items.reduce((s, i) => s + i.unitPrice * i.qty, 0);
  const canReview = o.status === 'delivered' && !o.reviewed;
  return (
    <PageShell title="Order" active="market" dock={false} bottomPad={o.paymentStatus === 'unpaid' || canReview ? 400 : undefined}
      footer={o.paymentStatus === 'unpaid' ? <div className="payfoot"><button className="mp pay" onClick={() => store.payOrder(id, method)}><ShoppingBag />Pay {money(o.finalPrice)}</button></div> : canReview ? <div className="footbar"><Btn kind="primary" size="lg" block onClick={() => store.reviewOrder(id, { sellerRating: sr, productRating: pr, text: text.trim() })}>Submit review</Btn></div> : undefined}>
      <div className="ohead">
        <div><div className="oid">Order {o.id.slice(-6).toUpperCase()}</div><div className="osub">{listTime(o.createdAt)} - {seller?.name}</div></div>
        <span className="mp pill" style={{ ['--tc' as string]: STATUS_COLOR[o.status] }}>{statusLabel(o.status)}</span>
      </div>
      {o.items.map((i) => (
        <div key={i.productId} className="mp dark oitem">
          <span className="othumb">{i.productId === 'p_deskmat' ? <img src={img('photo-deskmat')} alt="" draggable={false} /> : <ProdImg k={i.image} fill />}</span>
          <span className="grow" style={{ minWidth: 0 }}><span className="oi-t">{i.title}</span><span className="oi-s">{money(i.unitPrice)} × {i.qty}</span></span>
          <b className="oi-p">{money(i.unitPrice * i.qty)}</b>
        </div>
      ))}
      <div className="mp dark otot">
        <div className="orow"><span>Subtotal</span><span>{money(sub)}</span></div>
        <div className="orow"><span>Delivery</span><span>{money(o.deliveryFee)}</span></div>
        <div className="orow total"><span>Total</span><span className="price">{money(o.finalPrice)}</span></div>
      </div>
      <Label>Deliver to</Label>
      <div className="mp dark oaddr"><MapPin />{o.address}</div>

      {o.paymentStatus === 'unpaid' ? (<>
        <Label>Payment method</Label>
        <div className="mgrid">{METHODS.map(([m, ic]) => <button key={m} className={`mp mbtn${method === m ? ' on' : ''}`} onClick={() => setMethod(m)}>{ic}{m}</button>)}</div>
        <div className="mp green obanner"><span className="oinfo"><Info /></span><span>Payment details stay private — only a confirmation is shared in chat.</span></div>
      </>) : (<>
        <Label>Tracking{o.tracking ? ` · ${o.tracking.courier} ${o.tracking.code}` : ''}</Label>
        <div className="plate flat pad"><div className="steps">
          {STEPS.map(([k, label, Icon]) => <div key={k} className={`step${idx >= ORDER.indexOf(k) ? ' done' : ''}`}><span className="dot"><Icon /></span><div><div className="t-name" style={{ fontSize: U(32) }}>{label}</div></div></div>)}
        </div></div>
      </>)}

      {canReview && (<>
        <Label>Rate your order</Label>
        <div className="plate flat pad stack">
          <div><div className="t-mute">Seller</div><Stars v={sr} onChange={setSr} /></div>
          <div><div className="t-mute">Product</div><Stars v={pr} onChange={setPr} /></div>
          <Field><textarea value={text} onChange={(e) => setText(e.target.value)} placeholder="Share a few words (optional)" /></Field>
        </div>
      </>)}
      {o.reviewed && <><div style={{ height: U(20) }} /><Banner tone="ok">Thanks for your review.</Banner></>}
      <div style={{ height: U(24) }} />
      <Btn kind="ghost" block icon={<MessageCircle />} onClick={() => router.push(`/chat/?id=${o.conversationId}`)}>Open conversation</Btn>
    </PageShell>
  );
}

export default function Page() { return <Suspense><OrderScreen /></Suspense>; }
