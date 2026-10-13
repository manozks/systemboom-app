'use client';

import { useEffect, useState } from 'react';

// deterministic pseudo-random so server and client render the same particles
const rnd = (i: number, k: number) => { const x = Math.sin(i * 127.1 + k * 311.7) * 43758.5453; return x - Math.floor(x); };
export const LAVA = Array.from({ length: 110 }, (_, i) => {
  const a = rnd(i, 1) * Math.PI * 2;
  const dist = 120 + Math.pow(rnd(i, 2), 0.7) * 520; // px
  return { dx: Math.cos(a) * dist, dy: Math.sin(a) * dist, size: 3 + rnd(i, 3) * 9, dur: 0.7 + rnd(i, 4) * 0.6, delay: rnd(i, 5) * 0.08, fall: 40 + rnd(i, 6) * 160 };
});

/** Lives in the root layout so it survives the route change: the splash swaps the app in at the flash's
 *  peak (event `sb-lava`), and the flash fades + lava sparks fly out over the real page. */
export default function LavaOverlay() {
  const [at, setAt] = useState<{ x: number; y: number } | null>(null);
  useEffect(() => {
    let t: ReturnType<typeof setTimeout>;
    const on = (e: Event) => {
      const d = (e as CustomEvent<{ x: number; y: number }>).detail;
      setAt(d);
      clearTimeout(t);
      t = setTimeout(() => setAt(null), 1400);
    };
    window.addEventListener('sb-lava', on);
    return () => { window.removeEventListener('sb-lava', on); clearTimeout(t); };
  }, []);
  if (!at) return null;
  return (
    <div className="lavafx" aria-hidden style={{ left: at.x, top: at.y }}>
      <div className="lavaflash" />
      {LAVA.map((p, i) => (
        <i key={i} style={{ ['--dx' as string]: `${p.dx}px`, ['--dy' as string]: `${p.dy}px`, ['--fall' as string]: `${p.fall}px`, width: p.size, height: p.size, animationDuration: `${p.dur}s`, animationDelay: `${p.delay}s` }} />
      ))}
    </div>
  );
}
