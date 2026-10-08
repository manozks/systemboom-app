'use client';

import { createContext, useCallback, useContext, useEffect, useRef, useState, type CSSProperties, type ReactNode } from 'react';

/** `calc(N * var(--u))` — N design units (941 per stage width). */
export const U = (n: number) => `calc(${n} * var(--u))`;
/** `calc(N * var(--k))` — N units inside an <Art> block. */
export const K = (n: number) => `calc(${n} * var(--k))`;

export const img = (name: string) => `${process.env.NEXT_PUBLIC_BASE_PATH || ''}/img/${name}.webp`;

// ───────── toast ─────────
const ToastCtx = createContext<(msg: string) => void>(() => {});
export const useToast = () => useContext(ToastCtx);

export function ToastProvider({ children }: { children: ReactNode }) {
  const [msg, setMsg] = useState('');
  const [on, setOn] = useState(false);
  const t = useRef<ReturnType<typeof setTimeout> | undefined>(undefined);
  const show = useCallback((m: string) => {
    setMsg(m);
    setOn(true);
    clearTimeout(t.current);
    t.current = setTimeout(() => setOn(false), 1600);
  }, []);
  return (
    <ToastCtx.Provider value={show}>
      {children}
      <div className={`toast${on ? ' show' : ''}`} role="status">{msg}</div>
    </ToastCtx.Provider>
  );
}

// ───────── Art: a picture designed at w x h; children are positioned with K(n) ─────────
export function Art({ w, h, src, children, style, className = '' }: { w: number; h: number; src?: string; children?: ReactNode; style?: CSSProperties; className?: string }) {
  return (
    <div className={`artbox ${className}`} style={{ aspectRatio: `${w} / ${h}`, ['--w' as string]: w, ...style }}>
      <div className="in">
        {src && <img className="bg" src={img(src)} alt="" draggable={false} />}
        {children}
      </div>
    </div>
  );
}

/** Absolutely positioned box in K units (inside <Art>) */
export function At({ x, y, w, h, r, children, style, className = '' }: { x?: number; y?: number; w?: number; h?: number; r?: number; children?: ReactNode; style?: CSSProperties; className?: string }) {
  return (
    <div className={`abs ${className}`} style={{ left: x !== undefined ? K(x) : undefined, top: y !== undefined ? K(y) : undefined, width: w !== undefined ? K(w) : undefined, height: h !== undefined ? K(h) : undefined, right: r !== undefined ? K(r) : undefined, ...style }}>
      {children}
    </div>
  );
}

/** Interactive wrapper: lifts on hover, squashes on press, optional shine sweep. */
export function Press({ onClick, children, className = '', style, shine = true, flat = false, pop = false, label }: { onClick?: () => void; children?: ReactNode; className?: string; style?: CSSProperties; shine?: boolean; flat?: boolean; pop?: boolean; label?: string }) {
  return (
    <div
      role="button"
      tabIndex={0}
      aria-label={label}
      className={`press ${flat ? 'flat' : ''} ${pop ? 'pop' : ''} ${className}`}
      style={style}
      onClick={onClick}
      onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onClick?.(); } }}
    >
      {children}
      {shine && <span className="shine" />}
    </div>
  );
}

/** Breathing glow loop used by a few ornaments */
export function useTick(ms = 60) {
  const [t, setT] = useState(0);
  useEffect(() => { const id = setInterval(() => setT((v) => v + ms / 1000), ms); return () => clearInterval(id); }, [ms]);
  return t;
}
