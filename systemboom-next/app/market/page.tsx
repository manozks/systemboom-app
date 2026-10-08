'use client';

import { useMemo, useState } from 'react';
import { Briefcase, Car, ChevronDown, Heart, LayoutGrid, MapPin, Monitor, MoreVertical, Home as HomeIcon, ArrowUpDown, SlidersHorizontal, Tag, Wrench, Box } from 'lucide-react';
import { PageShell, ChromeBtn } from '@/components/PageShell';
import { SearchBar } from '@/components/Controls';
import { Art, At, K, Press, img, useToast } from '@/lib/ui';

const CATS = [
  { label: 'All', Icon: LayoutGrid },
  { label: 'Electronics', Icon: Monitor },
  { label: 'Vehicles', Icon: Car },
  { label: 'Property', Icon: HomeIcon },
  { label: 'Services', Icon: Wrench },
  { label: 'Jobs', Icon: Briefcase },
];
const SLOTS: [number, number][] = [[4, 150], [154, 292], [298, 436], [442, 580], [585, 724], [728, 864]];

const ITEMS = [
  { title: 'iPhone 14 Pro', kind: 'Mobile Phone', cat: 'Electronics', place: 'Kathmandu', price: 'Rs. 145,000', photo: 'prod1' },
  { title: 'Toyota Land Cruiser', kind: 'Car', cat: 'Vehicles', place: 'Kathmandu', price: 'Rs. 1,75,00,000', photo: 'prod2' },
  { title: 'Modern House', kind: 'Property', cat: 'Property', place: 'Lalitpur', price: 'Rs. 3,50,00,000', photo: 'prod3' },
  { title: 'MacBook Pro', kind: 'Laptop', cat: 'Electronics', place: 'Kathmandu', price: 'Rs. 2,40,000', photo: 'prod4' },
];

