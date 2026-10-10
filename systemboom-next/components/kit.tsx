'use client';

import { Check, ChevronRight, Info, Package } from 'lucide-react';
import { cloneElement, isValidElement, type ButtonHTMLAttributes, type CSSProperties, type ReactNode } from 'react';
import { Art, At, K, Press, U } from '@/lib/ui';

export const cx = (...a: (string | false | undefined | null)[]) => a.filter(Boolean).join(' ');

export function Plate({ children, className, style, onClick, variant }: { children?: ReactNode; className?: string; style?: CSSProperties; onClick?: () => void; variant?: 'flat' | 'hot' | 'teal' }) {
  const Tag = onClick ? 'button' : 'div';
  return <Tag className={cx('plate', variant, className)} style={style} onClick={onClick}>{children}</Tag>;
}

export function Btn({ kind = 'steel', size, block, icon, children, ...rest }: { kind?: 'primary' | 'steel' | 'ghost' | 'danger' | 'teal'; size?: 'sm' | 'lg'; block?: boolean; icon?: ReactNode } & ButtonHTMLAttributes<HTMLButtonElement>) {
  const cls = kind === 'ghost' ? cx('btn', kind, size, block && 'block', rest.className) : cx('xbtn', kind, size, block && 'block', rest.className);
  return <button {...rest} className={cls}>{icon}{children}</button>;
}

export function IBtn({ children, tone, small, on, label, onClick, style }: { children: ReactNode; tone?: 'gold' | 'hot' | 'danger'; small?: boolean; on?: boolean; label: string; onClick?: () => void; style?: CSSProperties }) {
  return <button aria-label={label} title={label} className={cx('ibtn', tone, small && 'sm', on && 'on')} onClick={onClick} style={style}>{children}</button>;
}

export function Field({ label, children }: { label?: string; children: ReactNode }) {
  return <label className="field">{label && <span>{label}</span>}{children}</label>;
}

export function Switch({ on, onChange, label }: { on: boolean; onChange: (v: boolean) => void; label: string }) {
  return <button role="switch" aria-checked={on} aria-label={label} className={cx('iswitch', on && 'on')} onClick={() => onChange(!on)}><i /></button>;
}

export function Banner({ tone, icon, children }: { tone?: 'warn' | 'ok' | 'err'; icon?: ReactNode; children: ReactNode }) {
  return <div className={cx('banner', tone)}>{icon ?? <Info />}<div>{children}</div></div>;
}

export function Pill({ color = '#5ab8f2', children, icon }: { color?: string; children: ReactNode; icon?: ReactNode }) {
  return <span className="pill" style={{ ['--t' as string]: color }}>{icon}{children}</span>;
}

const HUES = ['#e5560a', '#7c5cff', '#1ea7a0', '#d94f8a', '#3b82f6', '#c28a1a', '#6d8f2f', '#b04a4a'];
const hueOf = (s: string) => HUES[[...s].reduce((a, c) => a + c.charCodeAt(0), 0) % HUES.length];
const initials = (n: string) => n.split(/\s+/).map((w) => w[0]).slice(0, 2).join('').toUpperCase();

export function Avatar({ name, size = 110, anon, presence, group }: { name: string; size?: number; anon?: boolean; presence?: 'online' | 'away' | 'offline'; group?: boolean }) {
  const c = hueOf(name);
  const dot = presence === 'online' ? '#33d17a' : presence === 'away' ? '#ffb02e' : undefined;
  return (
    <span className={cx('avatar', anon && 'anon')} style={{ width: U(size), height: U(size) }}>
      <span className="in">
        <span className="face" style={{ background: `radial-gradient(circle at 35% 25%, ${c}, #0c0f14 130%)`, fontSize: U(size * 0.36) }}>{group ? '👥' : initials(name)}</span>
      </span>
      {dot && <i className="dot" style={{ background: dot }} />}
    </span>
  );
}

export function LRow({ icon, title, sub, right, onClick, teal, chev = true }: { icon?: ReactNode; title: ReactNode; sub?: ReactNode; right?: ReactNode; onClick?: () => void; teal?: boolean; chev?: boolean }) {
  const isAv = isValidElement(icon) && icon.type === Avatar;
  const inner = (
    <>
      {icon && (isAv ? cloneElement(icon as React.ReactElement<{ size?: number }>, { size: 104 }) : <span className={cx('iico', teal && 'teal')}>{icon}</span>)}
      <span className="grow" style={{ minWidth: 0 }}><span className="lr-t ellip">{title}</span>{sub && <span className="lr-s ellip">{sub}</span>}</span>
      {right}
      {onClick && chev && !right && <ChevronRight className="chev" />}
    </>
  );
  return onClick
    ? <button className="mp dark lr" onClick={onClick}>{inner}</button>
    : <div className="mp dark lr">{inner}</div>;
}

export function Empty({ icon, title, sub, children }: { icon?: ReactNode; title: string; sub?: string; children?: ReactNode }) {
  return (
    <div className="empty">
      <div className="ring">{icon ?? <Package />}</div>
      <div className="t-title" style={{ marginBottom: U(10) }}>{title}</div>
      {sub && <div className="t-mute" style={{ marginBottom: U(30) }}>{sub}</div>}
      {children}
    </div>
  );
}

