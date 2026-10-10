'use client';

import { Suspense, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import { FileText, Image as ImageIcon, Link2 } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Empty, LRow, gradFor } from '@/components/kit';
import { useMessages } from '@/lib/data/store';
import { clockTime } from '@/lib/data/format';
import { U } from '@/lib/ui';

function Media() {
  const id = useSearchParams().get('id') ?? undefined;
  const msgs = useMessages(id);
  const [tab, setTab] = useState<'media' | 'docs' | 'links'>('media');
  const media = msgs.filter((m) => m.type === 'image' || m.type === 'video');
  const docs = msgs.filter((m) => m.type === 'document');
  const links = msgs.filter((m) => m.type === 'link');
  return (
    <PageShell title="Media, links & docs" active="chats" dock={false}>
      <div className="chips">
        {([['media', `Media ${media.length}`], ['docs', `Docs ${docs.length}`], ['links', `Links ${links.length}`]] as const).map(([k, l]) => <button key={k} className={`chip${tab === k ? ' on' : ''}`} onClick={() => setTab(k)}>{l}</button>)}
      </div>
      <div style={{ height: U(16) }} />
      {tab === 'media' && (media.length
        ? <div className="grid2">{media.map((m) => <div key={m.id} className="pimg" style={{ height: U(300), borderRadius: U(26), background: gradFor(m.image?.url ?? m.video?.thumb ?? 'grad-1') }}><ImageIcon style={{ opacity: 0.6, width: '26%', height: '26%' }} /></div>)}</div>
        : <Empty icon={<ImageIcon />} title="No media yet" sub="Photos and videos shared in this chat will appear here." />)}
      {tab === 'docs' && (docs.length
        ? docs.map((m) => <LRow key={m.id} icon={<FileText />} title={m.document?.name} sub={`${m.document?.ext} · ${m.document?.size} · ${clockTime(m.createdAt)}`} chev={false} />)
        : <Empty icon={<FileText />} title="No documents" sub="Files shared in this chat will appear here." />)}
      {tab === 'links' && (links.length
        ? links.map((m) => <LRow key={m.id} icon={<Link2 />} title={m.link?.title} sub={m.link?.host} chev={false} />)
        : <Empty icon={<Link2 />} title="No links" sub="Links shared in this chat will appear here." />)}
    </PageShell>
  );
}

export default function Page() { return <Suspense><Media /></Suspense>; }
