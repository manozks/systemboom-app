'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Lock, MessageSquare, Send, Smile } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Empty, IBtn } from '@/components/kit';
import { useStore, useUser } from '@/lib/data/store';
import { useOnline } from '@/lib/connectivity';
import type { PrivacyMode } from '@/lib/data/types';
import { U } from '@/lib/ui';

const OPTIONS: { value: PrivacyMode; label: string; desc: string; icon: React.ReactNode }[] = [
  { value: 'standard', label: 'Standard', desc: 'Secured in transit and at rest', icon: <MessageSquare /> },
  { value: 'private', label: 'Private', desc: 'End-to-end encrypted — only participants’ devices can read it', icon: <Lock /> },
];

/** Pre-creation state of a direct chat (FLOW-003): choose Standard or Private, then say hello. */
function Draft() {
  const sp = useSearchParams();
  const router = useRouter();
  const store = useStore();
  const online = useOnline();
  const user = useUser(sp.get('user') ?? undefined);
  const [mode, setMode] = useState<PrivacyMode>(sp.get('mode') === 'private' ? 'private' : 'standard');
  const [text, setText] = useState('');
  if (!user) return <PageShell title="New chat" active="chats" dock={false}><Empty title="Contact not found" /></PageShell>;
  const send = () => {
    const t = text.trim();
    if (!t) return;
    const cid = store.openOrCreatePrivate(user.id, mode);
    store.sendMessage(cid, { type: 'text', text: t }, online);
    router.replace(`/chat/?id=${cid}`);
  };
  return (
    <PageShell title={user.name} active="chats" dock={false} bottomPad={300}
      footer={(
        <div className="footbar">
          <div className="rowflex" style={{ gap: U(14) }}>
            <div className="gwell grow" style={{ margin: 0, borderRadius: 999 }}><input value={text} onChange={(e) => setText(e.target.value)} onKeyDown={(e) => e.key === 'Enter' && send()} placeholder={mode === 'private' ? 'Private message' : 'Message'} aria-label="Message" style={{ fontSize: U(36) }} /><button aria-label="Emoji" onClick={() => setText((t) => t + '🙂')}><Smile style={{ width: U(54), height: U(54), color: '#ffb866' }} /></button></div>
            <IBtn label="Send" tone="hot" onClick={send}><Send /></IBtn>
          </div>
        </div>
      )}>
      <div style={{ textAlign: 'center', marginBottom: U(30) }}>
        <div style={{ display: 'inline-block' }}><Avatar name={user.name} size={200} presence={user.presence} /></div>
        <div className="t-title" style={{ marginTop: U(14) }}>{user.name}</div>
        <div className="t-mute">Choose how this conversation is protected, then say hello.</div>
      </div>
      <div className="stack">
        {OPTIONS.map((o) => (
          <button key={o.value} className={`mp dark lr${mode === o.value ? ' picked' : ''}`} onClick={() => setMode(o.value)} aria-pressed={mode === o.value}>
            <span className="iico">{o.icon}</span>
            <span className="grow" style={{ textAlign: 'left' }}><span className="lr-t">{o.label}{o.value === 'standard' && <span className="lr-s" style={{ display: 'inline', marginLeft: U(10) }}>· default</span>}</span><span className="lr-s">{o.desc}</span></span>
            <span className={`radio${mode === o.value ? ' on' : ''}`} />
          </button>
        ))}
      </div>
      <p className="t-mute" style={{ textAlign: 'center', marginTop: U(20) }}>Privacy type can’t be changed after this conversation starts.</p>
    </PageShell>
  );
}

export default function Page() { return <Suspense><Draft /></Suspense>; }
