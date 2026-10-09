'use client';

import { Suspense, useEffect, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { Mic, MicOff, Phone, Video, VideoOff, Volume2, VolumeX } from 'lucide-react';
import { Art, At, K, Press, img } from '@/lib/ui';

const fmt = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;
const initials = (n: string) => n.split(/\s+/).map((w) => w[0]).slice(0, 2).join('').toUpperCase();
const BX = [155, 365, 575, 785];
const ico = { width: '46%', height: '46%' } as const;

function Call() {
  const sp = useSearchParams();
  const router = useRouter();
  const name = sp.get('name') ?? 'Unknown';
  const photo = sp.get('photo');
  const [video, setVideo] = useState(sp.get('video') === '1');
  const [secs, setSecs] = useState(-2); // -2..-1 = ringing
  const [mute, setMute] = useState(false);
  const [spk, setSpk] = useState(true);
  const [ended, setEnded] = useState(false);

  useEffect(() => {
    if (ended) return;
    const t = setInterval(() => setSecs((s) => s + 1), 1000);
    return () => clearInterval(t);
  }, [ended]);

  const end = () => { setEnded(true); setTimeout(() => (window.history.length > 1 ? router.back() : router.push('/calls/')), 900); };
  const ringing = secs < 0 && !ended;
  const status = ended ? `Call ended · ${fmt(Math.max(secs, 0))}` : ringing ? (video ? 'Video calling…' : 'Calling…') : fmt(secs);

  const buttons = [
    { label: mute ? 'Unmute' : 'Mute', on: mute, onClick: () => setMute(!mute), icon: mute ? <MicOff style={ico} strokeWidth={1.7} /> : <Mic style={ico} strokeWidth={1.7} />, color: mute ? '#ffb866' : '#fff' },
    { label: spk ? 'Speaker off' : 'Speaker on', on: spk, onClick: () => setSpk(!spk), icon: spk ? <Volume2 style={ico} strokeWidth={1.7} /> : <VolumeX style={ico} strokeWidth={1.7} />, color: spk ? '#ff9a3a' : '#fff' },
    { label: video ? 'Camera off' : 'Camera on', on: video, onClick: () => setVideo(!video), icon: video ? <Video style={ico} strokeWidth={1.7} /> : <VideoOff style={ico} strokeWidth={1.7} />, color: video ? '#ffb866' : '#fff' },
    { label: 'End call', on: false, onClick: end, icon: <Phone style={{ ...ico, transform: 'rotate(135deg)', fill: 'currentColor' }} strokeWidth={1.4} />, color: '#ffe0b0' },
  ];

  return (
    <div className="stage" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
      <Art w={941} h={1365} src="call-bg" style={{ maskImage: 'linear-gradient(180deg, transparent 0, #000 6%, #000 94%, transparent 100%)', WebkitMaskImage: 'linear-gradient(180deg, transparent 0, #000 6%, #000 94%, transparent 100%)' }}>
        {ringing && <At x={175} y={50} w={590} h={590}><span style={{ position: 'absolute', inset: 0, borderRadius: '50%', border: `${K(6)} solid rgba(255,150,50,.75)`, animation: 'ping 1.8s ease-out infinite' }} /></At>}
        <At x={262} y={137} w={416} h={416} style={{ display: 'grid', placeItems: 'center', borderRadius: '50%', overflow: 'hidden' }}>
          {photo ? <img src={img(photo)} alt={name} draggable={false} style={{ width: '100%', height: '100%', objectFit: 'cover' }} /> : (
            <span className="chrome-text" style={{ fontSize: K(190), fontWeight: 900, lineHeight: 1, letterSpacing: '-0.02em', filter: `drop-shadow(0 ${K(3)} 0 #1d2a0a) drop-shadow(0 0 ${K(14)} rgba(255,150,40,.9))` }}>{initials(name)}</span>
          )}
        </At>
        <At x={0} y={730} w={941} style={{ textAlign: 'center', transform: 'translateY(-50%)', padding: `0 ${K(60)}`, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
          <span style={{ fontSize: K(name.length > 14 ? 78 : 98), fontWeight: 900, lineHeight: 1, color: '#fff', letterSpacing: '0.01em', textShadow: 'none' }}>{name}</span>
        </At>
        <At x={0} y={824} w={941} style={{ textAlign: 'center', transform: 'translateY(-50%)', fontSize: K(50), fontWeight: 600, color: ended ? '#ff9a8f' : '#ffb347', textShadow: `0 0 ${K(14)} rgba(255,140,30,.9)`, fontVariantNumeric: 'tabular-nums' }}>{status}</At>
        {buttons.map((b, i) => (
          <At key={b.label} x={BX[i] - 92} y={990 - 92} w={184} h={184}>
            <Press pop shine={false} label={b.label} onClick={b.onClick} style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', color: b.color, filter: `drop-shadow(0 0 ${K(10)} ${b.on || i === 3 ? 'rgba(255,140,30,.9)' : 'rgba(255,255,255,.35)'})` }}>
              {b.icon}
            </Press>
          </At>
        ))}
      </Art>
    </div>
  );
}

export default function Page() { return <Suspense><Call /></Suspense>; }
