'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Package, Star } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { useOrder, useStore } from '@/lib/data/store';
import { U, useToast } from '@/lib/ui';

function Stars({ v, onChange }: { v: number; onChange: (n: number) => void }) {
  return <div className="stars big">{[1, 2, 3, 4, 5].map((n) => <Star key={n} className={n <= v ? 'on' : ''} onClick={() => onChange(n)} />)}</div>;
}

function Review() {
  const id = useSearchParams().get('id') ?? undefined;
  const router = useRouter();
  const store = useStore();
  const toast = useToast();
  const o = useOrder(id);
  const seller = o ? store.state.users[o.sellerId] : undefined;
  const [sr, setSr] = useState(5);
  const [pr, setPr] = useState(5);
  const [text, setText] = useState('');
  if (!o) return <PageShell title="Leave a review" active="market" dock={false}><div className="empty">Order not found.</div></PageShell>;
  const submit = () => {
    store.reviewOrder(o.id, { sellerRating: sr, productRating: pr, text: text.trim() });
    toast('Thanks for your review');
    router.replace(`/chat/?id=${o.conversationId}`);
  };
  return (
    <PageShell title="Leave a review" active="market" dock={false} bottomPad={400}
      footer={<div className="payfoot"><button className="mp pay" onClick={submit}>Submit review</button></div>}>
      <div style={{ textAlign: 'center', marginBottom: U(30) }}>
        <Package style={{ width: U(110), height: U(110), color: '#ffb866' }} />
        <div className="t-title" style={{ marginTop: U(10) }}>How was your order?</div>
        <div className="t-mute">{o.items[0]?.title}</div>
      </div>
      <div className="mp dark otot stack" style={{ gap: U(30), padding: U(30) }}>
        <div className="rowflex" style={{ justifyContent: 'space-between' }}><b>Rate {seller?.name}</b><Stars v={sr} onChange={setSr} /></div>
        <div className="rowflex" style={{ justifyContent: 'space-between' }}><b>Rate the product</b><Stars v={pr} onChange={setPr} /></div>
      </div>
      <div className="olabel"><span>Your feedback (optional)</span></div>
      <div className="gwell area"><textarea value={text} onChange={(e) => setText(e.target.value)} placeholder="Share what you liked…" aria-label="Feedback" /></div>
    </PageShell>
  );
}

export default function Page() { return <Suspense><Review /></Suspense>; }
