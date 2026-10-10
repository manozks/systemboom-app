'use client';

import { Copy, KeyRound, Share2 } from 'lucide-react';
import { useRouter } from 'next/navigation';
import { QrGrid } from '@/components/QrGrid';
import { PageShell } from '@/components/PageShell';
import { Banner, Btn, Label, Plate } from '@/components/kit';
import { useActiveAnon } from '@/lib/data/store';
import { U, useToast } from '@/lib/ui';

export default function AnonQr() {
  const me = useActiveAnon();
  const toast = useToast();
  const router = useRouter();
  return (
    <PageShell title="My QR" active="home" dock={false}>
      <Plate variant="teal" className="pad" style={{ textAlign: 'center' }}>
        <div className="t-name" style={{ fontSize: U(42) }}>{me.name}</div>
        <div className="t-mute" style={{ marginBottom: U(24) }}>{me.sessionId}</div>
        <div style={{ width: U(560), margin: '0 auto', padding: U(20), background: '#fff', borderRadius: U(28), boxShadow: '0 0 28px rgba(40,230,215,.5)' }}><QrGrid seed={me.publicKey} /></div>
      </Plate>
      <Label>Public key</Label>
      <Plate variant="flat" className="pad"><code style={{ wordBreak: 'break-all', fontSize: U(25), color: '#b6fff4' }}>{me.publicKey}</code></Plate>
      <Label>Fingerprint</Label>
      <Plate variant="flat" className="pad"><code style={{ fontSize: U(28), color: '#ffd9a0' }}>{me.fingerprint}</code></Plate>
      <div style={{ height: U(24) }} />
      <div className="grid2">
        <Btn kind="steel" icon={<Copy />} onClick={() => { navigator.clipboard?.writeText(me.publicKey); toast('Public key copied'); }}>Copy key</Btn>
        <Btn kind="teal" icon={<Share2 />} onClick={() => toast('Share sheet (prototype)')}>Share</Btn>
      </div>
      <div style={{ height: U(14) }} />
      <Btn kind="ghost" block icon={<KeyRound />} onClick={() => router.push('/anon-key/?id=anon-me')}>View public key details</Btn>
      <div style={{ height: U(20) }} />
      <Banner>Only share this with people you want to talk to. Your private key never leaves this device.</Banner>
    </PageShell>
  );
}
