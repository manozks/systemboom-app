'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Check } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Btn, Field, Label, LRow } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import type { GroupType } from '@/lib/data/types';
import { U } from '@/lib/ui';

function NewGroup() {
  const router = useRouter();
  const anon = useSearchParams().get('anon') === '1';
  const { state, me, createGroup } = useStore();
  const [name, setName] = useState('');
  const [sel, setSel] = useState<string[]>([]);
  const [type, setType] = useState<GroupType>('standard');
  const people = Object.values(state.users).filter((u) => u.id !== me && !u.business && !!u.anon === anon);
  const toggle = (id: string) => setSel((s) => (s.includes(id) ? s.filter((x) => x !== id) : [...s, id]));
  const ok = name.trim().length > 0 && sel.length > 0;
  return (
    <PageShell title={anon ? 'Anonymous Group' : 'New Group'} active="chats" dock={false} footer={<div className="footbar"><Btn kind="primary" size="lg" block disabled={!ok} onClick={() => router.replace(`/chat/?id=${createGroup(name.trim(), sel, anon ? { env: 'anonymous' } : { groupType: type })}`)}>Create group · {sel.length} members</Btn></div>}>
      <Field label="Group name"><input value={name} onChange={(e) => setName(e.target.value)} placeholder="e.g. Weekend trek" /></Field>
      <Label>Type</Label>
      <div className="chips">{(['standard', 'family', 'business'] as GroupType[]).map((t) => <button key={t} className={`chip${type === t ? ' on' : ''}`} onClick={() => setType(t)} style={{ textTransform: 'capitalize' }}>{t}</button>)}</div>
      <Label>Add members</Label>
      {people.map((u) => (
        <LRow key={u.id} icon={<Avatar name={u.name} size={70} presence={u.presence} />} title={u.name} sub={u.about ?? u.phone} chev={false} onClick={() => toggle(u.id)}
          right={<span className={`iswitch${sel.includes(u.id) ? ' on' : ''}`}><i /></span>} />
      ))}
    </PageShell>
  );
}

export default function Page() { return <Suspense><NewGroup /></Suspense>; }