export function Sheet({ open, onClose, title, children }: { open: boolean; onClose: () => void; title?: string; children: ReactNode }) {
  if (!open) return null;
  return (
    <>
      <div className="scrim" onClick={onClose} />
      <div className="sheet" role="dialog" aria-label={title}>
        <Plate className="pad">
          {title && <div className="t-title" style={{ marginBottom: U(20) }}>{title}</div>}
          {children}
        </Plate>
      </div>
    </>
  );
}

export function Dialog({ open, onClose, title, text, confirm = 'Delete', cancel = 'Cancel', onConfirm }: { open: boolean; onClose: () => void; title: string; text?: string; confirm?: string; cancel?: string; onConfirm: () => void }) {
  if (!open) return null;
  return (
    <>
      <div className="scrim" onClick={onClose} />
      <div className="dialog dlg" role="dialog" aria-label={title}>
        <Art w={513} h={262} src="dialog-bg">
          <At x={34} y={72} r={34} style={{ fontSize: K(38), fontWeight: 800, lineHeight: 1.1, color: '#fff', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', textShadow: `0 ${K(3)} ${K(4)} rgba(0,0,0,.9)` }}>{title}</At>
          <At x={34} y={118} r={34} style={{ fontSize: K(19), lineHeight: 1.25, color: '#e9eef3' }}>{text}</At>
          <At x={36} y={160} w={212} h={58}><Press shine={false} label={cancel} onClick={onClose} style={{ width: '100%', height: '100%', borderRadius: K(20), display: 'grid', placeItems: 'center', fontSize: K(25), fontWeight: 800, color: '#fff', textShadow: `0 ${K(2)} ${K(3)} rgba(0,0,0,.9)` }}>{cancel}</Press></At>
          <At x={264} y={160} w={212} h={58}><Press shine={false} label={confirm} onClick={onConfirm} style={{ width: '100%', height: '100%', borderRadius: K(20), display: 'grid', placeItems: 'center', fontSize: K(25), fontWeight: 800, color: '#fff', textShadow: `0 ${K(2)} ${K(3)} rgba(90,0,0,.9)` }}>{confirm}</Press></At>
        </Art>
      </div>
    </>
  );
}

export function Label({ children }: { children: ReactNode }) { return <div className="olabel"><span>{children}</span></div>; }

export function Tick() { return <Check style={{ width: U(30), height: U(30) }} />; }

/** Product / media placeholder tile: gradient keyed by name, with an icon. */
const GRADS: Record<string, string> = {
  p1: 'linear-gradient(135deg,#ff9a3a,#7a2a02)', p2: 'linear-gradient(135deg,#7c5cff,#241552)', p3: 'linear-gradient(135deg,#4fb6a8,#0e3a36)', p4: 'linear-gradient(135deg,#5aa0ff,#112e66)',
  p5: 'linear-gradient(135deg,#e07aa8,#5c1a3c)', p6: 'linear-gradient(135deg,#9acb5a,#2d4510)', p7: 'linear-gradient(135deg,#d9a35a,#4a2d0a)', p8: 'linear-gradient(135deg,#b0b8c4,#2a323c)',
  'prod-1': 'linear-gradient(135deg,#ff9a3a,#7a2a02)', 'grad-1': 'linear-gradient(135deg,#6c63ff,#e5560a)', 'grad-2': 'linear-gradient(135deg,#1ea7a0,#3b2a8c)',
};
export const gradFor = (k: string) => GRADS[k] ?? `linear-gradient(135deg, ${hueOf(k)}, #10151c)`;

export function ProdImg({ k, size = 130, radius = 26, fill, children }: { k: string; size?: number; radius?: number; fill?: boolean; children?: ReactNode }) {
  return <div className="pimg" style={{ width: fill ? '100%' : U(size), height: fill ? '100%' : U(size), borderRadius: fill ? 0 : U(radius), border: fill ? 0 : undefined, background: gradFor(k) }}>{children ?? <Package style={{ width: '42%', height: '42%' }} />}</div>;
}


export type Act = { label: string; icon?: ReactNode; danger?: boolean; onSelect: () => void };

/** Bottom action sheet: list of icon + label rows (prototype ActionSheet). */
export function ActionSheet({ open, onClose, title, actions }: { open: boolean; onClose: () => void; title?: string; actions: Act[] }) {
  if (!open) return null;
  return (
    <>
      <div className="scrim" onClick={onClose} />
      <div className="sheet asheet" role="dialog" aria-label={title}>
        <div className="apanel">
          {title && <div className="atitle">{title}</div>}
          {actions.map((a) => (
            <button key={a.label} className={cx('arow2', a.danger && 'danger')} onClick={() => { onClose(); a.onSelect(); }}>
              {a.icon && <span className="aico">{a.icon}</span>}
              <span className="alab">{a.label}</span>
            </button>
          ))}
        </div>
      </div>
    </>
  );
}

/** Segmented control (options as buttons). */
export function Seg<T extends string>({ value, onChange, options }: { value: T; onChange: (v: T) => void; options: { value: T; label: string }[] }) {
  return <div className="chips">{options.map((o) => <button key={o.value} className={cx('chip', value === o.value && 'on')} onClick={() => onChange(o.value)}>{o.label}</button>)}</div>;
}
