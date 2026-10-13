'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { createPortal } from 'react-dom';
import { useEffect, useRef, useState } from 'react';
import { Home, MessageSquare, Phone, Store, User, VenetianMask } from 'lucide-react';
import { At, Art, K, img } from '@/lib/ui';

export type Tab = 'home' | 'chats' | 'calls' | 'market' | 'profile';

const ITEMS = [
  { id: 'home', label: 'Home', href: '/', x: 38, y: 62, w: 104, h: 118, cx: 85, cy: 105, Icon: Home, lx: 23 },
  { id: 'chats', label: 'Chats', href: '/chats/', x: 205, y: 72, w: 105, h: 106, cx: 258, cy: 108, Icon: MessageSquare, lx: 197 },
  { id: 'market', label: 'Market', href: '/market/', x: 575, y: 68, w: 112, h: 110, cx: 628, cy: 108, Icon: Store, lx: 568 },
  { id: 'profile', label: 'Profile', href: '/profile/', x: 752, y: 72, w: 96, h: 106, cx: 800, cy: 108, Icon: User, lx: 740 },
] as const;


const FAN = [
  { href: '/chats/', label: 'Chats', Icon: MessageSquare, glow: '#5ab8f2', a: -60 },
  { href: '/calls/', label: 'Calls', Icon: Phone, glow: '#ff9a2a', a: -20 },
  { href: '/market/', label: 'Marketplace', Icon: Store, glow: '#ffd27a', a: 20 },
  { href: '/anonymous/', label: 'Anonymous', Icon: VenetianMask, glow: '#28e6d7', a: 60 },
] as const;

/** The Calls orb. Hovering it (mouse) or tapping it (touch) fans out a circular menu: Chats, Calls, Marketplace, Anonymous.
 *  With the menu already open from hovering, a click goes straight to Calls. */
function CallsOrb() {
  const router = useRouter();
  const ref = useRef<HTMLAnchorElement>(null);
  const timer = useRef<ReturnType<typeof setTimeout>>(undefined);
  const viaTap = useRef(false);
  const [open, setOpen] = useState(false);
  const [mounted, setMounted] = useState(false);
  const [geo, setGeo] = useState({ x: 0, y: 0, u: 1 });
  useEffect(() => { setMounted(true); return () => clearTimeout(timer.current); }, []);

  const show = (tap: boolean) => {
    clearTimeout(timer.current);
    const r = ref.current?.getBoundingClientRect();
    if (!r) return;
    if (tap) viaTap.current = true;
    setGeo({ x: r.left + r.width / 2, y: r.top + r.height / 2, u: (r.width / 148) * (896 / 941) });
    setOpen(true);
  };
  const hideSoon = () => {
    if (viaTap.current) return; // opened by touch: stays until dismissed
    clearTimeout(timer.current);
    timer.current = setTimeout(() => setOpen(false), 320);
  };
  const close = () => { clearTimeout(timer.current); viaTap.current = false; setOpen(false); };
  const go = (href: string) => { close(); router.push(href); };

  const R = 400 * geo.u;
  return (
    <>
      <Link
        ref={ref}
        href="/calls/"
        aria-label="Calls"
        className="press calls-orb"
        style={{ display: 'block', width: '100%', height: '100%', borderRadius: '50%' }}
        onPointerEnter={(e) => { if (e.pointerType === 'mouse') show(false); }}
        onPointerLeave={(e) => { if (e.pointerType === 'mouse') hideSoon(); }}
        onClick={(e) => {
          e.preventDefault();
          if (!open) show(true);
          else if (viaTap.current) close();
          else go('/calls/');
        }}
      >
        <span className="orb-ping" />
        <img src={img('nav-calls')} alt="" draggable={false} style={{ width: '100%', height: '100%', display: 'block' }} />
      </Link>
      {mounted && createPortal(
        <div className={'orbmenu' + (open ? ' on' : '')} style={{ ['--ox' as string]: `${geo.x}px`, ['--oy' as string]: `${geo.y}px`, ['--ou' as string]: `${geo.u}px`, pointerEvents: open ? 'auto' : 'none' }} aria-hidden={!open}>
          <div className="orbdim" onClick={close} style={{ pointerEvents: open && viaTap.current ? 'auto' : 'none' }} />
          <div className="orbhalo" />
          <div className="orbring" />
          <div className="orbzone" onPointerEnter={() => clearTimeout(timer.current)} onPointerLeave={(e) => { if (e.pointerType === 'mouse') hideSoon(); }} />
          {FAN.map(({ href, label, Icon, glow, a }, i) => {
            const rad = (a * Math.PI) / 180;
            return (
              <button
                key={label}
                className="orbitem"
                tabIndex={open ? 0 : -1}
                onPointerEnter={() => clearTimeout(timer.current)}
                onPointerLeave={(e) => { if (e.pointerType === 'mouse') hideSoon(); }}
                onClick={() => go(href)}
                style={{ ['--tx' as string]: `${Math.sin(rad) * R}px`, ['--ty' as string]: `${-Math.cos(rad) * R * 0.92 - 10 * geo.u}px`, ['--g' as string]: glow, ['--i' as string]: i, ['--rot' as string]: a < 0 ? '-70deg' : '70deg' }}
              >
                <span className="orbbtn"><img src={img('share-ring')} alt="" draggable={false} /><Icon strokeWidth={1.8} /></span>
                <b>{label}</b>
              </button>
            );
          })}
        </div>,
        document.body,
      )}
    </>
  );
}

