'use client';

import { useRouter } from 'next/navigation';
import { AtSign, Bell, ChevronRight, Heart, MessageCircle, Package, PhoneMissed, UserPlus } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { Empty } from '@/components/kit';
import { useStore } from '@/lib/data/store';
import { listTime } from '@/lib/data/format';
import type { NotificationKind } from '@/lib/data/types';
import { U } from '@/lib/ui';

const ICON: Record<NotificationKind, React.ReactNode> = { message: <MessageCircle />, missed_call: <PhoneMissed />, mention: <AtSign />, group_invite: <UserPlus />, reaction: <Heart />, order: <Package /> };

export default function Notifications() {
  const router = useRouter();
  const { state, readNotification, readAllNotifications } = useStore();
  const unread = state.notifications.filter((n) => !n.read).length;
  return (
    <PageShell title="Notifications" active="profile" dock={false}>
      <div className="nhead">
        <span className="nunread">{unread} unread</span>
        <button className="nbtn" onClick={readAllNotifications} disabled={!unread}>Mark all read<ChevronRight /></button>
      </div>
      {state.notifications.length === 0 && <Empty icon={<Bell />} title="All caught up" sub="New notifications will appear here." />}
      {state.notifications.map((n) => (
        <button key={n.id} className="ncard" onClick={() => { readNotification(n.id); if (n.conversationId) router.push(`/chat/?id=${n.conversationId}`); }}>
          <span className="nico">{ICON[n.kind]}</span>
          <span className="nbody">
            <span className="nrow"><span className="ntitle ellip">{n.title}</span><span className="ntime">{!n.read && <i className="ndot" />}{listTime(n.at)}</span></span>
            <span className="nsub ellip">{n.body}</span>
          </span>
          <ChevronRight className="nchev" />
        </button>
      ))}
      <div style={{ height: U(10) }} />
    </PageShell>
  );
}
