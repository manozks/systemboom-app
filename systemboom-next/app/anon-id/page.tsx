'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Check, KeyRound, Plus, Trash2 } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Banner, Btn, Dialog, Field, IBtn, Label, LRow, Sheet } from '@/components/kit';
import { useActiveAnon, useAnonIdentities, useStore } from '@/lib/data/store';
import { U, useToast } from '@/lib/ui';

export default function AnonIdentities() {
  const router = useRouter();
  const toast = useToast();
  const store = useStore();
  const all = useAnonIdentities();
  const active = useActiveAnon();
  const [del, setDel] = useState<string | null>(null);
  const [creating, setCreating] = useState(false);
  const [name, setName] = useState('');
  const create = () => { store.createAnonIdentity(name.trim() || undefined); setName(''); setCreating(false); toast('New anonymous identity created'); };
  return (
    <PageShell title="Identities" active="home" dock={false} bottomPad={300} right={<IBtn label="New identity" tone="gold" onClick={() => setCreating(true)} style={{ width: '100%', height: '100%' }}><Plus /></IBtn>}
      footer={<div className="footbar"><Btn kind="teal" size="lg" block icon={<Plus />} onClick={() => setCreating(true)}>New identity</Btn></div>}>
      <Banner icon={<KeyRound />}>Each identity is a separate key pair generated on this device. Switching changes who you appear as — never revealing your registered account.</Banner>
      <Label>Your identities</Label>
      {all.map((a) => (
        <LRow key={a.id} teal icon={<Avatar name={a.name} size={70} anon />} title={a.name} sub={`${a.sessionId} · ${a.id === active.id ? 'Active' : 'Tap to view key'}`} chev={false}
          onClick={() => router.push(`/anon-key/?id=${a.id === active.id ? 'anon-me' : a.id}`)}
          right={<span className="rowflex" style={{ gap: U(12) }}>
            {a.id === active.id ? <Check style={{ width: U(44), height: U(44), color: '#4ff0e0' }} /> : <span onClick={(e) => { e.stopPropagation(); store.setActiveAnon(a.id); toast(`Now appearing as ${a.name}`); }}><Btn kind="teal" size="sm">Use</Btn></span>}
            {all.length > 1 && <span onClick={(e) => { e.stopPropagation(); setDel(a.id); }}><IBtn label={`Delete ${a.name}`} small tone="danger"><Trash2 /></IBtn></span>}
          </span>} />
      ))}
      <div style={{ height: U(10) }} />
      <Btn kind="ghost" block onClick={() => router.push('/anon-qr/')}>Show QR & public key</Btn>
      <Dialog open={!!del} onClose={() => setDel(null)} title="Delete identity?" text="Its keys are removed from this device." onConfirm={() => { del && store.deleteAnonIdentity(del); toast('Identity deleted'); setDel(null); }} />
      <Sheet open={creating} onClose={() => setCreating(false)} title="New anonymous identity">
        <div className="stack">
          <Field label="Temporary display name (optional)"><input value={name} onChange={(e) => setName(e.target.value)} placeholder="Leave blank for a random name" /></Field>
          <Btn kind="teal" block icon={<KeyRound />} onClick={create}>Generate identity</Btn>
        </div>
      </Sheet>
    </PageShell>
  );
}
