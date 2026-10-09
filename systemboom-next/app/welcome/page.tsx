'use client';

import { useRouter } from 'next/navigation';
import { Lock, MessageCircle, Phone, ShoppingBag, VenetianMask } from 'lucide-react';
import { Btn } from '@/components/kit';
import { Art, U } from '@/lib/ui';

const FEATURES: [React.ReactNode, string][] = [[<MessageCircle key="a" />, 'Chats'], [<Phone key="b" />, 'Calls'], [<ShoppingBag key="c" />, 'Market'], [<Lock key="d" />, 'Private']];

export default function Welcome() {
  const router = useRouter();
  return (
    <div className="stage" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', gap: U(50), padding: `${U(60)} ${U(48)}`, minHeight: '100dvh' }}>
      <Art w={863} h={193} src="logo-lockup" className="logoplate" />
      <div style={{ textAlign: 'center' }}>
        <div className="hero-title">Chat. Call. <em>Trade.</em></div>
        <p className="t-sub" style={{ marginTop: U(20), color: '#c3cedb' }}>One calm place for conversations, calls and a marketplace — with optional end-to-end privacy.</p>
      </div>
      <div className="grid2" style={{ gridTemplateColumns: 'repeat(4,1fr)', gap: U(14) }}>
        {FEATURES.map(([ic, l]) => <div key={l} className="plate flat" style={{ padding: `${U(26)} 0`, display: 'grid', placeItems: 'center', gap: U(10), color: '#ffd9a0', fontWeight: 700, fontSize: U(25) }}><span style={{ width: U(56), height: U(56), display: 'grid' }}>{ic}</span>{l}</div>)}
      </div>
      <div className="stack">
        <Btn kind="primary" size="lg" block icon={<Phone />} onClick={() => router.push('/')}>Continue with phone</Btn>
        <Btn kind="teal" size="lg" block icon={<VenetianMask />} onClick={() => router.push('/anonymous/')}>Go anonymous</Btn>
        <p className="t-mute" style={{ textAlign: 'center' }}>By continuing you accept the Terms & Privacy Policy.</p>
      </div>
    </div>
  );
}
