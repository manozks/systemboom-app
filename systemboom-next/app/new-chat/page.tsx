'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Check, Lock, Users } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { SearchBar } from '@/components/Controls';
import { Avatar, Label, LRow } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import type { User } from '@/lib/data/types';
import { U } from '@/lib/ui';

function NewChat() {
  const router = useRouter();
  const privateIntent = useSearchParams().get('mode') === 'private';
  const { state } = useStore();
  const [q, setQ] = useState('');
  const contacts = Object.values(state.users)
    .filter((u) => u.id !== 'me' && !u.anon && (!q.trim() || u.name.toLowerCase().includes(q.trim().toLowerCase())))
    .sort((a, b) => a.name.localeCompare(b.name));

  const open = (u: User) => {
    const wanted = privateIntent ? 'private' : 'standard';
    const existing = state.conversations.find((c) => c.kind === 'private' && (c.env ?? 'registered') === 'registered' && c.userId === u.id && (c.privacyMode ?? 'standard') === wanted);
    router.push(existing ? `/chat/?id=${existing.id}` : `/draft-chat/?user=${u.id}${privateIntent ? '&mode=private' : ''}`);
  };

  return (
    <PageShell title={privateIntent ? 'New private chat' : 'New chat'} active="chats" dock={false}>
      <SearchBar value={q} onChange={setQ} placeholder="Search name or number" />
      <div style={{ height: U(20) }} />
      {!privateIntent && (<>
        <LRow icon={<Users />} title="New group" sub="Create a group conversation" onClick={() => router.push('/new-group/')} />
        <LRow icon={<Lock />} title="New private chat" sub="End-to-end encrypted conversation" onClick={() => router.push('/new-chat/?mode=private')} />
      </>)}
      <Label>Contacts on SYSTEMBOOM · {contacts.length}</Label>
      {contacts.map((u) => (
        <LRow key={u.id} icon={<Avatar name={u.name} size={70} presence={u.presence} />} title={<>{u.name}{u.verified && <Check style={{ width: U(36), height: U(36), color: '#5ab8f2', verticalAlign: '-10%', marginLeft: U(8) }} />}</>} sub={u.about ?? u.phone ?? 'SYSTEMBOOM user'} onClick={() => open(u)} />
      ))}
    </PageShell>
  );
}

export default function Page() { return <Suspense><NewChat /></Suspense>; }
