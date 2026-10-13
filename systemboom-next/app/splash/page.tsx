'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';

// Fuse path in the icon's own 1254x1254 space: from the spark at the far end to the bomb's fuse hole.
const FUSE = 'M874,306 C868.0,301.7 849.5,289.7 838,280 C826.5,270.3 815.0,259.0 805,248 C795.0,237.0 789.2,223.7 778,214 C766.8,204.3 754.0,196.3 738,190 C722.0,183.7 700.5,175.3 682,176 C663.5,176.7 644.2,187.0 627,194 C609.8,201.0 593.0,208.3 579,218 C565.0,227.7 552.7,240.8 543,252 C533.3,263.2 526.0,273.3 521,285 C516.0,296.7 512.3,311.5 513,322 C513.7,332.5 523.0,343.7 525,348';
const START = 0.4; // s before the fuse is lit
const BURN = 2.2; // s for the flame to travel the whole rope
const BLAST = 1.3; // s of blast + lava sparks before the app opens

// deterministic pseudo-random so server and client render the same particles
const rnd = (i: number, k: number) => { const x = Math.sin(i * 127.1 + k * 311.7) * 43758.5453; return x - Math.floor(x); };
const LAVA = Array.from({ length: 110 }, (_, i) => {
  const a = rnd(i, 1) * Math.PI * 2;
  const dist = 120 + Math.pow(rnd(i, 2), 0.7) * 520; // px
  return { dx: Math.cos(a) * dist, dy: Math.sin(a) * dist, size: 3 + rnd(i, 3) * 9, dur: 0.7 + rnd(i, 4) * 0.6, delay: rnd(i, 5) * 0.08, fall: 40 + rnd(i, 6) * 160 };
});

export default function Splash() {
  const router = useRouter();
  const [boom, setBoom] = useState(false);
  useEffect(() => {
    const t1 = setTimeout(() => setBoom(true), (START + BURN) * 1000);
    const t2 = setTimeout(() => router.replace('/welcome/'), (START + BURN + BLAST) * 1000);
    return () => { clearTimeout(t1); clearTimeout(t2); };
  }, [router]);
  return (
    <div className="stage center-screen splashfull" onClick={() => router.replace('/welcome/')}>
      <div className={'bombwrap' + (boom ? ' shake' : '')}>
        <img className="bombicon" src={`${process.env.NEXT_PUBLIC_BASE_PATH ?? ''}/img/bomb-icon.webp`} alt="SYSTEMBOOM" draggable={false} />
        <svg className="bombfx" viewBox="0 0 1254 1254" aria-hidden>
          <defs>
            <filter id="bblur" x="-20%" y="-20%" width="140%" height="140%"><feGaussianBlur stdDeviation="22" /></filter>
            <filter id="bblur2"><feGaussianBlur stdDeviation="6" /></filter>
            <radialGradient id="bflame"><stop offset="0" stopColor="#fff" /><stop offset=".22" stopColor="#fff2c0" /><stop offset=".5" stopColor="#ff9a2a" stopOpacity=".85" /><stop offset="1" stopColor="#ff5a00" stopOpacity="0" /></radialGradient>
            <radialGradient id="bash"><stop offset="0" stopColor="#120d0a" /><stop offset=".6" stopColor="#1c1410" stopOpacity=".9" /><stop offset="1" stopColor="#1c1410" stopOpacity="0" /></radialGradient>
            <mask id="burnt" maskUnits="userSpaceOnUse" x="0" y="0" width="1254" height="1254">
              <path d={FUSE} fill="none" stroke="#fff" strokeWidth="210" strokeLinecap="round" pathLength="1" strokeDasharray="1 1" strokeDashoffset="1">
                <animate attributeName="stroke-dashoffset" from="1" to="0" begin={`${START}s`} dur={`${BURN}s`} fill="freeze" calcMode="linear" />
              </path>
            </mask>
          </defs>
          <g mask="url(#burnt)">
            <path d={FUSE} fill="none" stroke="rgba(10,8,8,.55)" strokeWidth="200" strokeLinecap="round" filter="url(#bblur)" />
            <path d={FUSE} fill="none" stroke="#150f0b" strokeWidth="74" strokeLinecap="round" />
            <path d={FUSE} fill="none" stroke="#3a2a1e" strokeWidth="46" strokeLinecap="butt" strokeDasharray="8 15" opacity=".8" />
          </g>
          <circle cx="874" cy="306" r="62" fill="url(#bash)" opacity="0"><animate attributeName="opacity" from="0" to="1" begin={`${START}s`} dur=".3s" fill="freeze" /></circle>
          <g opacity="0">
            <set attributeName="opacity" to="1" begin={`${START}s`} fill="freeze" />
            <set attributeName="opacity" to="0" begin={`${START + BURN}s`} fill="freeze" />
            <animateMotion path={FUSE} begin={`${START}s`} dur={`${BURN}s`} fill="freeze" calcMode="linear" />
            <circle r="120" fill="url(#bflame)" opacity=".85"><animate attributeName="r" values="110;132;116;136;110" dur=".32s" repeatCount="indefinite" /></circle>
            <circle r="30" fill="#fff" filter="url(#bblur2)"><animate attributeName="r" values="26;36;28;38;26" dur=".24s" repeatCount="indefinite" /></circle>
            <g className="bsparks">
              {[[-50, -70], [60, -50], [-70, 30], [40, 70], [0, -95], [85, 10], [-30, 90]].map(([x, y], i) => <circle key={i} cx={x} cy={y} r={7 + (i % 3) * 2} fill="#ffb347" style={{ animationDelay: `${i * 0.11}s` }} />)}
            </g>
          </g>
        </svg>
        {boom && <div className="bombblast" />}
        {boom && (
          <div className="lava" aria-hidden>
            {LAVA.map((p, i) => (
              <i key={i} style={{ ['--dx' as string]: `${p.dx}px`, ['--dy' as string]: `${p.dy}px`, ['--fall' as string]: `${p.fall}px`, width: p.size, height: p.size, animationDuration: `${p.dur}s`, animationDelay: `${p.delay}s` }} />
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
