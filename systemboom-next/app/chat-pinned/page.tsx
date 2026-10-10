'use client';

import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import { Pin, PinOff } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Empty, IBtn, LRow } from '@/components/kit';
import { useMessages, useStore } from '@/lib/data/store';
import { useToast } from '@/lib/ui';

function Pinned() {
  const id = useSearchParams().get('id') ?? undefined;
  const msgs = useMessages(id);
  const store = useStore();
  const toast = useToast();
  const pinned = msgs.filter((m) => m.pinned && !m.deleted);
  return (
    <PageShell title="Pinned messages" active="chats" dock={false}>
      {pinned.length === 0 && <Empty icon={<Pin />} title="No pinned messages" sub="Tap any message and choose Pin to keep it here for quick access." />}
      {pinned.map((m) => (
        <LRow key={m.id} icon={<Pin />} title={m.authorId === store.me ? 'You' : store.state.users[m.authorId]?.name} sub={m.text ?? m.image?.caption ?? m.document?.name ?? m.type} chev={false}
          right={<IBtn label="Unpin message" small onClick={() => { store.togglePinMessage(m.id); toast('Unpinned'); }}><PinOff /></IBtn>} />
      ))}
    </PageShell>
  );
}

export default function Page() { return <Suspense><Pinned /></Suspense>; }
