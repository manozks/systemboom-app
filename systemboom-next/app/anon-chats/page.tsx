'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { EyeOff, ScanLine } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { SearchBar } from '@/components/Controls';
import { Avatar, Banner, Btn, Empty, LRow } from '@/components/kit';
import { conversationTitle, latestMessage, useConversationList, useStore } from '@/lib/data/store';
import { listTime } from '@/lib/data/format';
import { U } from '@/lib/ui';

export default function AnonChats() {
  const router = useRouter();
  const store = useStore();
  const list = useConversationList({ env: 'anonymous' });
  const [q, setQ] = useState('');
  const items = list.filter((c) => conversationTitle(c, store.state.users).toLowerCase().includes(q.trim().toLowerCase()));
  return (
    <PageShell title="Anonymous chats" active="home" dock={false}>
      <Banner icon={<EyeOff />}>You are anonymous · identity hidden</Banner>
      <div style={{ height: U(20) }} />
      <SearchBar value={q} onChange={setQ} placeholder="Search anonymous chats" />
      <div style={{ height: U(20) }} />
      {items.length === 0 && <Empty icon={<ScanLine />} title={q ? 'No matches' : 'No anonymous chats yet'} sub={q ? 'Try another name.' : 'Scan a QR code to connect with someone privately.'}><Btn kind="teal" onClick={() => router.push('/anon-scan/')}>Pair via QR</Btn></Empty>}
      {items.map((c) => {
        const t = conversationTitle(c, store.state.users);
        const last = latestMessage(c, store.state.messages);
        return <LRow key={c.id} teal icon={<Avatar name={t} size={70} anon group={c.kind === 'group'} />} title={t} sub={last?.text ?? last?.type ?? 'Tap to start'} right={<span className="t-mute">{last ? listTime(last.createdAt) : ''}{c.unread > 0 && <span className="badge" style={{ display: 'block', margin: `${U(6)} 0 0 auto`, width: U(44), height: U(44), fontSize: U(24) }}>{c.unread}</span>}</span>} onClick={() => { store.markRead(c.id); router.push(`/chat/?id=${c.id}`); }} />;
      })}
      <div style={{ height: U(24) }} />
      <Btn kind="teal" block icon={<ScanLine />} onClick={() => router.push('/anon-scan/')}>Pair via QR</Btn>
    </PageShell>
  );
}
