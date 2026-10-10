'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Minus, Plus, ShieldCheck } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { ProdImg } from '@/components/kit';
import { useProduct, useStore } from '@/lib/data/store';
import { money } from '@/lib/data/format';
import { U, img } from '@/lib/ui';

const Label = ({ children }: { children: React.ReactNode }) => <div className="olabel"><span>{children}</span></div>;

function CreateOrder() {
  const sp = useSearchParams();
  const router = useRouter();
  const store = useStore();
  const product = useProduct(sp.get('product') ?? undefined);
  const presetPrice = sp.get('price');
  const [qty, setQty] = useState(sp.get('qty') ? Number(sp.get('qty')) : 1);
  const [address, setAddress] = useState('Baneshwor, Kathmandu 44600');
  if (!product) return <PageShell title="Create order" active="market" dock={false}><div className="empty">Product not found.</div></PageShell>;
  const unit = presetPrice ? Number(presetPrice) : product.price;
  const fee = 150;
  const total = unit * qty + fee;
  const place = () => {
    const cid = sp.get('conv') || store.openOrCreatePrivate(product.sellerId);
    const oid = store.createOrder({ conversationId: cid, sellerId: product.sellerId, items: [{ productId: product.id, title: product.title, image: product.image, unitPrice: unit, qty }], deliveryFee: fee, address });
    router.replace(`/order/?id=${oid}`);
  };
  return (
    <PageShell title="Create order" active="market" dock={false} bottomPad={400}
      footer={<div className="payfoot"><button className="mp pay" onClick={place}>Place order · {money(total)}</button></div>}>
      <div className="mp dark oitem">
        <span className="othumb">{product.id === 'p_deskmat' ? <img src={img('photo-deskmat')} alt="" draggable={false} /> : <ProdImg k={product.image} fill />}</span>
        <span className="grow" style={{ minWidth: 0 }}><span className="oi-t">{product.title}</span><span className="oi-s" style={{ color: '#ffb02e' }}>{money(unit)}</span></span>
      </div>
      <Label>Quantity</Label>
      <div className="qty">
        <button className="rbtn" aria-label="Decrease" onClick={() => setQty((q) => Math.max(1, q - 1))}><Minus /></button>
        <span className="gwell qn">{qty}</span>
        <button className="rbtn hot" aria-label="Increase" onClick={() => setQty((q) => q + 1)}><Plus /></button>
      </div>
      <Label>Delivery address</Label>
      <div className="gwell area"><textarea value={address} onChange={(e) => setAddress(e.target.value)} aria-label="Delivery address" /></div>
      <div className="mp dark otot" style={{ marginTop: U(26) }}>
        <div className="orow"><span>Subtotal ({qty} item{qty > 1 ? 's' : ''})</span><span>{money(unit * qty)}</span></div>
        <div className="orow"><span>Delivery</span><span>{money(fee)}</span></div>
        <div className="orow total"><span>Total</span><span className="price">{money(total)}</span></div>
      </div>
      <div className="mp green obanner" style={{ marginTop: U(20) }}><span className="oinfo"><ShieldCheck /></span><span>This order stays linked to your conversation. You can message the seller anytime.</span></div>
    </PageShell>
  );
}

export default function Page() { return <Suspense><CreateOrder /></Suspense>; }
