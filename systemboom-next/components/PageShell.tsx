'use client';

import { useRouter } from 'next/navigation';
import { Bell, ChevronLeft } from 'lucide-react';
import type { ReactNode } from 'react';
import { Art, At, K, Press, U, useToast } from '@/lib/ui';
import { Dock, type Tab } from './Dock';

export function ChromeBtn({ children, onClick, gold = false, badge, label }: { children: ReactNode; onClick?: () => void; gold?: boolean; badge?: string; label: string }) {
  return (
    <Press onClick={onClick} pop shine={false} label={label} style={{ width: '100%', height: '100%', borderRadius: '50%', position: 'relative' }}>
      <div className={gold ? 'gold-ring' : 'chrome-ring'} style={{ position: 'absolute', inset: 0, padding: '6%', boxShadow: `0 ${K(5)} ${K(8)} rgba(0,0,0,.8)${gold ? ', 0 0 ' + K(16) + ' rgba(255,170,40,.55)' : ''}` }}>
        <div style={{ width: '100%', height: '100%', borderRadius: '50%', display: 'grid', placeItems: 'center', background: gold ? 'radial-gradient(circle at 35% 25%,#3a2a10,#0e0904 75%)' : 'radial-gradient(circle at 35% 25%,#2b3540,#0b0f13 75%)', color: gold ? '#ffd27a' : '#dfe6ee' }}>
          {children}
        </div>
      </div>
      {badge && <span className="badge" style={{ position: 'absolute', right: K(-12), top: K(-12), minWidth: K(40), height: K(40), padding: `0 ${K(8)}`, fontSize: K(23), animation: 'breathe 4s ease-in-out infinite' }}>{badge}</span>}
    </Press>
  );
}

/** Shared page frame: metal header (back arrow, title, bell), scrolling body and the bottom dock. */
export function PageShell({ title, active, right, children }: { title: string; active: Tab; right?: ReactNode; children: ReactNode }) {
  const router = useRouter();
  const toast = useToast();
  return (
    <div className="stage">
      <header style={{ position: 'relative', zIndex: 5 }}>
        <Art w={854} h={209} src="hdr-calls">
          <At x={38} y={52} w={92} h={92}>
            <ChromeBtn label="Back" onClick={() => (window.history.length > 1 ? router.back() : router.push('/'))}>
              <ChevronLeft style={{ width: '58%', height: '58%' }} strokeWidth={2.2} />
            </ChromeBtn>
          </At>
          <At x={0} y={104} w={854} style={{ textAlign: 'center', transform: 'translateY(-50%)', fontSize: K(68), fontWeight: 900, lineHeight: 1, pointerEvents: 'none' }}>
            <span className="silver-text">{title}</span>
          </At>
          <At x={724} y={52} w={92} h={92}>
            {right ?? (
              <ChromeBtn label="Notifications" gold badge="14" onClick={() => toast('Notifications')}>
                <Bell style={{ width: '54%', height: '54%' }} strokeWidth={1.8} />
              </ChromeBtn>
            )}
          </At>
        </Art>
      </header>
      <main className="page-pad" style={{ padding: `${U(10)} ${U(26)} 0`, paddingBottom: U(340) }}>{children}</main>
      <Dock active={active} />
    </div>
  );
}
