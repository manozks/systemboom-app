'use client';

import Link from 'next/link';
import { Home, MessageSquare, Store, User } from 'lucide-react';
import { At, Art, K, img } from '@/lib/ui';

export type Tab = 'home' | 'chats' | 'calls' | 'market' | 'profile';

const ITEMS = [
  { id: 'home', label: 'Home', href: '/', x: 38, y: 62, w: 104, h: 118, cx: 85, cy: 105, Icon: Home, lx: 23 },
  { id: 'chats', label: 'Chats', href: '/chats/', x: 205, y: 72, w: 105, h: 106, cx: 258, cy: 108, Icon: MessageSquare, lx: 197 },
  { id: 'market', label: 'Market', href: '/market/', x: 575, y: 68, w: 112, h: 110, cx: 628, cy: 108, Icon: Store, lx: 568 },
  { id: 'profile', label: 'Profile', href: '/profile/', x: 752, y: 72, w: 96, h: 106, cx: 800, cy: 108, Icon: User, lx: 740 },
] as const;

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
        <Link href="/calls/" aria-label="Calls" className="press calls-orb" style={{ display: 'block', width: '100%', height: '100%', borderRadius: '50%' }}>
          <span className="orb-ping" />
          <img src={img('nav-calls')} alt="" draggable={false} style={{ width: '100%', height: '100%', display: 'block' }} />
        </Link>
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
