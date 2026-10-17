'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ArrowRight, Bell, ChevronRight, Store, VenetianMask, Palette } from 'lucide-react';
import { useEffect, useRef } from 'react';
import type { CSSProperties, ReactNode } from 'react';
import { Art, At, K, Press, U, img, useToast } from '@/lib/ui';
import { DockContent } from '@/components/Dock';
import { ChromeBtn } from '@/components/PageShell';

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


const HH_PLANETS = [
  { n: 'mercury', rx: 232, ry: 38, d: 30, rx1: 140, ry1: 13, d1: 17, T: 20, ph: 0.0 },
  { n: 'venus', rx: 232, ry: 38, d: 34, rx1: 140, ry1: 13, d1: 19, T: 20, ph: 0.5 },
  { n: 'moon', rx: 284, ry: 48, d: 36, rx1: 180, ry1: 16, d1: 20, T: 33, ph: 0.2 },
  { n: 'jupiter', rx: 336, ry: 58, d: 46, rx1: 225, ry1: 19, d1: 22, T: 53, ph: 0.0 },
  { n: 'saturn', rx: 336, ry: 58, d: 50, rx1: 225, ry1: 19, d1: 24, T: 53, ph: 0.5 },
];

const HH_EMBERS = [
  { rx: 232, ry: 38, rx1: 140, ry1: 13, T: 7, ph: 0.1, d: 5, rev: false, o: 1 },
  { rx: 232, ry: 38, rx1: 140, ry1: 13, T: 7, ph: 0.1291, d: 3.1, rev: false, o: 0.5 },
  { rx: 232, ry: 38, rx1: 140, ry1: 13, T: 7, ph: 0.62, d: 4, rev: true, o: 1 },
  { rx: 232, ry: 38, rx1: 140, ry1: 13, T: 7, ph: 0.5909, d: 2.5, rev: true, o: 0.5 },
  { rx: 284, ry: 48, rx1: 180, ry1: 16, T: 11, ph: 0.3, d: 5.5, rev: false, o: 1 },
  { rx: 284, ry: 48, rx1: 180, ry1: 16, T: 11, ph: 0.3185, d: 3.4, rev: false, o: 0.5 },
  { rx: 284, ry: 48, rx1: 180, ry1: 16, T: 11, ph: 0.7, d: 4.5, rev: true, o: 1 },
  { rx: 284, ry: 48, rx1: 180, ry1: 16, T: 11, ph: 0.6815, d: 2.8, rev: true, o: 0.5 },
  { rx: 284, ry: 48, rx1: 180, ry1: 16, T: 11, ph: 0.95, d: 4, rev: false, o: 1 },
  { rx: 284, ry: 48, rx1: 180, ry1: 16, T: 11, ph: 0.9685, d: 2.5, rev: false, o: 0.5 },
  { rx: 336, ry: 58, rx1: 225, ry1: 19, T: 17, ph: 0.05, d: 6, rev: false, o: 1 },
  { rx: 336, ry: 58, rx1: 225, ry1: 19, T: 17, ph: 0.062, d: 3.7, rev: false, o: 0.5 },
  { rx: 336, ry: 58, rx1: 225, ry1: 19, T: 17, ph: 0.35, d: 4.5, rev: true, o: 1 },
  { rx: 336, ry: 58, rx1: 225, ry1: 19, T: 17, ph: 0.338, d: 2.8, rev: true, o: 0.5 },
  { rx: 336, ry: 58, rx1: 225, ry1: 19, T: 17, ph: 0.6, d: 5.5, rev: false, o: 1 },
  { rx: 336, ry: 58, rx1: 225, ry1: 19, T: 17, ph: 0.612, d: 3.4, rev: false, o: 0.5 },
  { rx: 336, ry: 58, rx1: 225, ry1: 19, T: 17, ph: 0.85, d: 4, rev: true, o: 1 },
  { rx: 336, ry: 58, rx1: 225, ry1: 19, T: 17, ph: 0.838, d: 2.5, rev: true, o: 0.5 },
];

