'use client';

import { useRouter } from 'next/navigation';
import { Lock, QrCode, ScanLine, UserCog, Users, VenetianMask } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Avatar, Banner, Empty, Label, LRow, Plate } from '@/components/kit';
import { conversationTitle, latestMessage, useActiveAnon, useConversationList, useStore } from '@/lib/data/store';
import { listTime } from '@/lib/data/format';
import { U } from '@/lib/ui';

export default function AnonymousPage() {
  const router = useRouter();
  const { state } = useStore();
  const me = useActiveAnon();
  const list = useConversationList({ env: 'anonymous' });
  const tiles: [string, React.ReactNode, string][] = [['Scan', <ScanLine key="a" />, '/anon-scan/'], ['My QR', <QrCode key="b" />, '/anon-qr/'], ['Identities', <UserCog key="c" />, '/anon-id/'], ['New group', <Users key="d" />, '/new-group/?anon=1']];
  return (
    <PageShell title="Anonymous" active="home">
      <Plate variant="teal" className="pad">
        <div className="rowflex">
          <Avatar name={me.name} size={130} anon />
          <div className="grow"><div className="t-mute">Active identity</div><div className="t-name ellip" style={{ fontSize: U(40) }}>{me.name}</div><div className="t-mute">{me.sessionId}</div></div>
          <VenetianMask style={{ width: U(64), height: U(64), color: '#4ff0e0', filter: 'drop-shadow(0 0 8px #28e6d7)' }} />
        </div>
      </Plate>
      <div style={{ height: U(22) }} />
      <div className="grid2" style={{ gridTemplateColumns: 'repeat(4,1fr)', gap: U(14) }}>
        {tiles.map(([l, ic, to]) => (
          <button key={l} className="plate flat teal" style={{ padding: `${U(22)} 0`, display: 'grid', placeItems: 'center', gap: U(8), color: '#b6fff4', fontSize: U(24), fontWeight: 700 }} onClick={() => router.push(to)}>
            <span style={{ width: U(60), height: U(60), display: 'grid' }} className="">{ic}</span>{l}
          </button>
        ))}
      </div>
      <div style={{ height: U(22) }} />
      <Banner tone="ok" icon={<Lock />}>Anonymous conversations are always end-to-end encrypted. Contacts see only a temporary name and your public key.</Banner>
      <Label>Anonymous chats</Label>
      {!list.length && <Empty icon={<VenetianMask />} title="No anonymous chats" sub="Scan a QR code to pair with someone." />}
      {list.map((c) => {
        const last = latestMessage(c, state.messages);
        const t = conversationTitle(c, state.users);
        return <LRow key={c.id} teal icon={<Avatar name={t} size={70} anon group={c.kind === 'group'} />} title={t} sub={last?.text ?? last?.type} right={<span className="t-mute" style={{ textAlign: 'right' }}>{last ? listTime(last.createdAt) : ''}{c.unread > 0 && <span className="badge" style={{ display: 'block', margin: `${U(6)} 0 0 auto`, width: U(44), height: U(44), fontSize: U(24) }}>{c.unread}</span>}</span>} onClick={() => router.push(`/chat/?id=${c.id}`)} />;
      })}
    </PageShell>
  );
}
