'use client';

import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function Splash() {
  const router = useRouter();
  useEffect(() => { const t = setTimeout(() => router.replace('/welcome/'), 2600); return () => clearTimeout(t); }, [router]);
  return (
    <div className="stage center-screen splashfull" onClick={() => router.replace('/welcome/')}>
      <div className="splashbg" />
      <div className="splashcore" style={{ animation: 'breathe 2.4s ease-in-out infinite' }}>
        <div className="splashlogo">SYSTEMBOOM</div>
        <div className="splashring" style={{ position: 'static', transform: 'none', margin: 'calc(70 * var(--u)) auto 0' }} />
      </div>
    </div>
  );
}
