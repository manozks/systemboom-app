import { img } from '@/lib/ui';

/**
 * Profile photo inside a segmented glass ring: twelve dark glass plates (some lit cyan like a progress gauge), a fine tick scale and
 * bright dots in the gaps. Still at rest; hovering or pressing makes the lit plates breathe and the dots twinkle.
 */
const N = 12; // plates
const GAP = 5; // degrees between plates
const R1 = 66; // plate inner radius
const R2 = 89; // plate outer radius
const LIT = new Set([6, 7, 8, 9, 10]); // plate indexes (clockwise from the top gap) that are lit: bottom -> left side

const pt = (r: number, deg: number) => {
  const a = ((deg - 90) * Math.PI) / 180;
  return [r * Math.cos(a), r * Math.sin(a)] as const;
};
const sector = (a0: number, a1: number) => {
  const [x0, y0] = pt(R2, a0), [x1, y1] = pt(R2, a1), [x2, y2] = pt(R1, a1), [x3, y3] = pt(R1, a0);
  return `M${x0.toFixed(2)} ${y0.toFixed(2)} A${R2} ${R2} 0 0 1 ${x1.toFixed(2)} ${y1.toFixed(2)} L${x2.toFixed(2)} ${y2.toFixed(2)} A${R1} ${R1} 0 0 0 ${x3.toFixed(2)} ${y3.toFixed(2)} Z`;
};

export function ProfileRing({ photo = 'profile-photo' }: { photo?: string }) {
  const span = 360 / N;
  return (
    <svg className="pring" viewBox="-100 -100 200 200" aria-hidden>
      <defs>
        <linearGradient id="prDark" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#46506a" />
          <stop offset="1" stopColor="#1a2032" />
        </linearGradient>
        <linearGradient id="prLit" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#fff1bd" />
          <stop offset=".32" stopColor="#ffc94d" />
          <stop offset=".66" stopColor="#e39419" />
          <stop offset="1" stopColor="#8f5207" />
        </linearGradient>
        <linearGradient id="prGloss" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#ffffff" stopOpacity=".7" />
          <stop offset=".5" stopColor="#ffffff" stopOpacity=".12" />
          <stop offset=".52" stopColor="#ffffff" stopOpacity="0" />
        </linearGradient>
        <radialGradient id="prWell" cx=".5" cy=".5" r=".5">
          <stop offset=".8" stopColor="#0a0f1c" />
          <stop offset="1" stopColor="#1c2438" />
        </radialGradient>
        <clipPath id="prClip"><circle r="58" /></clipPath>
        <filter id="prGlow" x="-30%" y="-30%" width="160%" height="160%"><feGaussianBlur stdDeviation="2.4" /></filter>
      </defs>

      {/* tick scale */}
      {Array.from({ length: 60 }, (_, i) => {
        const long = i % 5 === 0;
        const [x0, y0] = pt(long ? 93 : 94.5, i * 6), [x1, y1] = pt(98, i * 6);
        return <line key={i} x1={x0} y1={y0} x2={x1} y2={y1} stroke="rgba(255,226,170,.55)" strokeWidth={long ? 1.1 : .6} />;
      })}

      {/* well behind the plates */}
      <circle r={R2 + 1.5} fill="url(#prWell)" />

      {/* plates */}
      {Array.from({ length: N }, (_, i) => {
        const a0 = i * span + GAP / 2, a1 = (i + 1) * span - GAP / 2;
        const lit = LIT.has(i);
        return (
          <g key={i} className={lit ? 'pr-lit' : undefined} style={lit ? { animationDelay: `${(i - 6) * 0.12}s` } : undefined}>
            {lit && <path d={sector(a0, a1)} fill="#ffb02e" opacity=".6" filter="url(#prGlow)" />}
            {/* 3D: a dark under-edge dropped a hair below the plate, then the plate, a bevel line and a glossy sheen */}
            <path d={sector(a0, a1)} fill={lit ? '#5a3203' : '#05080f'} opacity=".7" transform="translate(0 1.4)" />
            <path d={sector(a0, a1)} fill={lit ? 'url(#prLit)' : 'url(#prDark)'} stroke={lit ? 'rgba(255,244,205,.9)' : 'rgba(255,255,255,.2)'} strokeWidth="1" strokeLinejoin="round" />
            <path d={sector(a0 + 1.5, a1 - 1.5)} fill="none" stroke={lit ? 'rgba(255,255,255,.4)' : 'rgba(255,255,255,.08)'} strokeWidth=".7" strokeLinejoin="round" transform="scale(.97)" />
            <path d={sector(a0 + .8, a1 - .8)} fill="url(#prGloss)" opacity={lit ? 1 : .35} />
          </g>
        );
      })}

      {/* bright dots in the gaps */}
      {Array.from({ length: N }, (_, i) => {
        const [x, y] = pt(R2 + 3.2, i * span);
        return <circle key={i} className="pr-dot" cx={x} cy={y} r="1.5" fill="#fff" style={{ animationDelay: `${i * 0.15}s` }} />;
      })}

      {/* photo */}
      <circle r="62" fill="#0a0f1c" stroke="rgba(255,214,120,.8)" strokeWidth="1.4" />
      <image href={img(photo)} x="-58" y="-58" width="116" height="116" clipPath="url(#prClip)" preserveAspectRatio="xMidYMid slice" />
      <circle r="58" fill="none" stroke="rgba(0,0,0,.45)" strokeWidth="2" />
    </svg>
  );
}
