'use client';

import { useMemo, useState } from 'react';
import { ArrowDownLeft, ArrowUpRight, Clock, MoreVertical, Phone, PhoneMissed, Star, Video } from 'lucide-react';
import { PageShell } from '@/components/PageShell';
import { ListHeading, SearchBar, SegTabs } from '@/components/Controls';
import { Art, At, K, Press, img, useToast } from '@/lib/ui';

type Kind = 'incoming' | 'missed' | 'outgoing' | 'video';
const CALLS: { name: string; initials: string; color: string; kind: Kind; when: string; duration?: string; fav?: boolean; photo?: string }[] = [
  { name: 'Priya Mehta', initials: 'PM', color: '#C03A8A', kind: 'incoming', when: 'Incoming Call • 2 mins ago', duration: '5:24', fav: true, photo: 'face1' },
  { name: 'Rohit Verma', initials: 'RV', color: '#2F6A8A', kind: 'missed', when: 'Missed Call • 1 hour ago', photo: 'face2' },
  { name: 'Sneha Kapoor', initials: 'SK', color: '#2F8A6A', kind: 'outgoing', when: 'Outgoing Call • 3 hours ago', duration: '12:36', fav: true, photo: 'face3' },
  { name: 'Amit Singh', initials: 'AS', color: '#6A4FC8', kind: 'video', when: 'Video Call • Yesterday', duration: '25:18', photo: 'face4' },
  { name: 'Boom Store', initials: 'BS', color: '#7A4FC8', kind: 'incoming', when: 'Incoming Call • Yesterday', duration: '2:05' },
  { name: 'Deepa Karki', initials: 'DK', color: '#C9801F', kind: 'missed', when: 'Missed Call • 2 days ago' },
];
const DIR: Record<Kind, { Icon: typeof Phone; color: string; ring: string }> = {
  incoming: { Icon: ArrowDownLeft, color: '#35E07F', ring: '#2FD070' },
  missed: { Icon: PhoneMissed, color: '#FF4A3D', ring: '#FF5A4D' },
  outgoing: { Icon: ArrowUpRight, color: '#4FC3FF', ring: '#4FA8FF' },
  video: { Icon: Video, color: '#C77DFF', ring: '#7A6AFF' },
};

