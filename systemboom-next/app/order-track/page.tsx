'use client';

import { Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Box, Check, MessageCircle, Star, Truck } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Btn } from '@/components/kit';
import { useOrder } from '@/lib/data/store';
import { STATUS_COLOR, statusLabel } from '@/lib/status';
import { U } from '@/lib/ui';

const STEPS = [['confirmed', 'Order confirmed', Check], ['shipped', 'Shipped', Box], ['out_for_delivery', 'Out for delivery', Truck], ['delivered', 'Delivered', Check]] as const;
const ORDER = ['pending_payment', 'confirmed', 'shipped', 'out_for_delivery', 'delivered', 'completed'];

function Track() {
  const id = useSearchParams().get('id') ?? undefined;
  const router = useRouter();
  const o = useOrder(id);
  if (!o) return <PageShell title="Tracking" active="market" dock={false}><div className="empty">Order not found.</div></PageShell>;
  const idx = ORDER.indexOf(o.status);
  return (
    <PageShell title="Delivery tracking" active="market" dock={false}>
      <div className="plate flat" style={{ height: U(300), display: 'grid', placeItems: 'center', background: 'linear-gradient(160deg,#2d688f,#12303f)', position: 'relative', overflow: 'hidden' }}>
        <Truck style={{ width: U(110), height: U(110), color: '#fff' }} />
        <span className="pill" style={{ position: 'absolute', bottom: U(24), ['--t' as string]: STATUS_COLOR[o.status] }}>{statusLabel(o.status)}</span>
      </div>
      <div className="mp dark otot" style={{ marginTop: U(20) }}>
        <div className="orow"><span style={{ color: '#9db4e0' }}>Courier</span><b>{o.tracking?.courier ?? 'Boom Express'}</b></div>
        <div className="orow"><span style={{ color: '#9db4e0' }}>Tracking code</span><b style={{ fontFamily: 'monospace' }}>{o.tracking?.code ?? '—'}</b></div>
      </div>
      <div className="olabel"><span>Progress</span></div>
      <div className="plate flat pad"><div className="steps">
        {STEPS.map(([k, label, Icon]) => <div key={k} className={`step${idx >= ORDER.indexOf(k) ? ' done' : ''}`}><span className="dot"><Icon /></span><div><div className="t-name" style={{ fontSize: U(36) }}>{label}</div></div></div>)}
      </div></div>
      <div className="stack" style={{ marginTop: U(24) }}>
        <Btn kind="steel" block icon={<MessageCircle />} onClick={() => router.push(`/chat/?id=${o.conversationId}`)}>Message seller</Btn>
        {o.status === 'delivered' && !o.reviewed && <Btn kind="primary" block icon={<Star />} onClick={() => router.push(`/order-review/?id=${o.id}`)}>Leave a review</Btn>}
      </div>
    </PageShell>
  );
}

export default function Page() { return <Suspense><Track /></Suspense>; }
