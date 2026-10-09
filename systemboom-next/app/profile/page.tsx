'use client';

import { Bell, Camera, ChevronRight, Check, ClipboardList, Heart, Headphones, Mail, MapPin, MessageSquare, Pencil, Phone, Settings, ShoppingCart, Wallet } from 'lucide-react';
import { PageShell, ChromeBtn } from '@/components/PageShell';
import { useRouter } from 'next/navigation';
import { Art, At, K, Press, img, useToast } from '@/lib/ui';

const STATS = [
  { Icon: ShoppingCart, n: '24', label: 'Purchases' },
  { Icon: Heart, n: '18', label: 'Favorites' },
  { Icon: MessageSquare, n: '12', label: 'Reviews' },
  { Icon: MapPin, n: '5', label: 'Addresses' },
];
const COLS: [number, number][] = [[26, 218], [228, 422], [432, 628], [638, 832]];

const MENU = [
  { Icon: ClipboardList, title: 'My Orders', sub: 'Track and manage your orders', to: '/orders/' },
  { Icon: Heart, title: 'My Wishlist', sub: 'Products you saved', to: '/market/' },
  { Icon: MapPin, title: 'My Addresses', sub: 'Manage delivery addresses', to: '/settings/?s=privacy' },
  { Icon: Wallet, title: 'Payments & Wallet', sub: 'Manage payment methods', to: '/orders/' },
  { Icon: Bell, title: 'Notifications', sub: 'Manage your notifications', to: '/notifications/' },
];
const MENU2 = [
  { Icon: Settings, title: 'Account Settings', sub: 'Privacy, security and preferences', to: '/settings/' },
  { Icon: Headphones, title: 'Help & Support', sub: 'Get help or contact us', to: '/settings/?s=help' },
];

export default function ProfilePage() {
  const toast = useToast();
  const router = useRouter();
  const row = ({ Icon, title, sub, to }: (typeof MENU)[number]) => (
    <Press key={title} onClick={() => router.push(to)} style={{ marginBottom: 'calc(3 * var(--u))', borderRadius: 'calc(30 * var(--u))' }}>
      <Art w={856} h={104} src="menu-row" style={{ filter: 'drop-shadow(0 6px 8px rgba(0,0,0,.6))' }}>
        <At x={36} y={11} w={82} h={82}>
          <div className="gold-ring ring-spin" style={{ width: '100%', height: '100%', padding: K(5), boxShadow: `0 0 ${K(12)} rgba(255,122,26,.55)` }}>
            <div style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', background: 'radial-gradient(circle at 35% 25%,#3a2410,#0a0604)', color: '#ffb866' }}>
              <Icon style={{ width: '52%', height: '52%', filter: 'drop-shadow(0 0 6px #ff8c28)' }} strokeWidth={1.8} />
            </div>
          </div>
        </At>
        <At x={146} y={14} r={96} style={{ left: K(146) }}>
          <div style={{ fontSize: K(34), fontWeight: 800, lineHeight: 1.15 }}>{title}</div>
          <div style={{ fontSize: K(27), lineHeight: 1.2, color: '#f2f6fa' }}>{sub}</div>
        </At>
        <At x={0} y={28} w={48} h={48} style={{ right: K(30), left: 'auto' }}><ChevronRight style={{ width: '100%', height: '100%' }} strokeWidth={2} /></At>
      </Art>
    </Press>
  );

  return (
    <PageShell title="Profile" active="profile" right={<ChromeBtn label="Settings" gold onClick={() => router.push('/settings/')}><Settings style={{ width: '54%', height: '54%' }} strokeWidth={1.8} /></ChromeBtn>}>
      {/* profile card */}
      <Press onClick={() => toast('Profile details')} shine={false} style={{ borderRadius: 'calc(34 * var(--u))' }}>
        <Art w={860} h={289} src="profile-card" style={{ filter: 'drop-shadow(0 10px 12px rgba(0,0,0,.7)) drop-shadow(0 0 16px rgba(255,140,50,.3))' }}>
          <At x={302} y={34} style={{ display: 'flex', alignItems: 'center', gap: K(14) }}>
            <span className="silver-text" style={{ fontSize: K(46), fontWeight: 800, whiteSpace: 'nowrap' }}>Aarav Sharma</span>
            <span style={{ width: K(42), height: K(42), borderRadius: '50%', display: 'grid', placeItems: 'center', background: 'radial-gradient(circle at 35% 25%,#7abaff,#1e6fe0)', boxShadow: '0 0 12px #3c8cffaa' }}><Check style={{ width: '70%', height: '70%' }} strokeWidth={3} /></span>
          </At>
          {[[Mail, 'aarav.sharma@example.com', 90], [Phone, '+977 9851416684', 128], [MapPin, 'Kathmandu, Nepal', 166]].map(([I, t, y]) => {
            const Ic = I as typeof Mail;
            return (
              <At key={t as string} x={302} y={y as number} style={{ display: 'flex', alignItems: 'center', gap: K(16), fontSize: K(29), whiteSpace: 'nowrap' }}>
                <Ic style={{ width: K(32), height: K(32) }} strokeWidth={2} />{t as string}
              </At>
            );
          })}
          <At x={0} y={118} w={46} h={46} style={{ right: K(28), left: 'auto' }}><ChevronRight style={{ width: '100%', height: '100%' }} strokeWidth={2} /></At>
          <At x={186} y={182} w={74} h={74}><Press pop shine={false} label="Change photo" onClick={() => toast('Change photo')} style={{ width: '100%', height: '100%', borderRadius: '50%' }} /></At>
          <At x={300} y={204} w={318} h={66}><Press shine={false} label="Edit profile" onClick={() => router.push('/settings/?s=profile')} style={{ width: '100%', height: '100%', borderRadius: '999px' }} /></At>
        </Art>
      </Press>
      <div style={{ height: 'calc(18 * var(--u))' }} />

      {/* stats */}
      <Art w={856} h={178} src="stats-card" style={{ filter: 'drop-shadow(0 10px 12px rgba(0,0,0,.7)) drop-shadow(0 0 16px rgba(255,140,50,.3))' }}>
        {STATS.map(({ Icon, n, label }, i) => (
          <At key={label} x={COLS[i][0]} y={14} w={COLS[i][1] - COLS[i][0]} h={150}>
            <Press flat shine={false} onClick={() => router.push(label === 'Purchases' ? '/orders/' : label === 'Favorites' ? '/market/' : '/settings/')} style={{ width: '100%', height: '100%', borderRadius: K(24), display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
              <Icon style={{ width: K(50), height: K(50) }} strokeWidth={1.8} />
              <span className="gold-text" style={{ fontSize: K(44), fontWeight: 900, lineHeight: 1.1 }}>{n}</span>
              <span style={{ fontSize: K(25) }}>{label}</span>
            </Press>
          </At>
        ))}
      </Art>
      <div style={{ height: 'calc(22 * var(--u))' }} />

      {MENU.map(row)}
      <div style={{ height: 'calc(14 * var(--u))' }} />
      {MENU2.map(row)}
      <p style={{ textAlign: 'center', color: '#7f8e9e', fontSize: 'calc(26 * var(--u))', marginTop: 'calc(26 * var(--u))' }}>SYSTEMBOOM Chat · Prototype · Phase 1 Foundation</p>
    </PageShell>
  );
}
