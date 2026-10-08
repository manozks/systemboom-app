'use client';

import Link from 'next/link';
import { ChevronRight, Store, VenetianMask, Palette } from 'lucide-react';
import type { CSSProperties, ReactNode } from 'react';
import { Art, At, K, Press, U, img, useToast } from '@/lib/ui';
import { DockContent } from '@/components/Dock';

/** A block placed in page design units (941 per stage width) and optionally scaled from its top-left corner. */
function Abs({ x, y, w, h, scale = 1, children, style }: { x: number; y: number; w: number; h?: number; scale?: number; children: ReactNode; style?: CSSProperties }) {
  return (
    <div style={{ position: 'absolute', left: U(x), top: U(y), width: U(w), height: h ? U(h) : undefined, transform: scale === 1 ? undefined : `scale(${scale})`, transformOrigin: '0 0', ...style }}>
      {children}
    </div>
  );
}

/** Deterministic spark cloud above the podium (no randomness at render time, so SSR matches). */
function Sparks() {
  const dots = Array.from({ length: 36 }, (_, i) => {
    const r = (n: number) => { const s = Math.sin(i * 91.7 + n * 13.3) * 10000; return s - Math.floor(s); };
    const c = (r(1) + r(2) + r(3)) / 3;
    return { left: `${c * 100}%`, top: `${30 + r(4) * 62}%`, dur: 2.4 + r(5) * 3.4, delay: -r(6) * 5, dx: (r(7) - 0.5) * 70, big: i % 6 === 0 };
  });
  return (
    <div style={{ position: 'absolute', left: '35%', width: '30%', top: '28%', height: '40%', pointerEvents: 'none' }} aria-hidden>
      {dots.map((d, i) => (
        <i key={i} className={`spark${d.big ? ' big' : ''}`} style={{ left: d.left, top: d.top, ['--d' as string]: `${d.dur}s`, ['--dl' as string]: `${d.delay}s`, ['--dx' as string]: `${d.dx}px` }} />
      ))}
    </div>
  );
}

type CardDef = { x: number; y: number; base: string; tile: string; tw: number; title: string; sub: string; href: string; badge?: string; badgeBg?: string; badgeFg?: string; icon?: ReactNode };

