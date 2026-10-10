'use client';

import { Suspense, useMemo, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Search } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Empty, LRow } from '@/components/kit';
import { SearchBar } from '@/components/Controls';
import { useMessages, useStore } from '@/lib/data/store';
import { clockTime } from '@/lib/data/format';
import { U } from '@/lib/ui';

const textOf = (m: { text?: string; type: string; image?: { caption?: string }; document?: { name: string }; product?: { title: string }; link?: { title: string } }) =>
  m.text ?? m.image?.caption ?? m.document?.name ?? m.product?.title ?? m.link?.title ?? m.type;

function SearchScreen() {
  const id = useSearchParams().get('id') ?? undefined;
  const router = useRouter();
  const store = useStore();
  const msgs = useMessages(id);
  const [q, setQ] = useState('');
  const results = useMemo(() => {
    const s = q.trim().toLowerCase();
    return s ? msgs.filter((m) => !m.deleted && m.type !== 'system' && textOf(m).toLowerCase().includes(s)) : [];
  }, [q, msgs]);
  return (
    <PageShell title="Search chat" active="chats" dock={false}>
      <SearchBar value={q} onChange={setQ} placeholder="Search this conversation" />
      <div style={{ height: U(24) }} />
      {!q.trim() ? <Empty icon={<Search />} title="Search messages" sub="Find messages, media, documents and links in this conversation." />
        : results.length === 0 ? <Empty icon={<Search />} title="No results" sub={`Nothing matches “${q}”.`} />
        : (<>
          <div className="t-mute" style={{ padding: `0 ${U(8)} ${U(12)}` }}>{results.length} result{results.length > 1 ? 's' : ''}</div>
          {results.map((m) => (
            <LRow key={m.id} icon={<Avatar name={store.state.users[m.authorId]?.name ?? 'You'} size={70} />} title={m.authorId === store.me ? 'You' : store.state.users[m.authorId]?.name} sub={`${clockTime(m.createdAt)} · ${textOf(m)}`} onClick={() => router.push(`/chat/?id=${id}`)} />
          ))}
        </>)}
    </PageShell>
  );
}

export default function Page() { return <Suspense><SearchScreen /></Suspense>; }