export default function CallsPage() {
  const toast = useToast();
  const [q, setQ] = useState('');
  const [tab, setTab] = useState(0);
  const items = useMemo(
    () => CALLS.filter((c) => (tab === 1 ? c.kind === 'missed' : tab === 2 ? c.fav : true) && c.name.toLowerCase().includes(q.toLowerCase())),
    [q, tab],
  );

  return (
    <PageShell title="Calls" active="calls">
      <SearchBar value={q} onChange={setQ} placeholder="Search contacts, numbers or start a call..." mic />
      <div style={{ height: 'calc(22 * var(--u))' }} />
      <SegTabs
        index={tab}
        onChange={setTab}
        items={[
          { label: 'Recent', icon: <Clock style={{ width: K(38), height: K(38) }} strokeWidth={2} /> },
          { label: 'Missed', icon: <PhoneMissed style={{ width: K(38), height: K(38), color: '#ff4a3d' }} strokeWidth={2} /> },
          { label: 'Favorites', icon: <Star style={{ width: K(38), height: K(38), color: '#ffc24a', fill: '#ffc24a' }} strokeWidth={1.5} /> },
        ]}
      />
      <div style={{ height: 'calc(26 * var(--u))' }} />

      {/* Make a Call */}
      <Press onClick={() => toast('Make a call')} style={{ borderRadius: 'calc(34 * var(--u))' }}>
        <Art w={852} h={222} src="makecall-bg" style={{ filter: 'drop-shadow(0 10px 12px rgba(0,0,0,.7)) drop-shadow(0 0 16px rgba(255,120,30,.35))' }}>
          <At x={34} y={16} w={192} h={192}><img className="ring-spin" src={img('makecall-ring')} alt="" draggable={false} style={{ width: '100%', height: '100%' }} /></At>
          <At x={300} y={50} r={176} style={{ left: K(300) }}>
            <div className="gold-text" style={{ fontSize: K(58), fontWeight: 800, lineHeight: 1.1 }}>Make a Call</div>
            <div style={{ fontSize: K(29), lineHeight: 1.22, marginTop: K(8) }}>Connect with anyone, anywhere in the world.</div>
          </At>
          <At x={682} y={46} w={132} h={132}><img src={img('makecall-orb')} alt="" draggable={false} style={{ width: '100%', height: '100%' }} /></At>
        </Art>
      </Press>

      <ListHeading title="RECENT CALLS" onAction={() => toast('See all calls')} />
      {items.map((c) => {
        const d = DIR[c.kind];
        const video = c.kind === 'video';
        return (
          <Press key={c.name} onClick={() => toast(`Calling ${c.name}`)} style={{ marginBottom: 'calc(14 * var(--u))', borderRadius: 'calc(34 * var(--u))' }}>
            <Art w={856} h={150} src="cta-blank-wide" style={{ filter: 'drop-shadow(0 8px 10px rgba(0,0,0,.65)) drop-shadow(0 0 14px rgba(255,140,50,.28))' }}>
              <At x={44} y={22} w={106} h={106}>
                <div className="gold-ring" style={{ width: '100%', height: '100%', padding: K(5), boxShadow: `0 0 ${K(12)} ${d.ring}` }}>
                  <div style={{ width: '100%', height: '100%', borderRadius: '50%', background: '#0a0604', padding: K(3) }}>
                    {c.photo ? <img src={img(c.photo)} alt={c.name} style={{ width: '100%', height: '100%', borderRadius: '50%', objectFit: 'cover' }} /> : <div style={{ width: '100%', height: '100%', borderRadius: '50%', background: c.color, display: 'grid', placeItems: 'center', fontWeight: 800, fontSize: K(36) }}>{c.initials}</div>}
                  </div>
                </div>
              </At>
              <At x={178} y={28} r={250} style={{ left: K(178) }}>
                <div className={c.kind === 'missed' ? 'gold-text' : ''} style={{ fontSize: K(38), fontWeight: 800, lineHeight: 1.15, color: c.kind === 'missed' ? undefined : '#fff', ...(c.kind === 'missed' ? { background: 'linear-gradient(180deg,#ffd9d4,#ff7a6d 55%,#d6221a)', WebkitBackgroundClip: 'text', backgroundClip: 'text', WebkitTextFillColor: 'transparent' } : {}) }}>{c.name}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: K(10), marginTop: K(8), fontSize: K(28) }}>
                  <d.Icon style={{ width: K(34), height: K(34), color: d.color, flex: 'none' }} strokeWidth={2.2} />
                  <span style={{ whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{c.when}</span>
                </div>
              </At>
              {c.duration && <At x={0} y={0} h={150} style={{ right: K(190), left: 'auto', display: 'flex', alignItems: 'center', fontSize: K(31), fontWeight: 600 }}>{c.duration}</At>}
              <At x={0} y={26} w={98} h={98} style={{ right: K(76), left: 'auto' }}>
                <Press pop shine={false} onClick={() => toast(`${video ? 'Video call' : 'Calling'} · ${c.name}`)} style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', border: `${K(5)} solid ${video ? '#4a5cff' : '#ff9a3a'}`, background: video ? 'radial-gradient(circle at 35% 25%,#16206a,#080c30)' : 'radial-gradient(circle at 35% 25%,#3a2410,#0a0604)', boxShadow: `0 0 ${K(14)} ${video ? '#4a5cff' : '#ff9a3a'}, inset 0 0 ${K(12)} ${video ? 'rgba(74,92,255,.5)' : 'rgba(255,154,58,.5)'}` }}>
                  {video ? <Video style={{ width: '54%', height: '54%' }} strokeWidth={1.8} /> : <Phone style={{ width: '50%', height: '50%', color: '#ffc978', fill: '#ffc978' }} strokeWidth={1.6} />}
                </Press>
              </At>
              <At x={0} y={44} w={58} h={62} style={{ right: K(14), left: 'auto' }}>
                <Press flat shine={false} pop onClick={() => toast('More options')} style={{ width: '100%', height: '100%', display: 'grid', placeItems: 'center', borderRadius: K(18) }}><MoreVertical style={{ width: '70%', height: '70%' }} /></Press>
              </At>
            </Art>
          </Press>
        );
      })}
      {items.length === 0 && <p style={{ textAlign: 'center', color: '#8896a6', padding: 'calc(60 * var(--u))' }}>No calls found</p>}
    </PageShell>
  );
}
