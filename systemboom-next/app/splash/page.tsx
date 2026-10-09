'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Art } from '@/lib/ui';

export default function Splash() {
  const router = useRouter();
  useEffect(() => { const t = setTimeout(() => router.replace('/welcome/'), 2200); return () => clearTimeout(t); }, [router]);
  return (
    <div className="stage center-screen" onClick={() => router.replace('/welcome/')}>
      <div style={{ width: '88%', animation: 'breathe 2.4s ease-in-out infinite' }}>
        <Art w={863} h={193} src="logo-lockup" className="logoplate" />
        <div className="spinner" style={{ margin: 'calc(90 * var(--u)) auto 0' }} />
      </div>
    </div>
  );
}
