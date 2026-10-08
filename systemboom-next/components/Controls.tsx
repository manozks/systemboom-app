'use client';

import type { ReactNode } from 'react';
import { Mic, Search } from 'lucide-react';
import { Art, At, K, Press, img } from '@/lib/ui';

/** Reference search bar art (chrome rim, steel-blue glass) with live icon + input. */
export function SearchBar({ value, onChange, placeholder, mic = false }: { value: string; onChange: (v: string) => void; placeholder: string; mic?: boolean }) {
  return (
    <Art w={851} h={83} src="search-bar" style={{ filter: 'drop-shadow(0 6px 8px rgba(0,0,0,.6))' }}>
      <At x={34} y={0} h={83} style={{ display: 'flex', alignItems: 'center' }}>
        <Search style={{ width: K(40), height: K(40) }} strokeWidth={2} />
      </At>
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        aria-label={placeholder}
        style={{ position: 'absolute', left: K(92), right: K(mic ? 92 : 40), top: 0, height: '100%', background: 'none', border: 0, outline: 0, color: '#fff', fontSize: K(27) }}
      />
      {mic && (
        <At x={0} y={0} h={83} style={{ right: K(34), left: 'auto', display: 'flex', alignItems: 'center' }}>
          <Mic style={{ width: K(40), height: K(40) }} strokeWidth={2} />
        </At>
      )}
    </Art>
  );
}

/** Three joined glass tabs with a sliding glowing orange key (reference art). */
export function SegTabs({ items, index, onChange }: { items: { label: string; icon?: ReactNode }[]; index: number; onChange: (i: number) => void }) {
  return (
    <Art w={856} h={82} src="tabs-base" style={{ filter: 'drop-shadow(0 6px 8px rgba(0,0,0,.6))' }}>
      <img
        src={img('tabs-key')}
        alt=""
        draggable={false}
        style={{ position: 'absolute', top: 0, height: '100%', width: K(280), left: K(8 + 280 * index), transition: 'left .32s cubic-bezier(.3,1.4,.5,1)', filter: `drop-shadow(0 0 ${K(14)} rgba(255,120,20,.6))` }}
      />
      {items.map((it, i) => (
        <At key={it.label} x={8 + 280 * i} y={0} w={280} h={82}>
          <Press flat shine={false} onClick={() => onChange(i)} label={it.label} style={{ width: '100%', height: '100%', borderRadius: K(30), display: 'flex', alignItems: 'center', justifyContent: 'center', gap: K(14), fontSize: K(27), fontWeight: 600 }}>
            {it.icon}
            {it.label}
          </Press>
        </At>
      ))}
    </Art>
  );
}

/** "RECENT CALLS  ......  See All >" style heading */
export function ListHeading({ title, action = 'See All', onAction }: { title: string; action?: string; onAction?: () => void }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: `calc(34 * var(--u)) calc(8 * var(--u)) calc(16 * var(--u))` }}>
      <span style={{ fontSize: 'calc(40 * var(--u))', fontWeight: 800, letterSpacing: '.4px' }}>{title}</span>
      <Press flat shine={false} onClick={onAction} style={{ fontSize: 'calc(33 * var(--u))', fontWeight: 600, padding: 'calc(6 * var(--u)) calc(8 * var(--u))', borderRadius: 'calc(20 * var(--u))' }}>
        {action} ›
      </Press>
    </div>
  );
}
