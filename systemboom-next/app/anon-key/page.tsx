'use client';

import { Suspense, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { Ban, Check, Copy, Fingerprint, Flag, ShieldCheck } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Btn, Label, Plate } from '@/components/kit';
import { useActiveAnon, useAnonIdentities, useUser } from '@/lib/data/store';
import { U, useToast } from '@/lib/ui';

function Key() {
  const id = useSearchParams().get('id') ?? 'anon-me';
  const toast = useToast();
  const me = useActiveAnon();
  const identities = useAnonIdentities();
  const contact = useUser(id);
  const [verified, setVerified] = useState(false);
  const own = id === 'anon-me' ? me : identities.find((a) => a.id === id);
  const self = !!own;
  const src = own ?? contact;
  const name = src?.name ?? 'Unknown';
  const key = src?.publicKey ?? '';
  const fp = src?.fingerprint ?? '';
  const session = src?.sessionId ?? '';
  return (
    <PageShell title="Public key" active="home" dock={false}>
      <div style={{ textAlign: 'center', marginBottom: U(24) }}>
        <div style={{ display: 'inline-block' }}><Avatar name={name} size={200} anon /></div>
        <div className="t-title" style={{ marginTop: U(14) }}>{name}</div>
        <div className="t-mute">{session}</div>
        {verified && <span className="pill" style={{ ['--t' as string]: '#35d07f', marginTop: U(12) }}><ShieldCheck /> Verified</span>}
      </div>
      <Label>Safety number (fingerprint)</Label>
      <Plate variant="flat" className="pad" style={{ textAlign: 'center' }}>
        <code style={{ color: '#ffd9a0', fontSize: U(32) }}>{fp}</code>
        <p className="t-mute" style={{ marginTop: U(12) }}>Compare this in person or over another trusted channel to confirm no one is in the middle.</p>
      </Plate>
      {!self && <div style={{ marginTop: U(16) }}><Btn kind={verified ? 'ghost' : 'teal'} block icon={verified ? <Check /> : <Fingerprint />} onClick={() => { setVerified((v) => !v); toast(verified ? 'Marked unverified' : 'Marked verified'); }}>{verified ? 'Verified' : 'Mark as verified'}</Btn></div>}
      <Label>Public key</Label>
      <Plate variant="flat" className="pad"><code style={{ wordBreak: 'break-all', fontSize: U(25), color: '#b6fff4' }}>{key}</code></Plate>
      <div style={{ height: U(16) }} />
      <Btn kind="steel" block icon={<Copy />} onClick={() => { navigator.clipboard?.writeText(key); toast('Public key copied'); }}>Copy public key</Btn>
      {!self && (
        <div className="grid2" style={{ marginTop: U(24) }}>
          <Btn kind="ghost" icon={<Ban />} onClick={() => toast(`${name} blocked`)}>Block</Btn>
          <Btn kind="ghost" icon={<Flag />} onClick={() => toast('Report submitted')}>Report</Btn>
        </div>
      )}
    </PageShell>
  );
}

export default function Page() { return <Suspense><Key /></Suspense>; }
