'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Check, Plus, Trash2 } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Banner, Btn, Dialog, IBtn, Label, LRow } from '@/components/kit';
import { useActiveAnon, useAnonIdentities, useStore } from '@/lib/data/store';
import { U, useToast } from '@/lib/ui';

export default function AnonIdentities() {
  const router = useRouter();
  const toast = useToast();
  const store = useStore();
  const all = useAnonIdentities();
  const active = useActiveAnon();
  const [del, setDel] = useState<string | null>(null);
  return (
    <PageShell title="Identities" active="home" dock={false} footer={<div className="footbar"><Btn kind="teal" size="lg" block icon={<Plus />} onClick={() => { store.createAnonIdentity(); toast('New identity created'); }}>New identity</Btn></div>}>
      <Banner>Each identity has its own temporary name, session ID and key pair. Switch anytime — contacts only know the identity you used with them.</Banner>
      <Label>Your identities</Label>
      {all.map((a) => (
        <LRow key={a.id} teal icon={<Avatar name={a.name} size={70} anon />} title={a.name} sub={`${a.sessionId} · ${a.id === active.id ? 'Active' : 'Tap to switch'}`} chev={false}
          onClick={() => { store.setActiveAnon(a.id); toast(`Switched to ${a.name}`); }}
          right={<span className="rowflex" style={{ gap: U(12) }}>
            {a.id === active.id && <Check style={{ width: U(44), height: U(44), color: '#4ff0e0' }} />}
            {all.length > 1 && <span onClick={(e) => { e.stopPropagation(); setDel(a.id); }}><IBtn label="Delete identity" small tone="danger"><Trash2 /></IBtn></span>}
          </span>} />
      ))}
      <div style={{ height: U(10) }} />
      <Btn kind="ghost" block onClick={() => router.push('/anon-qr/')}>Show QR & public key</Btn>
      <Dialog open={!!del} onClose={() => setDel(null)} title="Delete identity?" text="Its keys are removed from this device." onConfirm={() => { del && store.deleteAnonIdentity(del); setDel(null); }} />
    </PageShell>
  );
}