/** Shared inner content of the dock (icons, labels, Calls orb). Rendered inside an <Art> with k = width/896. */
export function DockContent({ active, dy = 0 }: { active: Tab; dy?: number }) {
  return (
    <>
      {ITEMS.map(({ id, label, href, x, y, w, h, cx, cy, Icon, lx }, i) => (
        <div key={id}>
          <At x={x} y={y + dy} w={w} h={h} style={{ borderRadius: K(30) }}>
            <Link href={href} className="press dock-hit" aria-label={label} style={{ display: 'block', width: '100%', height: '100%', borderRadius: 'inherit' }}>
              <span className={`dock-glyph g${i}`} style={{ left: K(cx - x - 31), top: K(cy - y - 31), width: K(62), height: K(62), animationDelay: `${-i * 0.9}s` }}>
                <Icon strokeWidth={1.7} className="gl" />
              </span>
              <span className="shine" />
            </Link>
          </At>
          <At x={lx} y={141 + dy} w={120} style={{ textAlign: 'center', fontSize: K(26), fontWeight: 700, lineHeight: 1, color: active === id ? '#ffd9a6' : '#f1f4f7', textShadow: active === id ? `0 0 ${K(8)} rgba(255,120,20,.8)` : `0 ${K(1.5)} ${K(2)} rgba(0,0,0,.8)`, pointerEvents: 'none' }}>
            {label}
          </At>
        </div>
      ))}
      <At x={380} y={141 + dy} w={120} style={{ textAlign: 'center', fontSize: K(26), fontWeight: 700, lineHeight: 1, color: '#ffe9d0', textShadow: `0 0 ${K(8)} rgba(255,120,20,.8)`, pointerEvents: 'none' }}>
        Calls
      </At>
      {/* unread badge on Chats */}
      <At x={272} y={62 + dy} style={{ minWidth: K(46), height: K(46), padding: `0 ${K(10)}`, fontSize: K(26), pointerEvents: 'none' }} className="badge">10</At>
      {/* Calls orb (art's own button, animated) */}
      <At x={374} y={2 + dy} w={148} h={148}>
        <CallsOrb />
      </At>
    </>
  );
}

/** Standalone bottom dock for inner pages. */
export function Dock({ active }: { active: Tab }) {
  return (
    <div className="dock">
      <Art w={896} h={215} src="dock">
        <DockContent active={active} />
      </Art>
    </div>
  );
}
