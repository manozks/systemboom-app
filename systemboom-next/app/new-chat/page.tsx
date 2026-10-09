'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Lock, Shield, Users } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { SearchBar } from '@/components/Controls';
import { Avatar, Banner, Label, LRow } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import type { PrivacyMode } from '@/lib/data/types';
import { U } from '@/lib/ui';

export default function NewChat() {
  const router = useRouter();
  const { state, me, openOrCreatePrivate } = useStore();
  const [q, setQ] = useState('');
  const [mode, setMode] = useState<PrivacyMode>('standard');
  const people = Object.values(state.users).filter((u) => u.id !== me && !u.business && u.name.toLowerCase().includes(q.toLowerCase()));
  const shops = Object.values(state.users).filter((u) => u.id !== me && u.business && u.name.toLowerCase().includes(q.toLowerCase()));
  return (
    <PageShell title="New Chat" active="chats" dock={false}>
      <SearchBar value={q} onChange={setQ} placeholder="Search contacts" />
      <Label>Privacy mode</Label>
      <div className="chips">
        <button className={`chip${mode === 'standard' ? ' on' : ''}`} onClick={() => setMode('standard')}><Shield style={{ width: U(30), height: U(30), verticalAlign: 'middle' }} /> Standard</button>
        <button className={`chip${mode === 'private' ? ' on' : ''}`} onClick={() => setMode('private')}><Lock style={{ width: U(30), height: U(30), verticalAlign: 'middle' }} /> Private (E2EE)</button>
      </div>
      <Banner tone={mode === 'private' ? 'ok' : undefined} icon={mode === 'private' ? <Lock /> : <Shield />}>
        {mode === 'private' ? 'Private chats are end-to-end encrypted. The mode is permanent for this conversation.' : 'Standard chats sync across devices. You can start a separate Private chat anytime.'}
      </Banner>
      <div style={{ height: U(24) }} />
      <LRow icon={<Users />} title="New group" sub="Chat with several people" onClick={() => router.push('/new-group/')} />
      <Label>Contacts</Label>
      {people.map((u) => (
        <LRow key={u.id} icon={<Avatar name={u.name} size={70} presence={u.presence} />} title={u.name} sub={u.about ?? u.phone} onClick={() => router.push(`/chat/?id=${openOrCreatePrivate(u.id, mode)}`)} />
      ))}
      {shops.length > 0 && <Label>Businesses</Label>}
      {shops.map((u) => (
        <LRow key={u.id} icon={<Avatar name={u.name} size={70} presence={u.presence} />} title={`${u.name} ✓`} sub={u.about} onClick={() => router.push(`/chat/?id=${openOrCreatePrivate(u.id, 'standard')}`)} />
      ))}
    </PageShell>
  );
}
