'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { AlertTriangle, Minus, Plus, Send, Tag } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { ProdImg } from '@/components/kit';
import { useConversation, useProducts, useStore } from '@/lib/data/store';
import { money } from '@/lib/data/format';
import { U, img } from '@/lib/ui';

const Label = ({ children }: { children: React.ReactNode }) => <div className="olabel"><span>{children}</span></div>;
const PHOTO: Record<string, string> = { p_deskmat: 'photo-deskmat' };

function Thumb({ id, k }: { id: string; k: string }) {
  return <span className="othumb">{PHOTO[id] ? <img src={img(PHOTO[id])} alt="" draggable={false} /> : <ProdImg k={k} fill />}</span>;
}

function Offer() {
  const sp = useSearchParams();
  const router = useRouter();
  const store = useStore();
  const products = useProducts();
  const chatId = sp.get('chat') ?? undefined;
  const conv = useConversation(chatId);
  const [pid, setPid] = useState<string | undefined>(sp.get('product') ?? undefined);
  const product = products.find((p) => p.id === pid);
  const [qty, setQty] = useState(1);
  const [price, setPrice] = useState<string | null>(null);
  const [note, setNote] = useState('');

  if (!chatId || !conv) return <PageShell title="Make an offer" active="chats" dock={false}><div className="empty">Open a chat first.</div></PageShell>;
  const sellerProducts = products.filter((p) => p.sellerId === conv.userId);

  if (!product) {
    return (
      <PageShell title="Make an offer" active="chats" dock={false}>
        <Label>Choose a product</Label>
        {(sellerProducts.length ? sellerProducts : products).map((p) => (
          <button key={p.id} className="mp dark oitem opick" onClick={() => { setPid(p.id); setPrice(String(p.price)); }}>
            <Thumb id={p.id} k={p.image} />
            <span className="grow" style={{ minWidth: 0, textAlign: 'left' }}><span className="oi-t">{p.title}</span><span className="oi-s" style={{ color: '#ffb02e' }}>{money(p.price)}</span></span>
          </button>
        ))}
      </PageShell>
    );
  }

  const priceStr = price ?? String(product.price);
  const n = Number(priceStr) || 0;
  const valid = n > 0 && n <= product.price * 1.5;
  return (
    <PageShell title="Make an offer" active="chats" dock={false} bottomPad={400}
      footer={<div className="payfoot"><button className="mp pay" disabled={!valid} onClick={() => { store.sendOffer(chatId, { productId: product.id, price: n, qty, note: note.trim() || undefined }); router.replace(`/chat/?id=${chatId}`); }}><Send />Send offer · {money(n * qty)}</button></div>}>
      <div className="mp dark oitem">
        <Thumb id={product.id} k={product.image} />
        <span className="grow" style={{ minWidth: 0 }}><span className="oi-t">{product.title}</span><span className="oi-s">Listed at <b style={{ color: '#ffb02e' }}>{money(product.price)}</b></span></span>
      </div>

      <Label>Your price per unit (Rs)</Label>
      <div className="gwell big"><Tag /><input inputMode="numeric" value={priceStr} onChange={(e) => setPrice(e.target.value.replace(/\D/g, ''))} placeholder={String(product.price)} aria-label="Your price" /></div>

      <div className="chips" style={{ justifyContent: 'center', flexWrap: 'wrap' }}>
        {[['List price', product.price], ['-5%', Math.round(product.price * 0.95)], ['-10%', Math.round(product.price * 0.9)], ['-15%', Math.round(product.price * 0.85)]].map(([l, v]) => (
          <button key={l as string} className={`chip${n === v ? ' on' : ''}`} onClick={() => setPrice(String(v))}>{l} · {money(v as number)}</button>
        ))}
      </div>

      <Label>Quantity</Label>
      <div className="qty">
        <button className="rbtn" aria-label="Less" onClick={() => setQty((q) => Math.max(1, q - 1))}><Minus /></button>
        <span className="gwell qn">{qty}</span>
        <button className="rbtn hot" aria-label="More" onClick={() => setQty((q) => Math.min(20, q + 1))}><Plus /></button>
      </div>

      <Label>Note (optional)</Label>
      <div className="gwell area"><textarea value={note} onChange={(e) => setNote(e.target.value)} placeholder="Add a friendly note" aria-label="Note" /></div>

      <div className="mp dark otot" style={{ marginTop: U(26) }}>
        <div className="orow"><span>{money(n)} × {qty}</span><span className="price" style={{ fontWeight: 900 }}>{money(n * qty)}</span></div>
      </div>
      {n > product.price && <div className="owarn"><AlertTriangle />Your offer is above the listed price.</div>}
    </PageShell>
  );
}

export default function Page() { return <Suspense><Offer /></Suspense>; }