export default function MarketPage() {
  const toast = useToast();
  const [q, setQ] = useState('');
  const [cat, setCat] = useState(0);
  const [place, setPlace] = useState<string | null>(null);
  const [sort, setSort] = useState(false);
  const [liked, setLiked] = useState<Set<string>>(new Set());

  const items = useMemo(() => {
    const list = ITEMS.filter((p) => (cat === 0 || p.cat === CATS[cat].label) && (!place || p.place === place) && `${p.title} ${p.kind}`.toLowerCase().includes(q.toLowerCase()));
    return sort ? [...list].sort((a, b) => a.title.localeCompare(b.title)) : list;
  }, [q, cat, place, sort]);

  const pill = (x0: number, x1: number, Icon: typeof Tag, label: string, onClick: () => void) => (
    <At x={x0} y={14} w={x1 - x0} h={62}>
      <Press flat shine={false} onClick={onClick} label={label} style={{ width: '100%', height: '100%', borderRadius: '999px', display: 'flex', alignItems: 'center', padding: `0 ${K(14)}`, gap: K(10), fontSize: K(23), fontWeight: 600 }}>
        <Icon style={{ width: K(32), height: K(32), flex: 'none' }} strokeWidth={2} />
        <span style={{ flex: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{label}</span>
        <ChevronDown style={{ width: K(32), height: K(32), flex: 'none' }} strokeWidth={2} />
      </Press>
    </At>
  );

  return (
    <PageShell title="Marketplace" active="market" right={<ChromeBtn label="Orders" gold onClick={() => toast('Orders')}><Box style={{ width: '54%', height: '54%' }} strokeWidth={1.8} /></ChromeBtn>}>
      <SearchBar value={q} onChange={setQ} placeholder="Search listings" mic />
      <div style={{ height: 'calc(22 * var(--u))' }} />

      {/* category keys */}
      <Art w={867} h={132} src="cat-base" style={{ filter: 'drop-shadow(0 6px 8px rgba(0,0,0,.6))' }}>
        <img src={img('cat-key')} alt="" draggable={false} style={{ position: 'absolute', top: 0, height: '100%', width: K(SLOTS[0][1] - SLOTS[0][0] + 4), left: K(SLOTS[cat][0] - 2), transition: 'left .32s cubic-bezier(.3,1.4,.5,1)', filter: `drop-shadow(0 0 ${K(14)} rgba(255,120,20,.55))` }} />
        {CATS.map(({ label, Icon }, i) => (
          <At key={label} x={SLOTS[i][0]} y={0} w={SLOTS[i][1] - SLOTS[i][0]} h={132}>
            <Press flat shine={false} onClick={() => setCat(i)} label={label} style={{ width: '100%', height: '100%', borderRadius: K(26), display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: K(8), fontSize: K(24), fontWeight: 600 }}>
              <Icon style={{ width: K(58), height: K(58), color: cat === i ? '#ffc66e' : '#e5eaf0' }} strokeWidth={1.7} />
              {label}
            </Press>
          </At>
        ))}
      </Art>
      <div style={{ height: 'calc(22 * var(--u))' }} />

      {/* filters */}
      <Art w={858} h={90} src="filter-bar" style={{ filter: 'drop-shadow(0 6px 8px rgba(0,0,0,.6))' }}>
        {pill(22, 258, MapPin, place ?? 'Location', () => setPlace((p) => (p === null ? 'Kathmandu' : p === 'Kathmandu' ? 'Lalitpur' : null)))}
        {pill(270, 494, ArrowUpDown, sort ? 'Name' : 'Sort by', () => setSort((s) => !s))}
        {pill(508, 748, Tag, 'Price Range', () => toast('Price range'))}
        <At x={760} y={12} w={76} h={66}>
          <Press flat pop shine={false} onClick={() => toast('Filters')} label="Filters" style={{ width: '100%', height: '100%', display: 'grid', placeItems: 'center', borderRadius: K(22) }}>
            <SlidersHorizontal style={{ width: K(42), height: K(42) }} strokeWidth={2} />
          </Press>
        </At>
      </Art>
      <div style={{ height: 'calc(22 * var(--u))' }} />

      {items.map((p) => {
        const fav = liked.has(p.title);
        return (
          <Press key={p.title} onClick={() => toast(p.title)} style={{ marginBottom: 'calc(14 * var(--u))', borderRadius: 'calc(34 * var(--u))' }}>
            <Art w={865} h={232} src="cta-blank-wide" style={{ filter: 'drop-shadow(0 10px 12px rgba(0,0,0,.7)) drop-shadow(0 0 16px rgba(255,140,50,.3))' }}>
              <At x={48} y={46} w={216} h={140}>
                <div style={{ width: '100%', height: '100%', borderRadius: K(22), padding: K(3.5), background: 'linear-gradient(135deg,#ffe2a8,#d98a2e,#5a3510,#ffd58a)', boxShadow: `0 ${K(5)} ${K(7)} rgba(0,0,0,.8), 0 0 ${K(12)} rgba(255,122,26,.4)` }}>
                  <img src={img(p.photo)} alt={p.title} style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: K(19), display: 'block' }} />
                </div>
              </At>
              <At x={296} y={44} r={262} style={{ left: K(296) }}>
                <div style={{ fontSize: K(29), fontWeight: 800, lineHeight: 1.15, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{p.title}</div>
                <div style={{ fontSize: K(23), color: '#e6edf5', marginTop: K(2) }}>{p.kind}</div>
                <div style={{ display: 'flex', alignItems: 'center', gap: K(6), fontSize: K(21), marginTop: K(4) }}><MapPin style={{ width: K(24), height: K(24) }} />{p.place}</div>
                <div className="gold-text" style={{ fontSize: K(28), fontWeight: 900, lineHeight: 1.1, marginTop: K(4) }}>{p.price}</div>
              </At>
              <At x={0} y={44} style={{ right: K(44), left: 'auto', display: 'flex', gap: K(14) }}>
                <Press flat pop shine={false} label="Favourite" onClick={() => setLiked((s) => { const n = new Set(s); fav ? n.delete(p.title) : n.add(p.title); return n; })} style={{ padding: K(8), borderRadius: K(20) }}>
                  <Heart style={{ width: K(40), height: K(40), color: fav ? '#ff5a6d' : '#fff', fill: fav ? '#ff5a6d' : 'none' }} />
                </Press>
                <Press flat pop shine={false} label="More" onClick={() => toast('More options')} style={{ padding: K(8), borderRadius: K(20) }}>
                  <MoreVertical style={{ width: K(40), height: K(40) }} />
                </Press>
              </At>
              <At x={0} y={0} w={210} h={66} style={{ right: K(46), bottom: K(48), top: 'auto', left: 'auto' }}>
                <Press onClick={() => toast(`Chatting with the seller about ${p.title}`)} label="Buy Now" style={{ width: '100%', height: '100%', borderRadius: '999px' }}>
                  <img src={img('buy-btn')} alt="Buy Now" draggable={false} style={{ width: '100%', height: '100%', display: 'block' }} />
                </Press>
              </At>
            </Art>
          </Press>
        );
      })}
      {items.length === 0 && <p style={{ textAlign: 'center', color: '#8896a6', padding: 'calc(60 * var(--u))' }}>No listings found</p>}
    </PageShell>
  );
}
