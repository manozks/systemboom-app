'use client';

import { useRouter } from 'next/navigation';
import { Package } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Btn, Empty, LRow, Pill, ProdImg } from '@/components/kit';
import { useOrders, useStore } from '@/lib/data/store';
import { listTime, money } from '@/lib/data/format';
import { STATUS_COLOR, statusLabel } from '@/lib/status';
import { U } from '@/lib/ui';


export default function Orders() {
  const router = useRouter();
  const orders = useOrders();
  const { state } = useStore();
  return (
    <PageShell title="My Orders" active="market" dock={false}>
      {!orders.length && <Empty icon={<Package />} title="No orders yet" sub="Orders you place from chats appear here."><Btn kind="primary" onClick={() => router.push('/market/')}>Browse marketplace</Btn></Empty>}
      {orders.map((o) => (
        <LRow key={o.id} icon={<ProdImg k={o.items[0].image} size={76} radius={38} />} title={o.items[0].title + (o.items.length > 1 ? ` +${o.items.length - 1}` : '')}
          sub={<span>{state.users[o.sellerId]?.name} · {listTime(o.createdAt)} · {money(o.finalPrice)}</span>}
          right={<Pill color={STATUS_COLOR[o.status]}>{statusLabel(o.status)}</Pill>} onClick={() => router.push(`/order/?id=${o.id}`)} />
      ))}
      <div style={{ height: U(10) }} />
    </PageShell>
  );
}
