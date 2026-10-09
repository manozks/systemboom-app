'use client';

/** Deterministic pseudo-QR from the public key (decorative; the prototype has no real encoder). */
export function QrGrid({ seed, size = 29 }: { seed: string; size?: number }) {
  const cells: boolean[] = [];
  let h = 2166136261;
  for (let i = 0; i < size * size; i++) {
    h ^= seed.charCodeAt(i % seed.length) + i * 31;
    h = Math.imul(h, 16777619) >>> 0;
    cells.push((h >>> 7) % 5 < 2);
  }
  const finder = (x: number, y: number) => {
    const inF = (ox: number, oy: number) => x >= ox && x < ox + 7 && y >= oy && y < oy + 7;
    const f = (ox: number, oy: number) => { const dx = x - ox, dy = y - oy; return dx === 0 || dy === 0 || dx === 6 || dy === 6 || (dx >= 2 && dx <= 4 && dy >= 2 && dy <= 4); };
    if (inF(0, 0)) return f(0, 0);
    if (inF(size - 7, 0)) return f(size - 7, 0);
    if (inF(0, size - 7)) return f(0, size - 7);
    return null;
  };
  return (
    <svg viewBox={`0 0 ${size} ${size}`} style={{ width: '100%', display: 'block', background: '#fff', borderRadius: 8, padding: 0 }} shapeRendering="crispEdges">
      {cells.map((c, i) => { const x = i % size, y = Math.floor(i / size); const f = finder(x, y); const on = f === null ? c : f; return on ? <rect key={i} x={x} y={y} width={1} height={1} fill="#0a1a18" /> : null; })}
    </svg>
  );
}
