'use client';

import { VenetianMask } from 'lucide-react';
import { PageShell } from '@/components/PageShell';

export default function AnonymousPage() {
  return (
    <PageShell title="Anonymous" active="home">
      <div style={{ display: 'grid', placeItems: 'center', gap: 'calc(24 * var(--u))', padding: 'calc(160 * var(--u)) 0', textAlign: 'center' }}>
        <VenetianMask style={{ width: 'calc(180 * var(--u))', height: 'calc(180 * var(--u))', color: '#b6fff4', filter: 'drop-shadow(0 0 14px #28ebd7)' }} strokeWidth={1.4} />
        <p style={{ fontSize: 'calc(40 * var(--u))', fontWeight: 800, margin: 0 }}>Identity-free space</p>
        <p style={{ fontSize: 'calc(30 * var(--u))', color: '#c3cedb', margin: 0, maxWidth: '80%' }}>Voice and video, kept fully independent. Coming soon.</p>
      </div>
    </PageShell>
  );
}
