'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ScanLine } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Banner, Btn, Field, Label } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import { U } from '@/lib/ui';

export default function AnonScan() {
  const router = useRouter();
  const { pairViaQR } = useStore();
  const [key, setKey] = useState('');
  const [busy, setBusy] = useState(false);
  const pair = () => { setBusy(true); setTimeout(() => router.replace(`/chat/?id=${pairViaQR()}`), 1200); };
  return (
    <PageShell title="Scan QR" active="home" dock={false}>
      <div className="plate teal" style={{ aspectRatio: '1', display: 'grid', placeItems: 'center', overflow: 'hidden' }}>
        <div style={{ width: '62%', aspectRatio: '1', border: `${U(6)} solid #4ff0e0`, borderRadius: U(30), position: 'relative', boxShadow: '0 0 24px rgba(40,230,215,.6)' }}>
          <span style={{ position: 'absolute', left: 0, right: 0, height: U(6), background: '#4ff0e0', boxShadow: '0 0 14px #28e6d7', animation: 'scanline 2s ease-in-out infinite' }} />
          <ScanLine style={{ position: 'absolute', inset: '30%', width: '40%', height: '40%', color: '#b6fff4', opacity: 0.5 }} />
        </div>
      </div>
      <style>{'@keyframes scanline{0%,100%{top:4%}50%{top:92%}}'}</style>
      <div style={{ height: U(24) }} />
      <Btn kind="teal" size="lg" block disabled={busy} onClick={pair}>{busy ? 'Exchanging keys…' : 'Simulate scan'}</Btn>
      <Label>Or paste a public key</Label>
      <Field><input value={key} onChange={(e) => setKey(e.target.value)} placeholder="Public key (hex)" /></Field>
      <div style={{ height: U(16) }} />
      <Btn kind="ghost" block disabled={key.trim().length < 16 || busy} onClick={pair}>Pair with key</Btn>
      <div style={{ height: U(24) }} />
      <Banner>Pairing creates a new end-to-end encrypted conversation. You will see only a temporary name.</Banner>
    </PageShell>
  );
}