export default function Home() {
  const toast = useToast();
  const cards: CardDef[] = [
    { x: 26, y: 895, base: 'card-base-blue', tile: 'ico-chat-ref', tw: 95, title: 'Chats', sub: 'Direct & group', href: '/chats/', badge: '10' },
    { x: 475, y: 895, base: 'card-base-dark', tile: 'ico-call-ref', tw: 85, title: 'Calls', sub: 'Voice & video', href: '/calls/' },
    { x: 26, y: 1135, base: 'card-base-dark', tile: 'ico-mk', tw: 85, title: 'Marketplace', sub: 'Shop in chat', href: '/market/', badge: '1', badgeBg: 'radial-gradient(circle at 35% 30%,#ffd37a,#e09a1c 55%,#b36f08)', badgeFg: '#2a1700', icon: <Store style={{ width: '56%', height: '56%', color: '#ffe6b0', filter: 'drop-shadow(0 0 6px #ffb432)' }} strokeWidth={1.7} /> },
    { x: 475, y: 1135, base: 'card-base-dark', tile: 'ico-an', tw: 85, title: 'Anonymous', sub: 'Speak freely', href: '/anonymous/', badge: '3', badgeBg: 'radial-gradient(circle at 35% 30%,#7cfff0,#12bfb0 55%,#0a7f76)', badgeFg: '#032a27', icon: <VenetianMask style={{ width: '56%', height: '56%', color: '#b6fff4', filter: 'drop-shadow(0 0 6px #28ebd7)' }} strokeWidth={1.7} /> },
  ];

  return (
    <div className="stage">
      <div style={{ position: 'relative', height: U(2110), overflow: 'hidden' }}>
        {/* ── hero ── */}
        <Abs x={21} y={29} w={861} scale={1.038}>
          <Art w={861} h={355} style={{ filter: `drop-shadow(0 ${U(8)} ${U(12)} rgba(0,0,0,.7)) drop-shadow(0 0 ${U(14)} rgba(255,120,20,.3))` }}>
            <img className="bg" src={img('hero-nobomb')} alt="" draggable={false} style={{ clipPath: 'polygon(0.3% 15.5%,17% 15.5%,24% 0.3%,76% 0.3%,83% 15.5%,99.7% 15.5%,99.7% 83%,94.5% 99.7%,5.5% 99.7%,0.3% 83%)' }} />
            <div className="podium-glow" />
            <Sparks />
            <At x={78} y={62} w={600}><img src={img('logo-lockup')} alt="SYSTEMBOOM" draggable={false} style={{ width: '100%', display: 'block', WebkitMaskImage: 'linear-gradient(90deg,transparent,#000 5%,#000 95%,transparent)', maskImage: 'linear-gradient(90deg,transparent,#000 5%,#000 95%,transparent)' }} /></At>
            <At x={790} y={55} w={37} h={37} className="badge" style={{ fontSize: K(25), animation: 'breathe 4s ease-in-out infinite' }}>14</At>
            <At x={742} y={40} w={100} h={100}><Press pop shine={false} label="Notifications" onClick={() => toast('Notifications')} style={{ width: '100%', height: '100%', borderRadius: '50%' }} /></At>
          </Art>
        </Abs>

        {/* ── greeting ── */}
        <Abs x={21} y={411} w={865} scale={1.025}>
          <Art w={865} h={206} src="greeting-new" style={{ filter: `drop-shadow(0 ${U(8)} ${U(10)} rgba(0,0,0,.65))` }}>
            <At x={278} y={40} style={{ fontSize: K(27), fontWeight: 800, letterSpacing: '.12em', color: '#e8ecf1', textShadow: `0 ${K(-1)} 0 #000, 0 ${K(1.5)} 0 rgba(255,255,255,.5), 0 ${K(3)} ${K(3)} rgba(0,0,0,.7)` }}>GOOD MORNING</At>
            <At x={268} y={72}><span className="silver-text" style={{ fontSize: K(74), fontWeight: 800, lineHeight: 1, whiteSpace: 'nowrap', letterSpacing: '-.01em' }}>Aarav Sharma</span></At>
            <At x={70} y={30} w={150} h={150}><Press pop shine={false} label="Change profile photo" onClick={() => toast('Change profile photo')} style={{ width: '100%', height: '100%', borderRadius: '50%' }} /></At>
          </Art>
        </Abs>

        {/* ── start a conversation ── */}
        <Abs x={24} y={621} w={856} scale={1.026}>
          <Art w={843} h={211} src="cta-new" style={{ filter: `drop-shadow(0 ${U(12)} ${U(16)} rgba(0,0,0,.75)) drop-shadow(0 0 ${U(24)} rgba(255,122,26,.42))` }}>
            <At x={50} y={38} w={600}>
              <div className="gold-text" style={{ fontSize: K(46), fontWeight: 800, lineHeight: 1.15 }}>Start a conversation</div>
              <div style={{ fontSize: K(31), lineHeight: 1.22, marginTop: K(8), color: '#f2f4f7', textShadow: `0 ${K(2)} ${K(2)} rgba(0,0,0,.7)` }}>Everything begins with a chat — decisions, calls, and purchases.</div>
            </At>
            <At x={672} y={38} w={138} h={138}>
              <Link href="/chats/" aria-label="Start a conversation" className="press pop" style={{ display: 'block', width: '100%', height: '100%', borderRadius: '50%' }} />
            </At>
          </Art>
        </Abs>

        {/* ── explore ── */}
        <Abs x={37} y={848} w={300}><span style={{ fontSize: U(30), fontWeight: 800, letterSpacing: '.1em', color: '#c7cfd7', textShadow: `0 ${U(1.5)} 0 rgba(255,255,255,.25), 0 ${U(-1.5)} 0 rgba(0,0,0,.9)` }}>EXPLORE</span></Abs>
        {cards.map((c) => (
          <Abs key={c.title} x={c.x} y={c.y} w={429}>
            <Link href={c.href} style={{ display: 'block' }} aria-label={`${c.title} — ${c.sub}`}>
              <Press className="explore-card" style={{ borderRadius: U(34) }}>
                <Art w={429} h={220} src={c.base} style={{ filter: `drop-shadow(0 ${U(8)} ${U(10)} rgba(0,0,0,.6))` }}>
                  <At x={36} y={38} w={c.tw} h={80} style={{ filter: `drop-shadow(0 ${K(5)} ${K(6)} rgba(0,0,0,.65))` }}>
                    <img className="tile" src={img(c.tile)} alt="" draggable={false} style={{ width: '100%', height: '100%', borderRadius: K(22), display: 'block' }} />
                    {c.icon && <div style={{ position: 'absolute', inset: 0, display: 'grid', placeItems: 'center' }}>{c.icon}</div>}
                  </At>
                  <At x={40} y={127} style={{ fontSize: K(41), fontWeight: 800, lineHeight: 1.05, textShadow: `0 ${K(1.5)} 0 #0a1018, 0 ${K(4)} ${K(4)} rgba(0,0,0,.7)` }}>{c.title}</At>
                  <At x={41} y={170} style={{ fontSize: K(31), lineHeight: 1, color: '#eef3f9', textShadow: `0 ${K(1.5)} ${K(2)} rgba(0,0,0,.7)` }}>{c.sub}</At>
                  {c.badge && <At x={357} y={28} w={40} h={40} className="badge" style={{ fontSize: K(22), background: c.badgeBg, color: c.badgeFg ?? '#fff' }}>{c.badge}</At>}
                </Art>
              </Press>
            </Link>
          </Abs>
        ))}

        {/* ── design system ── */}
        <Abs x={26} y={1375} w={878}>
          <Link href="/design/" style={{ display: 'block' }} aria-label="Design System">
            <Press style={{ borderRadius: U(34) }}>
              <Art w={878} h={172} src="cta-blank-wide" style={{ filter: `drop-shadow(0 ${U(8)} ${U(10)} rgba(0,0,0,.6)) drop-shadow(0 0 ${U(14)} rgba(255,140,50,.3))` }}>
                <At x={78} y={47} w={84} h={78} style={{ filter: `drop-shadow(0 ${K(5)} ${K(6)} rgba(0,0,0,.65))` }}>
                  <img src={img('ico-ds')} alt="" draggable={false} style={{ width: '100%', height: '100%', borderRadius: K(22), display: 'block' }} />
                  <div style={{ position: 'absolute', inset: 0, display: 'grid', placeItems: 'center' }}><Palette style={{ width: '56%', height: '56%', color: '#c9f6ff', filter: 'drop-shadow(0 0 6px #3fd2f2)' }} strokeWidth={1.7} /></div>
                </At>
                <At x={204} y={40} style={{ fontSize: K(41), fontWeight: 800, lineHeight: 1 }}>Design System</At>
                <At x={204} y={86} style={{ fontSize: K(31), lineHeight: 1, color: '#eef3f9' }}>Foundation tokens &amp; components</At>
                <At x={204} y={126} style={{ display: 'flex', gap: K(10) }}>
                  {['#2fd3e6', '#e8a838', '#25c9b5', '#7a5cf0', '#e8643c'].map((c) => <i key={c} style={{ width: K(34), height: K(6), borderRadius: K(3), background: c, boxShadow: `0 0 ${K(6)} ${c}` }} />)}
                </At>
                <At x={0} y={64} w={44} h={44} style={{ right: K(84), left: 'auto', color: '#9fb2c8' }}><ChevronRight style={{ width: '100%', height: '100%' }} strokeWidth={2.2} /></At>
              </Art>
            </Press>
          </Link>
        </Abs>

        {/* ── AI companion + dock ── */}
        <Abs x={0} y={1562} w={896} scale={1.0502}>
          <Art w={896} h={515} src="ai-nav" style={{ filter: `drop-shadow(0 ${U(8)} ${U(10)} rgba(0,0,0,.6))` }}>
            <At x={370} y={33} style={{ fontSize: K(27), fontWeight: 800, letterSpacing: '.13em', color: '#d9dfe6', textShadow: `0 ${K(-1)} 0 #000, 0 ${K(1.5)} 0 rgba(255,255,255,.4)` }}>MY AI COMPANION</At>
            <At x={370} y={66}><span className="gold-text" style={{ fontSize: K(35), fontWeight: 800, lineHeight: 1, whiteSpace: 'nowrap' }}>Eos - Your Digital Strategist</span></At>
            <At x={371} y={102} style={{ fontSize: K(30), lineHeight: 1.3, fontWeight: 500, color: '#f6f8fa', textShadow: `0 ${K(2)} ${K(3)} rgba(0,0,0,.8)` }}>Optimizing your day, every day.<br />Last sync: 3 mins ago</At>
            <At x={368} y={210} w={452} h={82}>
              <Press flat shine={false} label="Configure Avatar" onClick={() => toast('Configure Avatar')} style={{ width: '100%', height: '100%', borderRadius: K(42), display: 'flex', alignItems: 'center', paddingLeft: K(70), fontSize: K(30), fontWeight: 800, textShadow: `0 ${K(2)} 0 #06102e, 0 0 ${K(8)} rgba(130,180,255,.9)` }}>
                Configure Avatar
              </Press>
            </At>
            <DockContent active="home" dy={300} />
          </Art>
        </Abs>
      </div>
    </div>
  );
}
