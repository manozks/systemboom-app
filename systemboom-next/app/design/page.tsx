'use client';

import { useState } from 'react';
import { Bell, Camera, Home, Mail, MapPin, MessageSquare, MoreHorizontal, Phone, Search, Settings, ShoppingCart, SlidersHorizontal, User, Heart, Palette } from 'lucide-react';
import { PageShell, ChromeBtn } from '@/components/PageShell';
import { Art, At, K, Press, img, useToast } from '@/lib/ui';

const BRAND = [
  ['Primary', '#FF8A00', '#ffb24a'], ['Secondary', '#00B2FF', '#5accff'], ['Accent', '#A855F7', '#c98bff'], ['Success', '#22C55E', '#6be69a'],
  ['Danger', '#EF4444', '#ff8a8a'], ['Warning', '#F59E0B', '#ffd36a'], ['Neutral', '#94A3B8', '#c6d0de'],
];
const TYPE = [
  ['Heading 1', '28 / Bold', 800], ['Heading 2', '24 / SemiBold', 700], ['Heading 3', '20 / SemiBold', 700],
  ['Heading 4', '16 / Medium', 500], ['Body Text', '14 / Regular', 400], ['Caption', '12 / Regular', 400],
] as const;
const ICONS = [Home, MessageSquare, Phone, ShoppingCart, User, Settings, Bell, Heart, Search, SlidersHorizontal, MapPin, Camera, Mail, MoreHorizontal];
const IX = [36, 150, 266, 380, 494, 608, 722];
const IY = [62, 150];
const BTN: [number, number][] = [[30, 218], [236, 422], [440, 622], [640, 822]];
const BNAMES = ['Primary', 'Secondary', 'Outline', 'Ghost'];
const BCOL = ['#ffb866', '#bfd8ff', '#fff', '#fff'];

const frameShadow = 'drop-shadow(0 10px 12px rgba(0,0,0,.7)) drop-shadow(0 0 18px rgba(255,122,26,.4))';
const title = (t: string, x = 32, y = 20, size = 30) => <At x={x} y={y} style={{ fontSize: K(size), fontWeight: 800 }}>{t}</At>;
const caption = (t: string, y = 26) => <At x={0} y={y} style={{ right: K(30), left: 'auto', fontSize: K(22), whiteSpace: 'nowrap' }}>{t}</At>;

export default function DesignPage() {
  const toast = useToast();
  const [icon, setIcon] = useState(0);

  return (
    <PageShell title="Design System" active="profile" right={<ChromeBtn label="Design tokens" gold onClick={() => toast('Design tokens')}><Palette style={{ width: '54%', height: '54%' }} strokeWidth={1.8} /></ChromeBtn>}>
      {/* Brand colours */}
      <div style={{ padding: 'calc(22 * var(--u)) 0 calc(34 * var(--u))' }}>
        <Art w={853} h={230} src="brand-colors" style={{ filter: frameShadow }}>
          {title('Brand Colors', 32, 22, 31)}
          {caption('Primary • Secondary • Status • Neutral', 28)}
          {BRAND.map(([name, hex, tint], i) => (
            <At key={name} x={22 + i * 114} y={60} w={114} h={160}>
              <Press flat shine={false} onClick={() => toast(`${name} ${hex}`)} style={{ width: '100%', height: '100%', borderRadius: K(20), display: 'flex', flexDirection: 'column', alignItems: 'center', paddingTop: K(88) }}>
                <span style={{ fontSize: K(17.5), fontWeight: 500, whiteSpace: 'nowrap' }}>{name}</span>
                <span style={{ fontSize: K(16), fontWeight: 700, color: tint, whiteSpace: 'nowrap' }}>{hex}</span>
              </Press>
            </At>
          ))}
        </Art>
      </div>

      {/* Typography */}
      <div style={{ marginBottom: 'calc(18 * var(--u))' }}>
        <Art w={853} h={278} src="typography" style={{ filter: frameShadow }}>
          {title('Typography', 34, 22, 29)}
          {caption('Font Family: Poppins (Recommended)', 28)}
          {([['Heading 1', 48, 900, 66], ['Heading 2', 38, 800, 120], ['Heading 3', 28, 700, 164], ['Heading 4', 21, 500, 199]] as const).map(([t, s, w, y]) => (
            <At key={t} x={36} y={y}><span className="chrome-text" style={{ fontSize: K(s), fontWeight: w, lineHeight: 1.1 }}>{t}</span></At>
          ))}
          <At x={36} y={226} style={{ fontSize: K(18) }}>Body Text</At>
          {TYPE.map(([name, spec, w], i) => (
            <At key={name} x={566} y={66 + i * 31.5} w={262}>
              <Press flat shine={false} onClick={() => toast(`${name} · ${spec}`)} style={{ display: 'flex', borderRadius: K(10) }}>
                <span style={{ width: K(124), fontSize: K(19), fontWeight: w }}>{name}</span>
                <span style={{ fontSize: K(18), color: '#e6ecf3' }}>{spec}</span>
              </Press>
            </At>
          ))}
        </Art>
      </div>

      {/* Buttons */}
      <div style={{ marginBottom: 'calc(18 * var(--u))' }}>
        <Art w={853} h={153} src="buttons-panel" style={{ filter: frameShadow }}>
          {title('Buttons', 32, 18, 28)}
          {caption('Primary • Secondary • Outline • Ghost', 24)}
          {BTN.map(([x0, x1], i) => (
            <At key={BNAMES[i]} x={x0} y={64} w={x1 - x0} h={70}>
              <Press onClick={() => toast(BNAMES[i])} label={BNAMES[i]} style={{ width: '100%', height: '100%', borderRadius: '999px', display: 'grid', placeItems: 'center', fontSize: K(26), fontWeight: 600, color: BCOL[i] }}>
                {BNAMES[i]}
              </Press>
            </At>
          ))}
        </Art>
      </div>

      {/* Icons */}
      <Art w={853} h={239} src="icons-panel" style={{ filter: frameShadow }}>
        {title('Icons', 32, 16, 28)}
        {caption('Navigation • Action • System', 22)}
        <img src={img('icon-key')} alt="" draggable={false} style={{ position: 'absolute', width: K(108), height: K(88), left: K(IX[icon % 7] - 8), top: K(IY[Math.floor(icon / 7)] - 6), transition: 'left .3s cubic-bezier(.3,1.4,.5,1), top .3s cubic-bezier(.3,1.4,.5,1)' }} />
        {ICONS.map((Icon, i) => (
          <At key={i} x={IX[i % 7]} y={IY[Math.floor(i / 7)]} w={92} h={76}>
            <Press flat pop shine={false} onClick={() => setIcon(i)} label={`Icon ${i + 1}`} style={{ width: '100%', height: '100%', borderRadius: K(24), display: 'grid', placeItems: 'center' }}>
              <Icon style={{ width: K(42), height: K(42), color: icon === i ? '#ffc66e' : '#fff' }} strokeWidth={1.8} />
            </Press>
          </At>
        ))}
      </Art>
      <p style={{ textAlign: 'center', color: '#7f8e9e', fontSize: 'calc(26 * var(--u))', marginTop: 'calc(30 * var(--u))' }}>Build once. Reuse everywhere. Consistency is a feature. — DS-003</p>
    </PageShell>
  );
}
