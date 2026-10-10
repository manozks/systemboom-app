'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Check, Copy, MessageSquarePlus, ScanLine } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Banner, Btn, Field, Label } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import { ANON_ADJECTIVES, ANON_ANIMALS, keyMaterial, toFingerprint } from '@/lib/data/mock';
import { U } from '@/lib/ui';

const randomName = () => `${ANON_ADJECTIVES[Math.floor(Math.random() * ANON_ADJECTIVES.length)]} ${ANON_ANIMALS[Math.floor(Math.random() * ANON_ANIMALS.length)]} ${1000 + Math.floor(Math.random() * 9000)}`;
const fakeFingerprint = (seed: string) => toFingerprint(keyMaterial(seed).publicKey);

type Found = { name: string; fingerprint: string };

export default function AnonScan() {
  const router = useRouter();
  const { pairViaQR } = useStore();
  const [found, setFound] = useState<Found | null>(null);
  const [error, setError] = useState(false);
  const [paste, setPaste] = useState(false);
  const [key, setKey] = useState('');
  const [busy, setBusy] = useState(false);

  // Simulate detecting a nearby anonymous QR after a couple of seconds.
  useEffect(() => {
    if (found || error || paste) return;
    const t = window.setTimeout(() => setFound({ name: randomName(), fingerprint: fakeFingerprint(`preview-${Math.floor(Math.random() * 9000)}`) }), 2600);
    return () => window.clearTimeout(t);
  }, [found, error, paste]);

  const connect = () => {
    if (!found) return;
    setBusy(true);
    window.setTimeout(() => router.replace(`/chat/?id=${pairViaQR(found.name)}`), 900);
  };
  const rescan = () => { setError(false); setFound(null); setPaste(false); setKey(''); };

  return (
    <PageShell title="Scan QR" active="home" dock={false}>
      <div className="plate teal" style={{ aspectRatio: '1', display: 'grid', placeItems: 'center', overflow: 'hidden' }}>
        <div style={{ width: '62%', aspectRatio: '1', border: `${U(6)} solid ${error ? '#ff6a5a' : '#4ff0e0'}`, borderRadius: U(30), position: 'relative', boxShadow: `0 0 24px ${error ? 'rgba(255,90,70,.6)' : 'rgba(40,230,215,.6)'}` }}>
          {!found && !error && !paste && <span style={{ position: 'absolute', left: 0, right: 0, height: U(6), background: '#4ff0e0', boxShadow: '0 0 14px #28e6d7', animation: 'scanline 2s ease-in-out infinite' }} />}
          <div style={{ position: 'absolute', inset: 0, display: 'grid', placeItems: 'center', color: error ? '#ff6a5a' : found ? '#4ff0b0' : '#b6fff4', opacity: found || error ? 1 : 0.5 }}>
            {found ? <Check style={{ width: '40%', height: '40%' }} /> : <ScanLine style={{ width: '40%', height: '40%' }} />}
          </div>
        </div>
      </div>
      <style>{'@keyframes scanline{0%,100%{top:4%}50%{top:92%}}'}</style>
      <div style={{ height: U(24) }} />

      {error ? (
        <div className="stack">
          <Banner tone="err" icon={<ScanLine />}><b>Couldn’t read the code.</b> Make sure it’s a SYSTEMBOOM anonymous QR and that it’s well lit, then try again.</Banner>
          <Btn kind="teal" block icon={<ScanLine />} onClick={rescan}>Try again</Btn>
        </div>
      ) : found ? (
        <div className="plate teal pad stack">
          <div className="rowflex"><Avatar name={found.name} size={104} anon /><div className="grow"><div className="t-name">{found.name}</div><div className="t-mute">Anonymous identity detected</div></div></div>
          <div><div className="t-label" style={{ margin: 0 }}>Fingerprint</div><code style={{ color: '#ffd9a0', fontSize: U(30) }}>{found.fingerprint}</code></div>
          <Btn kind="teal" block disabled={busy} icon={<MessageSquarePlus />} onClick={connect}>{busy ? 'Exchanging keys…' : 'Start anonymous chat'}</Btn>
        </div>
      ) : paste ? (
        <div className="stack">
          <Label>Paste a public key</Label>
          <Field><input value={key} onChange={(e) => setKey(e.target.value)} placeholder="Public key (hex)" /></Field>
          <Btn kind="teal" block disabled={key.trim().length < 16} onClick={() => setFound({ name: randomName(), fingerprint: fakeFingerprint(key.trim()) })}>Pair with key</Btn>
          <Btn kind="ghost" block onClick={rescan}>Back to scanner</Btn>
        </div>
      ) : (
        <div className="stack" style={{ textAlign: 'center' }}>
          <p className="t-mute">Point at a SYSTEMBOOM anonymous QR code…</p>
          <div className="grid2">
            <Btn kind="teal" size="sm" onClick={() => setFound({ name: randomName(), fingerprint: fakeFingerprint('now') })}>Simulate a scan</Btn>
            <Btn kind="ghost" size="sm" onClick={() => setError(true)}>Simulate error</Btn>
          </div>
          <Btn kind="ghost" block icon={<Copy />} onClick={() => setPaste(true)}>Paste public key instead</Btn>
        </div>
      )}
      <div style={{ height: U(24) }} />
      <Banner>Pairing creates a new end-to-end encrypted conversation. You will see only a temporary name.</Banner>
    </PageShell>
  );
}
