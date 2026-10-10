'use client';

import { Suspense, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Camera, Check, Lock, Users } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Btn, Empty, Field, Label, LRow } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import type { GroupType, PrivacyMode } from '@/lib/data/types';
import { U, useToast } from '@/lib/ui';

function NewGroup() {
  const router = useRouter();
  const toast = useToast();
  const anon = useSearchParams().get('anon') === '1';
  const { state, me, createGroup } = useStore();
  const [name, setName] = useState('');
  const [sel, setSel] = useState<string[]>([]);
  const [type, setType] = useState<GroupType>('standard');
  const [mode, setMode] = useState<PrivacyMode>('standard');
  const [seed, setSeed] = useState('Group');
  const people = Object.values(state.users).filter((u) => u.id !== me && !u.business && !!u.anon === anon);
  const toggle = (id: string) => setSel((s) => (s.includes(id) ? s.filter((x) => x !== id) : [...s, id]));
  const ok = name.trim().length > 0 && sel.length > 0;
  const create = () => {
    const id = createGroup(name.trim(), sel, anon ? { env: 'anonymous' } : { groupType: type, privacyMode: mode });
    toast(anon ? 'Anonymous group created' : mode === 'private' ? 'Private group created' : 'Group created');
    router.replace(anon ? `/chat/?id=${id}` : `/chat/?id=${id}`);
  };
  return (
    <PageShell title={anon ? 'Anonymous Group' : 'New Group'} active="chats" dock={false} bottomPad={300}
      footer={<div className="footbar"><Btn kind={anon ? 'teal' : 'primary'} size="lg" block disabled={!ok} onClick={create}>Create group · {sel.length} members</Btn></div>}>
      <div className="rowflex" style={{ marginBottom: U(24), gap: U(26) }}>
        <button aria-label="Choose group photo" onClick={() => { setSeed((x) => x + '•'); toast('Photo picker (prototype)'); }} style={{ position: 'relative' }}>
          <Avatar name={seed} size={150} anon={anon} group />
          <span className="badge" style={{ position: 'absolute', right: 0, bottom: 0, width: U(54), height: U(54), background: 'radial-gradient(circle at 35% 30%, #ffd9a0, #ff8a2a)' }}><Camera style={{ width: '60%', height: '60%' }} /></span>
        </button>
        <div className="grow"><Field label="Group name"><input value={name} onChange={(e) => setName(e.target.value)} placeholder="e.g. Weekend Trip" /></Field></div>
      </div>
      {!anon && (<>
        <Label>Group type</Label>
        <div className="chips">{(['standard', 'family', 'business'] as GroupType[]).map((t) => <button key={t} className={`chip${type === t ? ' on' : ''}`} onClick={() => setType(t)} style={{ textTransform: 'capitalize' }}>{t}</button>)}</div>
        <Label>Group privacy</Label>
        <div className="stack">
          {([['standard', 'Standard', 'Secured in transit and at rest', <Users key="s" />], ['private', 'Private', 'End-to-end encrypted — only members’ devices can read it', <Lock key="p" />]] as [PrivacyMode, string, string, React.ReactNode][]).map(([v, l, d, ic]) => (
            <button key={v} className={`mp dark lr${mode === v ? ' picked' : ''}`} onClick={() => setMode(v)} aria-pressed={mode === v}>
              <span className="iico">{ic}</span><span className="grow" style={{ textAlign: 'left' }}><span className="lr-t">{l}{v === 'standard' && <span className="lr-s" style={{ display: 'inline', marginLeft: U(10) }}>· default</span>}</span><span className="lr-s">{d}</span></span><span className={`radio${mode === v ? ' on' : ''}`} />
            </button>
          ))}
        </div>
        <p className="t-mute" style={{ margin: `${U(8)} ${U(8)} 0` }}>Privacy type can’t be changed after the group is created.</p>
      </>)}
      <Label>Add members{sel.length > 0 ? ` · ${sel.length} selected` : ''}</Label>
      {people.length === 0 && <Empty icon={<Users />} title="No anonymous contacts" sub="Pair with people via QR first, then create a group." />}
      {people.map((u) => (
        <LRow key={u.id} teal={anon} icon={<Avatar name={u.name} size={70} anon={anon} presence={u.presence} />} title={u.name} sub={u.about ?? u.phone ?? 'SYSTEMBOOM user'} chev={false} onClick={() => toggle(u.id)}
          right={<span className={`iswitch${sel.includes(u.id) ? ' on' : ''}`}><i /></span>} />
      ))}
    </PageShell>
  );
}

export default function Page() { return <Suspense><NewGroup /></Suspense>; }
