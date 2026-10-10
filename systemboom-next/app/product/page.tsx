'use client';

import { Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { BadgeCheck, ChevronRight, MessageCircle, ShoppingBag, Star, Tag, Truck } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Btn, ProdImg } from '@/components/kit';
import { useProduct, useStore } from '@/lib/data/store';
import { money } from '@/lib/data/format';
import { Art, At, K, U, img } from '@/lib/ui';

const AV = { 'In stock': '#2bff8a', 'Low stock': '#ffb02e', 'Made to order': '#5ab8f2' } as const;
const PHOTO: Record<string, string> = { p_deskmat: 'photo-deskmat' };

function Product() {
  const id = useSearchParams().get('id') ?? undefined;
  const router = useRouter();
  const store = useStore();
  const p = useProduct(id);
  if (!p) return <PageShell title="Product" active="market" dock={false}><div className="empty">Product not found.</div></PageShell>;
  const seller = store.state.users[p.sellerId];
  const chat = () => store.openOrCreatePrivate(p.sellerId);
  const chatWithSeller = () => { const cid = chat(); store.shareProduct(cid, p.id); router.push(`/chat/?id=${cid}`); };
  const buy = () => router.push(`/order-new/?product=${p.id}&conv=${chat()}`);
  const photo = PHOTO[p.id];
  const color = AV[p.availability];

  return (
    <PageShell title="Product" active="market" dock={false}
      footer={(
        <div className="pfoot">
          <button className="abtn steel" onClick={chatWithSeller}><MessageCircle />Chat</button>
          <button className="abtn orange" onClick={buy}><ShoppingBag />Buy now</button>
        </div>
      )}
      bottomPad={420}>
      {/* photo in a riveted frame */}
      <div className="pphoto">
        <div style={{ aspectRatio: '818 / 540', overflow: 'hidden' }}>
          {photo ? <img src={img(photo)} alt={p.title} draggable={false} style={{ width: '100%', height: '100%', objectFit: 'cover', display: 'block' }} /> : <ProdImg k={p.image} fill><ShoppingBag style={{ width: '20%', height: '20%', opacity: 0.55 }} /></ProdImg>}
        </div>
      </div>

      <div className="ptitle"><span style={{ fontSize: U(p.title.length > 30 ? 40 : p.title.length > 22 ? 46 : 54), whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.title}</span></div>

      <div className="rowflex" style={{ margin: `${U(14)} ${U(6)} ${U(8)}`, gap: U(22) }}>
        <span className="price" style={{ fontSize: U(92), lineHeight: 1 }}>{money(p.price)}</span>
        <span className="stockpill" style={{ ['--t' as string]: color }}>{p.availability}</span>
      </div>
      <div className="rowflex" style={{ gap: U(12), margin: `0 ${U(6)}`, fontSize: U(40) }}>
        <Star style={{ width: U(48), height: U(48), color: '#ffc24a', fill: '#ffc24a', filter: 'drop-shadow(0 0 6px rgba(255,170,40,.8))' }} />
        <b style={{ fontSize: U(46) }}>{p.rating.toFixed(1)}</b>
        <span style={{ color: '#9db4e0' }}>({p.reviews} reviews)</span>
      </div>
      <p style={{ margin: `${U(22)} ${U(6)} ${U(18)}`, fontSize: U(36), lineHeight: 1.3, color: '#eef2f7' }}>{p.description}</p>

      <Art w={886} h={88} src="plate-tab" style={{ marginBottom: U(-14), position: 'relative', zIndex: 1 }}>
        <At x={56} y={34} style={{ transform: 'translateY(-50%)', fontSize: K(31), fontWeight: 800, letterSpacing: '0.2em', color: '#d3d8de', textShadow: `0 ${K(2)} ${K(3)} rgba(0,0,0,.9)` }}>SELLER</At>
      </Art>
      <button className="prow" onClick={() => router.push(`/chat/?id=${chat()}`)}>
        <Avatar name={seller?.name ?? 'Seller'} size={118} presence={seller?.presence} />
        <span className="grow" style={{ textAlign: 'left' }}>
          <span className="prow-t">{seller?.name ?? 'Seller'} {seller?.verified && <BadgeCheck style={{ width: U(44), height: U(44), color: '#cfd6de', fill: '#5f6a75', verticalAlign: '-8%' }} />}</span>
          <span className="prow-s">{seller?.about ?? 'Verified seller'}</span>
        </span>
        <ChevronRight className="prow-c" />
      </button>
      <div className="prow" role="group">
        <span className="prow-ico"><Truck /></span>
        <span className="grow" style={{ textAlign: 'left' }}><span className="prow-t">Delivery</span><span className="prow-s">Rs 150 inside the valley · 2–4 days</span></span>
        <ChevronRight className="prow-c" />
      </div>
      <div style={{ height: U(12) }} />
      <Btn kind="ghost" block icon={<Tag />} onClick={() => router.push(`/offer/?product=${p.id}&chat=${chat()}`)}>Make an offer</Btn>
    </PageShell>
  );
}

export default function Page() { return <Suspense><Product /></Suspense>; }