/** Deterministic twinkling stars scattered over the plate (no randomness at render time, so SSR matches). */
const HH_STARS = Array.from({ length: 20 }, (_, i) => {
  const r = (n: number) => { const s = Math.sin(i * 57.3 + n * 12.9) * 10000; return s - Math.floor(s); };
  return { x: (r(1) - 0.5) * 2 * 330, y: -120 + r(2) * 182, s: 5 + r(3) * 6, dur: 2 + r(4) * 2.6, dl: -r(5) * 4 };
});

/** Full-bleed, shorter hero header. It stays pinned and shrinks (c: 0 -> 1) over the first ~95 units of scrolling. */
function HomeHeader() {
  const router = useRouter();
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    let raf = 0;
    const update = () => {
      raf = 0;
      const u = el.offsetWidth / 941;
      // linear on purpose: the header's bottom edge then tracks the content scrolling up underneath it (no gap)
      const x = Math.min(1, Math.max(0, window.scrollY / (189 * u)));
      el.style.setProperty('--c', String(x));
      el.dataset.cmp = x > 0.4 ? '1' : '0';
    };
    const on = () => { if (!raf) raf = requestAnimationFrame(update); };
    update();
    window.addEventListener('scroll', on, { passive: true });
    window.addEventListener('resize', on);
    return () => { window.removeEventListener('scroll', on); window.removeEventListener('resize', on); cancelAnimationFrame(raf); };
  }, []);
  return (
    <div ref={ref} className="homehdr" style={{ ['--c' as string]: 0 }}>
      <div className="hh-scale">
        <Art w={854} h={236.9}>
          <i className="hh-hero" />
          <div className="hh-in">
          <At x={207} y={27.2} w={440} className="hh-logoat" style={{ zIndex: 2 }}>
            <img className="hh-logo" src={img('logo-lockup')} alt="SYSTEMBOOM" draggable={false} />
          </At>
          <At x={427} y={152} w={0} h={0} className="hh-orbit">
            <div className="hh-plate" aria-hidden><i className="pl-edge" /><i className="pl-base" /><i className="pl-sweep" /><i className="pl-ticks" /><i className="pl-rim" /><i className="pl-gloss" /></div>
            <div className="hh-stars" aria-hidden>
              {HH_STARS.map((st, i) => (
                <i key={i} className="hh-st" style={{ left: K(st.x), top: K(st.y), ['--s' as string]: st.s, ['--dur' as string]: `${st.dur}s`, ['--dl' as string]: `${st.dl}s` }} />
              ))}
            </div>
            {HH_EMBERS.map((e, i) => (
              <span key={i} className="hh-em" style={{ ['--rx0' as string]: e.rx, ['--ry0' as string]: e.ry, ['--rx1' as string]: e.rx1, ['--ry1' as string]: e.ry1, ['--d' as string]: e.d, ['--T' as string]: `${e.T}s`, ['--ph' as string]: e.ph, ['--o' as string]: e.o, animationDirection: e.rev ? 'alternate-reverse, alternate-reverse' : undefined }} />
            ))}
            {HH_PLANETS.map((p) => (
              <span key={p.n} className="hh-pl" style={{ ['--rx0' as string]: p.rx, ['--ry0' as string]: p.ry, ['--d0' as string]: p.d, ['--rx1' as string]: p.rx1, ['--ry1' as string]: p.ry1, ['--d1' as string]: p.d1, ['--T' as string]: `${p.T}s`, ['--ph' as string]: p.ph }}>
                <img src={img(`celestial/${p.n}`)} alt="" draggable={false} />
              </span>
            ))}
          </At>
          <At x={724} y={24.8} w={92} h={92} className="hh-bellw" style={{ zIndex: 4 }}>
            <ChromeBtn label="Notifications" gold badge="14" onClick={() => router.push('/notifications/')}>
              <Bell style={{ width: '54%', height: '54%' }} strokeWidth={1.8} />
            </ChromeBtn>
          </At>
          </div>
        </Art>
      </div>
      <i className="hh-fade" aria-hidden />
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
      <div style={{ position: 'relative', height: U(2110 - 142), overflow: 'clip' }}>
        <HomeHeader />

        {/* everything below sits in design units that started under the old, taller header: pull it up under the new one */}
        <div style={{ position: 'absolute', left: 0, top: U(-142), width: '100%' }}>
        {/* ── greeting ── */}
        <Abs x={21} y={411} w={865} scale={1.025}>
          <Art w={865} h={206} src="greeting-new" style={{ filter: `drop-shadow(0 ${U(8)} ${U(10)} rgba(0,0,0,.65))` }}>
            <At x={51.7} y={10} w={184} h={184} className="ringpulse" />
            <At x={51.7} y={10} w={184} h={184} className="ringsweep" />
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
            <At x={671} y={37} w={140} h={140} className="orbping cta" />
            <At x={671} y={37} w={140} h={140} className="ringpulse cta" />
            <At x={671} y={37} w={140} h={140} className="ringsweep cta" style={{ ['--in' as string]: '80%' }} />
            <At x={697} y={63} w={88} h={88} className="ctaarrow" aria-hidden><ArrowRight strokeWidth={2.4} className="a2" /><ArrowRight strokeWidth={2.4} className="a1" /></At>
            <At x={672} y={38} w={138} h={138}>
              <Link href="/chats/" aria-label="Start a conversation" className="press pop ctalink" style={{ display: 'block', width: '100%', height: '100%', borderRadius: '50%' }} />
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
                  <At x={36} y={38} w={c.tw} h={80} className="tilefx" style={{ filter: `drop-shadow(0 ${K(5)} ${K(6)} rgba(0,0,0,.65))`, ['--ph' as string]: `${-(c.x + c.y) % 7 * 0.4}s`, ['--tg' as string]: c.badgeBg ? '#ffd27a' : '#7ec8ff' }}>
                    <img className="tile" src={img(c.tile)} alt="" draggable={false} style={{ width: '100%', height: '100%', borderRadius: K(22), display: 'block' }} />
                    {c.icon && <div className="tileicon" style={{ position: 'absolute', inset: 0, display: 'grid', placeItems: 'center' }}>{c.icon}</div>}
                    <span className="tileripple" /><span className="tileshine" /><span className="tileorbit" />
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
                <At x={78} y={47} w={84} h={78} className="tilefx" style={{ filter: `drop-shadow(0 ${K(5)} ${K(6)} rgba(0,0,0,.65))`, ['--ph' as string]: '-1.2s', ['--tg' as string]: '#7fe3ff' }}>
                  <img className="tile" src={img('ico-ds')} alt="" draggable={false} style={{ width: '100%', height: '100%', borderRadius: K(22), display: 'block' }} />
                  <span className="tileripple" /><span className="tileshine" /><span className="tileorbit" />
                  <div className="tileicon" style={{ position: 'absolute', inset: 0, display: 'grid', placeItems: 'center' }}><Palette style={{ width: '56%', height: '56%', color: '#c9f6ff', filter: 'drop-shadow(0 0 6px #3fd2f2)' }} strokeWidth={1.7} /></div>
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
            <At x={368} y={210} w={452} h={82} className="btnwrap">
              <span className="btnglow" /><span className="btnshine" /><span className="btnorbit" />
              <Press flat shine={false} label="Configure Avatar" onClick={() => toast('Configure Avatar')} style={{ width: '100%', height: '100%', borderRadius: K(42), display: 'flex', alignItems: 'center', paddingLeft: K(70), fontSize: K(30), fontWeight: 800, textShadow: `0 ${K(2)} 0 #06102e, 0 0 ${K(8)} rgba(130,180,255,.9)` }}>
                Configure Avatar
              </Press>
            </At>
            <DockContent active="home" dy={300} />
          </Art>
        </Abs>
        </div>
      </div>
    </div>
  );
}
